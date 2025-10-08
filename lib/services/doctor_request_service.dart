// Service for managing doctor requests
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/doctor_request_model.dart';
import '../data/models/user_model.dart';
import 'fcm_notification_service.dart';

class DoctorRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

 // static const String requestsCollection = 'doctor_requests';
  static const String requestsCollection = 'requests';
  // Create a new doctor request
  Future<String> createDoctorRequest({
    required String doctorId,
    String? message,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'يجب تسجيل الدخول أولاً';
      }

      // Check if there's already a pending request to this doctor
      final existingRequest = await _firestore
          .collection(requestsCollection)
          .where('patientId', isEqualTo: currentUser.uid)
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw 'لديك طلب معلق بالفعل لهذا الطبيب';
      }

      // Create the request
      final requestData = {
        'patientId': currentUser.uid,
        'doctorId': doctorId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (message != null) 'message': message,
      };

      final docRef = await _firestore.collection(requestsCollection).add(requestData);
      
      // Send FCM notification to doctor
      await _sendRequestNotificationToDoctor(doctorId, currentUser.uid);
      
      return docRef.id;
    } catch (e) {
      throw 'فشل في إنشاء الطلب: $e';
    }
  }

  // Get pending requests for a doctor
  Stream<List<DoctorRequestModel>> getPendingRequestsForDoctor() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(requestsCollection)
        .where('doctorId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DoctorRequestModel.fromMap(doc.data(), documentId: doc.id);
      }).toList();
    });
  }

  // Get requests made by a patient
  Stream<List<DoctorRequestModel>> getRequestsByPatient() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(requestsCollection)
        .where('patientId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DoctorRequestModel.fromMap(doc.data(), documentId: doc.id);
      }).toList();
    });
  }

  // Accept a doctor request
  Future<void> acceptRequest(String requestId, {String? responseMessage}) async {
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
        if (responseMessage != null) 'responseMessage': responseMessage,
      });

      // Send FCM notification to patient
      await _sendAcceptanceNotificationToPatient(patientId);
    } catch (e) {
      throw 'فشل في قبول الطلب: $e';
    }
  }

  // Reject a doctor request
  Future<void> rejectRequest(String requestId, {String? responseMessage}) async {
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
        if (responseMessage != null) 'responseMessage': responseMessage,
      });

      // Send FCM notification to patient
      await _sendRejectionNotificationToPatient(patientId);
    } catch (e) {
      throw 'فشل في رفض الطلب: $e';
    }
  }

  // Get user details for a request
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

  // Send notification to doctor when request is created
  Future<void> _sendRequestNotificationToDoctor(String doctorId, String patientId) async {
    try {
      // Get patient details
      final patient = await getUserDetails(patientId);
      if (patient == null) return;

      final sent = await FCMNotificationService.sendNotificationToUserId(
        userId: doctorId,
        title: 'طلب جديد من مريض',
        body: 'مريض ${patient.name} يحتاج إلى المساعدة الآن.',
        data: {
          'type': 'doctor_request',
          'requestId': '',
          'patientId': patientId,
        },
      );

      // Log the notification
      await FCMNotificationService.logNotification(
        userId: doctorId,
        title: 'طلب جديد من مريض',
        body: 'مريض ${patient.name} يحتاج إلى المساعدة الآن.',
        data: {
          'type': 'doctor_request',
          'requestId': '',
          'patientId': patientId,
        },
        sent: sent,
      );
    } catch (e) {
      print('Error sending request notification to doctor: $e');
    }
  }

  // Send notification to patient when request is accepted
  Future<void> _sendAcceptanceNotificationToPatient(String patientId) async {
    try {
      final sent = await FCMNotificationService.sendNotificationToUserId(
        userId: patientId,
        title: 'تم قبول طلبك',
        body: 'الطبيب قبل طلبك وسيتم التواصل معك قريبًا.',
        data: {
          'type': 'request_accepted',
        },
      );

      // Log the notification
      await FCMNotificationService.logNotification(
        userId: patientId,
        title: 'تم قبول طلبك',
        body: 'الطبيب قبل طلبك وسيتم التواصل معك قريبًا.',
        data: {
          'type': 'request_accepted',
        },
        sent: sent,
      );
    } catch (e) {
      print('Error sending acceptance notification to patient: $e');
    }
  }

  // Send notification to patient when request is rejected
  Future<void> _sendRejectionNotificationToPatient(String patientId) async {
    try {
      final sent = await FCMNotificationService.sendNotificationToUserId(
        userId: patientId,
        title: 'تم رفض طلبك',
        body: 'الطبيب رفض طلبك حاليًا.',
        data: {
          'type': 'request_rejected',
        },
      );

      // Log the notification
      await FCMNotificationService.logNotification(
        userId: patientId,
        title: 'تم رفض طلبك',
        body: 'الطبيب رفض طلبك حاليًا.',
        data: {
          'type': 'request_rejected',
        },
        sent: sent,
      );
    } catch (e) {
      print('Error sending rejection notification to patient: $e');
    }
  }
}
