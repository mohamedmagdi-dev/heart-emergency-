// Enhanced request service for emergency requests
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/request_model.dart';
import '../data/models/user_model.dart';
import 'fcm_notification_service.dart';

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String requestsCollection = 'requests';

  // Create emergency request
  Future<String> createEmergencyRequest({
    required String doctorId,
    required String symptoms,
    required String urgencyLevel,
    required GeoPoint patientLocation,
    required String patientAddress,
    String? notes,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'يجب تسجيل الدخول أولاً';
      }

      // Check if doctor is available
      final doctorDoc = await _firestore.collection('users').doc(doctorId).get();
      if (!doctorDoc.exists) {
        throw 'الطبيب غير موجود';
      }

      final doctorData = doctorDoc.data()!;
      if (doctorData['available'] != true) {
        throw 'الطبيب غير متاح حالياً';
      }

      // Create the request
      final requestData = {
        'patientId': currentUser.uid,
        'doctorId': doctorId,
        'status': 'pending',
        'symptoms': symptoms,
        'urgencyLevel': urgencyLevel,
        'patientLocation': patientLocation,
        'patientAddress': patientAddress,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (notes != null) 'notes': notes,
      };

      final docRef = await _firestore.collection(requestsCollection).add(requestData);
      
      // Send FCM notification to doctor
      await _sendEmergencyRequestNotification(doctorId, currentUser.uid);
      
      return docRef.id;
    } catch (e) {
      throw 'فشل في إنشاء طلب الطوارئ: $e';
    }
  }

  // Get available doctors for emergency requests
  Future<List<UserModel>> getAvailableDoctors() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('verified', isEqualTo: true)
          .where('available', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw 'فشل في جلب الأطباء المتاحين: $e';
    }
  }

  // Get patient's emergency requests
  Stream<List<RequestModel>> getPatientEmergencyRequests(String patientId) {
    return _firestore
        .collection(requestsCollection)
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data(), documentId: doc.id);
      }).toList();
    });
  }

  // Get doctor's emergency requests
  Stream<List<RequestModel>> getDoctorEmergencyRequests(String doctorId) {
    return _firestore
        .collection(requestsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data(), documentId: doc.id);
      }).toList();
    });
  }

  // Accept emergency request
  Future<void> acceptEmergencyRequest(String requestId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'يجب تسجيل الدخول أولاً';
      }

      // Get the request to find patient ID
      final requestDoc = await _firestore.collection(requestsCollection).doc(requestId).get();
      if (!requestDoc.exists) {
        throw 'الطلب غير موجود';
      }

      final requestData = requestDoc.data()!;
      final patientId = requestData['patientId'] as String;

      // Update the request status
      await _firestore.collection(requestsCollection).doc(requestId).update({
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send FCM notification to patient
      await _sendRequestAcceptedNotification(patientId);
    } catch (e) {
      throw 'فشل في قبول الطلب: $e';
    }
  }

  // Reject emergency request
  Future<void> rejectEmergencyRequest(String requestId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'يجب تسجيل الدخول أولاً';
      }

      // Get the request to find patient ID
      final requestDoc = await _firestore.collection(requestsCollection).doc(requestId).get();
      if (!requestDoc.exists) {
        throw 'الطلب غير موجود';
      }

      final requestData = requestDoc.data()!;
      final patientId = requestData['patientId'] as String;

      // Update the request status
      await _firestore.collection(requestsCollection).doc(requestId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send FCM notification to patient
      await _sendRequestRejectedNotification(patientId);
    } catch (e) {
      throw 'فشل في رفض الطلب: $e';
    }
  }

  // Complete emergency request
  Future<void> completeEmergencyRequest(String requestId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'يجب تسجيل الدخول أولاً';
      }

      // Update the request status
      await _firestore.collection(requestsCollection).doc(requestId).update({
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'فشل في إكمال الطلب: $e';
    }
  }

  // Get user details for request display
  Future<UserModel?> getUserDetails(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        return UserModel.fromMap(userDoc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user details: $e');
      return null;
    }
  }

  // Send emergency request notification to doctor
  Future<void> _sendEmergencyRequestNotification(String doctorId, String patientId) async {
    try {
      // Get patient details
      final patient = await getUserDetails(patientId);
      if (patient == null) return;

      final sent = await FCMNotificationService.sendNotificationToUserId(
        userId: doctorId,
        title: 'طلب طارئ جديد',
        body: 'مريض ${patient.name} يحتاج إلى المساعدة فورًا.',
        data: {
          'type': 'emergency_request',
          'requestId': '',
          'patientId': patientId,
        },
      );

      // Log the notification
      await FCMNotificationService.logNotification(
        userId: doctorId,
        title: 'طلب طارئ جديد',
        body: 'مريض ${patient.name} يحتاج إلى المساعدة فورًا.',
        data: {
          'type': 'emergency_request',
          'requestId': '',
          'patientId': patientId,
        },
        sent: sent,
      );
    } catch (e) {
      print('Error sending emergency request notification: $e');
    }
  }

  // Send request accepted notification to patient
  Future<void> _sendRequestAcceptedNotification(String patientId) async {
    try {
      final sent = await FCMNotificationService.sendNotificationToUserId(
        userId: patientId,
        title: 'تم قبول طلب الطوارئ',
        body: 'الطبيب قبل طلبك وسيتم التواصل معك قريبًا.',
        data: {
          'type': 'request_accepted',
        },
      );

      // Log the notification
      await FCMNotificationService.logNotification(
        userId: patientId,
        title: 'تم قبول طلب الطوارئ',
        body: 'الطبيب قبل طلبك وسيتم التواصل معك قريبًا.',
        data: {
          'type': 'request_accepted',
        },
        sent: sent,
      );
    } catch (e) {
      print('Error sending request accepted notification: $e');
    }
  }

  // Send request rejected notification to patient
  Future<void> _sendRequestRejectedNotification(String patientId) async {
    try {
      final sent = await FCMNotificationService.sendNotificationToUserId(
        userId: patientId,
        title: 'تم رفض طلب الطوارئ',
        body: 'الطبيب رفض طلبك حاليًا.',
        data: {
          'type': 'request_rejected',
        },
      );

      // Log the notification
      await FCMNotificationService.logNotification(
        userId: patientId,
        title: 'تم رفض طلب الطوارئ',
        body: 'الطبيب رفض طلبك حاليًا.',
        data: {
          'type': 'request_rejected',
        },
        sent: sent,
      );
    } catch (e) {
      print('Error sending request rejected notification: $e');
    }
  }

  // Get request by ID
  Future<RequestModel?> getRequestById(String requestId) async {
    try {
      final doc = await _firestore.collection(requestsCollection).doc(requestId).get();
      if (doc.exists && doc.data() != null) {
        return RequestModel.fromMap(doc.data()!, documentId: doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting request by ID: $e');
      return null;
    }
  }

  // Get all emergency requests (admin)
  Stream<List<RequestModel>> getAllEmergencyRequests() {
    return _firestore
        .collection(requestsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data(), documentId: doc.id);
      }).toList();
    });
  }
}
