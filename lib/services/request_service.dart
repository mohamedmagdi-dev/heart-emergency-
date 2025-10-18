// Enhanced request service for emergency requests
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/request_model.dart';
import '../data/models/user_model.dart';
import 'fcm_notification_service.dart';
import 'notification_sender.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import '../core/utils/haversine.dart';
class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String requestsCollection = 'requests';
  // Add a simple request from current patient to a doctor
  Future<void> sendRequestToDoctor(String doctorId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'يجب تسجيل الدخول أولاً';
      }
      // Create minimal pending request
      final docRef = _firestore.collection(requestsCollection).doc();
      await docRef.set({
        'id': docRef.id,
        'patientId': user.uid,
        'doctorId': doctorId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Firestore notification to doctor
      await NotificationSender().sendNotification(
        toUserId: doctorId,
        title: 'New patient request', // إشعار جديد
        body: 'هناك طلب جديد من مريض',
        type: 'new_request',
        payload: {
          'requestId': docRef.id,
          'fromUserId': user.uid,
        },
      );
    } on FirebaseException catch (e) {
      // Friendly message if rules block access
      throw _friendlyFirestoreError(e, fallback: 'تعذر إرسال الطلب، تحقق من الصلاحيات.');
    } catch (e) {
      throw 'تعذر إرسال الطلب: $e';
    }
  }

  // Doctor responds to a request and notifies the patient
  Future<void> respondToRequest(String requestId, String patientId, bool accepted) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'يجب تسجيل الدخول أولاً';
      }

      final status = accepted ? 'accepted' : 'rejected'; // use 'rejected' to match existing enum

      await _firestore.collection(requestsCollection).doc(requestId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Firestore notification to patient
      await NotificationSender().sendNotification(
        toUserId: patientId,
        title: accepted ? 'تم قبول الطلب' : 'تم رفض الطلب',
        body: accepted
            ? 'تم قبول طلبك من الطبيب'
            : 'تم رفض طلبك من الطبيب حالياً',
        type: accepted ? 'request_accepted' : 'request_rejected',
        payload: {
          'requestId': requestId,
          'fromUserId': user.uid,
          'accepted': accepted,
        },
      );
    } on FirebaseException catch (e) {
      throw _friendlyFirestoreError(e, fallback: 'تعذر تحديث حالة الطلب.');
    } catch (e) {
      throw 'تعذر تحديث حالة الطلب: $e';
    }
  }

  String _friendlyFirestoreError(FirebaseException e, {required String fallback}) {
    switch (e.code) {
      case 'permission-denied':
        return 'ليس لديك صلاحية لتنفيذ هذه العملية.';
      case 'unavailable':
        return 'خدمة قاعدة البيانات غير متاحة مؤقتاً. حاول لاحقاً.';
      default:
        return fallback;
    }
  }

  // Create emergency request
  Future<String> createEmergencyRequest({
    required String doctorId,
    required String symptoms,
    required String urgencyLevel,
    required GeoPoint patientLocation,
    required String patientAddress,
    required double price, // Patient-set price
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
        // Pricing & commission (commissionRate stored for transparency)
        'price': price,
        'commissionRate': 0.12, // 12%
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
        'acceptedAt': FieldValue.serverTimestamp(),
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

      final docRef = _firestore.collection(requestsCollection).doc(requestId);
      final requestSnap = await docRef.get();
      if (!requestSnap.exists) {
        throw 'الطلب غير موجود';
      }
      final data = requestSnap.data()!;
      final double price = (data['finalPrice'] as num?)?.toDouble() ?? (data['price'] as num?)?.toDouble() ?? 0.0;
      final double commissionRate = (data['commissionRate'] as num?)?.toDouble() ?? 0.12;
      final double commissionAmount = double.parse((price * commissionRate).toStringAsFixed(2));

      // Update the request status + financials
      await docRef.update({
        'status': 'completed',
        'finalPrice': price,
        'commissionRate': commissionRate,
        'commissionAmount': commissionAmount,
        'completedAt': FieldValue.serverTimestamp(),
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

  // --- Live Tracking & ETA ---
  // Stream doctor location for a given request (after acceptance)
  Stream<GeoPoint?> streamDoctorLocation(String doctorId) {
    return _firestore.collection('users').doc(doctorId).snapshots().map((doc) {
      final map = doc.data();
      if (map == null) return null;
      return map['location'] as GeoPoint?;
    });
  }

  // Stream live distance (km) and ETA (minutes) between doctor and patient for a request
  // Assumes an average speed; can be refined with actual navigation SDK if added later.
  Stream<Map<String, dynamic>> streamDistanceAndEta({
    required GeoPoint patientLocation,
    required String doctorId,
    double averageSpeedKmPerHour = 40.0,
  }) {
    return streamDoctorLocation(doctorId).map((doctorGeo) {
      if (doctorGeo == null) {
        return {
          'distanceKm': null,
          'etaMinutes': null,
        };
      }
      final distanceKm = haversineDistanceKm(
        lat1: patientLocation.latitude,
        lon1: patientLocation.longitude,
        lat2: doctorGeo.latitude,
        lon2: doctorGeo.longitude,
      );
      final hours = distanceKm / averageSpeedKmPerHour;
      final etaMinutes = (hours * 60).ceil();
      return {
        'distanceKm': double.parse(distanceKm.toStringAsFixed(2)),
        'etaMinutes': etaMinutes,
      };
    });
  }

  // Update a request document with current distance and ETA (optional helper)
  Future<void> updateRequestDistanceAndEta({
    required String requestId,
    required double distanceKm,
    required int etaMinutes,
  }) async {
    await _firestore.collection(requestsCollection).doc(requestId).update({
      'distanceKm': distanceKm,
      'etaMinutes': etaMinutes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Admin Queries ---
  // Completed requests per doctor
  Stream<List<RequestModel>> getCompletedRequestsForDoctor(String doctorId) {
    return _firestore
        .collection(requestsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'completed')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }

  // Completed requests per patient
  Stream<List<RequestModel>> getCompletedRequestsForPatient(String patientId) {
    return _firestore
        .collection(requestsCollection)
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: 'completed')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }

  // 🟢 Added: Calculate doctor earning (88% after 12% commission)
  double calculateDoctorEarning(double price) {
    const double commissionRate = 0.12; // 12% commission
    return price * (1 - commissionRate); // Doctor gets 88%
  }

  // 🟢 Added: Get doctor earning for a completed request
  Future<double?> getDoctorEarning(String requestId) async {
    try {
      final doc = await _firestore.collection(requestsCollection).doc(requestId).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      final double? price = (data['finalPrice'] as num?)?.toDouble() ?? 
                           (data['price'] as num?)?.toDouble();
      
      if (price == null) return null;
      return calculateDoctorEarning(price);
    } catch (e) {
      print('Error getting doctor earning: $e');
      return null;
    }
  }
}
