// Enhanced request service for emergency requests
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/models/request_model.dart';
import '../data/models/user_model.dart';
import 'fcm_notification_service.dart';
import 'notification_sender.dart';
import 'earnings_service.dart';
import 'local_notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import '../core/utils/haversine.dart';
import 'image_upload_service.dart';
// ✅ إضافة المكتبات المطلوبة للعناوين والمسافة
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EarningsService _earningsService = EarningsService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final LocalNotificationService _localNotificationService = LocalNotificationService();
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
      Map<String, dynamic> requestData = {
        'patientId': currentUser.uid,
        'doctorId': doctorId,
        'status': 'pending',
        'symptoms': symptoms,
        'urgencyLevel': urgencyLevel,
        'patientLocation': patientLocation,
        'patientAddress': patientAddress,
        // Pricing & commission (commissionRate stored for transparency)
        // price will be set by the doctor later
        'commissionRate': 0.12, // 12%
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (notes != null) 'notes': notes,
      };
      
      // Process any local image paths in the request data
      requestData = await _imageUploadService.processImagePathsInMap(
        requestData,
        userId: currentUser.uid,
      );

      final docRef = await _firestore.collection(requestsCollection).add(requestData);
      
      // ✅ إضافة حساب العناوين والمسافة بعد إنشاء الطلب
      // جلب موقع الطبيب لحساب المسافة
      // final doctorDoc = await _firestore.collection('users').doc(doctorId).get();
      if (doctorDoc.exists) {
        final doctorData = doctorDoc.data()!;
        final doctorLocation = doctorData['location'] as GeoPoint?;
        
        if (doctorLocation != null) {
          // تحديث الطلب بالعناوين والمسافة (في الخلفية)
          updateRequestWithLocationData(
            requestId: docRef.id,
            patientLocation: patientLocation,
            doctorLocation: doctorLocation,
          );
        }
      }
      
      // Send FCM notification to doctor
      await _sendEmergencyRequestNotification(doctorId, currentUser.uid);
      
      return docRef.id;
    } catch (e) {
      throw 'فشل في إنشاء طلب الطوارئ: $e';
    }
  }

  // Doctor sets price for an emergency request and notifies the patient
  // Future<void> setPriceByDoctor({
  //   required String requestId,
  //   required double price,
  // }) async {
  //   try {
  //     final currentUser = _auth.currentUser;
  //     if (currentUser == null) {
  //       throw 'يجب تسجيل الدخول أولاً';
  //     }
  //
  //     final docRef = _firestore.collection(requestsCollection).doc(requestId);
  //     final snap = await docRef.get();
  //     if (!snap.exists) throw 'الطلب غير موجود';
  //     final data = snap.data()!;
  //
  //     // Ensure the requester is the assigned doctor
  //     final doctorId = data['doctorId'] as String?;
  //     final patientId = data['patientId'] as String?;
  //     if (doctorId == null || patientId == null) {
  //       throw 'بيانات الطلب غير مكتملة';
  //     }
  //     if (doctorId != currentUser.uid) {
  //       throw 'ليس لديك صلاحية لتحديد سعر هذا الطلب';
  //     }
  //
  //     // Get patient's currency from their user document
  //     final patientDoc = await _firestore.collection('users').doc(patientId).get();
  //     if (!patientDoc.exists) {
  //       throw 'بيانات المريض غير موجودة';
  //     }
  //     final patientData = patientDoc.data()!;
  //     final patientCurrency = patientData['currency'] as String? ?? 'EGP';
  //
  //     await docRef.update({
  //       'price': price,
  //       'currency': patientCurrency, // Save patient's currency
  //       'status': 'price_set',
  //       'priceSetAt': FieldValue.serverTimestamp(),
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     });
  //
  //     // Notify patient with proposed price using their currency
  //     await NotificationSender().sendNotification(
  //       toUserId: patientId,
  //       title: 'تم تحديد السعر',
  //       body: 'قام الطبيب بتحديد سعر الخدمة: ${price.toStringAsFixed(2)} $patientCurrency',
  //       type: 'price_set',
  //       payload: {
  //         'requestId': requestId,
  //         'price': price,
  //         'currency': patientCurrency,
  //       },
  //     );
  //   } on FirebaseException catch (e) {
  //     throw _friendlyFirestoreError(e, fallback: 'تعذر تحديد السعر.');
  //   } catch (e) {
  //     throw 'تعذر تحديد السعر: $e';
  //   }
  // }
  Future<void> setPriceByDoctor({
    required String requestId,
    required double price,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'يجب تسجيل الدخول أولاً';
      }

      final docRef = _firestore.collection(requestsCollection).doc(requestId);
      final snap = await docRef.get();
      if (!snap.exists) throw 'الطلب غير موجود';
      final data = snap.data()!;

      // Ensure the requester is the assigned doctor
      final doctorId = data['doctorId'] as String?;
      final patientId = data['patientId'] as String?;
      if (doctorId == null || patientId == null) {
        throw 'بيانات الطلب غير مكتملة';
      }
      if (doctorId != currentUser.uid) {
        throw 'ليس لديك صلاحية لتحديد سعر هذا الطلب';
      }

      // Check if price has already been set
      final currentStatus = data['status'] as String?;
      if (currentStatus == 'price_set' || data['price'] != null) {
        throw 'تم تحديد السعر مسبقاً ولا يمكن تغييره';
      }

      // Get patient's currency from their user document
      final patientDoc = await _firestore.collection('users').doc(patientId).get();
      if (!patientDoc.exists) {
        throw 'بيانات المريض غير موجودة';
      }
      final patientData = patientDoc.data()!;
      final patientCurrency = patientData['currency'] as String? ?? 'EGP';

      // ✅ التعديل المهم: استخدم 'price_set' بدل 'accepted'
      await docRef.update({
        'price': price,
        'currency': patientCurrency,
        'status': 'price_set', // ⬅️ دا التعديل الأساسي
        'priceSetAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ✅ إشعار المريض بتحديد السعر
      await NotificationSender().sendNotification(
        toUserId: patientId,
        title: 'تم تحديد السعر',
        body: 'قام الطبيب بتحديد سعر الخدمة: ${price.toStringAsFixed(2)} $patientCurrency',
        type: 'price_set',
        payload: {
          'requestId': requestId,
          'price': price,
          'currency': patientCurrency,
        },
      );

      // ✅ إشعار الطبيب بتحديد السعر
      await NotificationSender().sendNotification(
        toUserId: doctorId,
        title: 'تم تحديد السعر بنجاح',
        body: 'تم تحديد سعر الخدمة: ${price.toStringAsFixed(2)} $patientCurrency',
        type: 'price_set_doctor',
        payload: {
          'requestId': requestId,
          'price': price,
          'currency': patientCurrency,
        },
      );

      // ✅ إشعار محلي للمريض
      await _localNotificationService.showPriceSetNotification(
        amount: price,
        currency: patientCurrency,
        requestId: requestId,
      );
    } on FirebaseException catch (e) {
      throw _friendlyFirestoreError(e, fallback: 'تعذر تحديد السعر.');
    } catch (e) {
      throw 'تعذر تحديد السعر: $e';
    }
  }

  // Doctor accepts the request (after price is set) - goes directly to completed
  Future<void> acceptRequestByDoctor({
    required String requestId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'يجب تسجيل الدخول أولاً';
      }

      final docRef = _firestore.collection(requestsCollection).doc(requestId);
      final snap = await docRef.get();
      if (!snap.exists) throw 'الطلب غير موجود';
      final data = snap.data()!;

      final doctorId = data['doctorId'] as String?;
      final patientId = data['patientId'] as String?;
      if (doctorId == null || patientId == null) {
        throw 'بيانات الطلب غير مكتملة';
      }
      if (doctorId != currentUser.uid) {
        throw 'ليس لديك صلاحية لقبول هذا الطلب';
      }

      // Check if price has been set
      if (data['price'] == null) {
        throw 'يجب تحديد السعر أولاً قبل قبول الطلب';
      }

      final price = (data['price'] as num?)?.toDouble() ?? 0.0;
      final commissionRate = (data['commissionRate'] as num?)?.toDouble() ?? 0.12;
      final commissionAmount = price * commissionRate;

      // Update request to completed status
      await docRef.update({
        'status': 'completed',
        'finalPrice': price,
        'commissionRate': commissionRate,
        'commissionAmount': commissionAmount,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update doctor earnings
      await _earningsService.onRequestCompleted(doctorId);

      // Notify patient
      await NotificationSender().sendNotification(
        toUserId: patientId,
        title: 'تم قبول الطلب',
        body: 'قبل الطبيب طلبك وسيتم التواصل معك قريباً',
        type: 'request_accepted',
        payload: {
          'requestId': requestId,
          'fromUserId': doctorId,
          'accepted': true,
        },
      );

      // Show local notification to patient
      await _localNotificationService.showRequestAcceptedNotification(
        doctorName: 'الطبيب',
        requestId: requestId,
      );

    } on FirebaseException catch (e) {
      throw _friendlyFirestoreError(e, fallback: 'تعذر قبول الطلب.');
    } catch (e) {
      throw 'تعذر قبول الطلب: $e';
    }
  }

  // Doctor rejects the request (after price is set) - goes to rejected_by_doctor
  Future<void> rejectRequestByDoctor({
    required String requestId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'يجب تسجيل الدخول أولاً';
      }

      final docRef = _firestore.collection(requestsCollection).doc(requestId);
      final snap = await docRef.get();
      if (!snap.exists) throw 'الطلب غير موجود';
      final data = snap.data()!;

      final doctorId = data['doctorId'] as String?;
      final patientId = data['patientId'] as String?;
      if (doctorId == null || patientId == null) {
        throw 'بيانات الطلب غير مكتملة';
      }
      if (doctorId != currentUser.uid) {
        throw 'ليس لديك صلاحية لرفض هذا الطلب';
      }

      // Update request to rejected_by_doctor status
      await docRef.update({
        'status': 'rejected_by_doctor',
        'updatedAt': FieldValue.serverTimestamp(),
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      // Notify patient
      await NotificationSender().sendNotification(
        toUserId: patientId,
        title: 'تم رفض الطلب',
        body: 'رفض الطبيب طلبك حالياً',
        type: 'request_rejected',
        payload: {
          'requestId': requestId,
          'fromUserId': doctorId,
          'accepted': false,
        },
      );

      // Show local notification to patient
      await _localNotificationService.showRequestRejectedNotification(
        doctorName: 'الطبيب',
        requestId: requestId,
      );

    } on FirebaseException catch (e) {
      throw _friendlyFirestoreError(e, fallback: 'تعذر رفض الطلب.');
    } catch (e) {
      throw 'تعذر رفض الطلب: $e';
    }
  }

  // Patient accepts or rejects the doctor's price and notifies the doctor
  Future<void> respondToDoctorPrice({
    required String requestId,
    required bool accepted,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'يجب تسجيل الدخول أولاً';
      }

      final docRef = _firestore.collection(requestsCollection).doc(requestId);
      final snap = await docRef.get();
      if (!snap.exists) throw 'الطلب غير موجود';
      final data = snap.data()!;

      final doctorId = data['doctorId'] as String?;
      final patientId = data['patientId'] as String?;
      if (doctorId == null || patientId == null) {
        throw 'بيانات الطلب غير مكتملة';
      }
      if (patientId != currentUser.uid) {
        throw 'ليس لديك صلاحية للرد على هذا الطلب';
      }

      await docRef.update({
        'status': accepted ? 'accepted' : 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
        if (accepted) 'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Notify doctor
      await NotificationSender().sendNotification(
        toUserId: doctorId,
        title: accepted ? 'تم قبول السعر' : 'تم رفض السعر',
        body: accepted
            ? 'وافق المريض على السعر المحدد'
            : 'رفض المريض السعر المحدد',
        type: accepted ? 'price_accepted' : 'price_rejected',
        payload: {
          'requestId': requestId,
          'accepted': accepted,
        },
      );

      // Show local notification to doctor
      if (accepted) {
        await _localNotificationService.showPriceAcceptedNotification(
          requestId: requestId,
        );
      } else {
        await _localNotificationService.showPriceDeclinedNotification(
          requestId: requestId,
        );
      }
    } on FirebaseException catch (e) {
      throw _friendlyFirestoreError(e, fallback: 'تعذر تحديث حالة الطلب.');
    } catch (e) {
      throw 'تعذر تحديث حالة الطلب: $e';
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
      final String doctorId = data['doctorId'] as String? ?? '';

      // Update the request status + financials
      await docRef.update({
        'status': 'completed',
        'finalPrice': price,
        'commissionRate': commissionRate,
        'commissionAmount': commissionAmount,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update doctor earnings
      if (doctorId.isNotEmpty) {
        await _earningsService.onRequestCompleted(doctorId);
      }
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

  // Stream recent completed requests for real-time updates
  Stream<List<RequestModel>> streamRecentCompletedRequests({
    required String doctorId,
    int limit = 10,
  }) {
    return _firestore
        .collection(requestsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }

  // ✅ تحويل الإحداثيات إلى عنوان عربي قابل للقراءة
  Future<String> _getArabicAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // بناء العنوان باللغة العربية
        final addressParts = <String>[];
        
        if (placemark.street != null && placemark.street!.isNotEmpty) {
          addressParts.add(placemark.street!);
        }
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          addressParts.add(placemark.subLocality!);
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressParts.add(placemark.locality!);
        }
        if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
          addressParts.add(placemark.administrativeArea!);
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          addressParts.add(placemark.country!);
        }
        
        return addressParts.isNotEmpty ? addressParts.join(', ') : "العنوان غير متاح";
      }
      return "العنوان غير متاح";
    } catch (e) {
      print('خطأ في تحويل الإحداثيات إلى عنوان: $e');
      return "العنوان غير متاح";
    }
  }

  // ✅ حساب المسافة والوقت المقدر باستخدام Google Distance Matrix API
  Future<Map<String, dynamic>> _calculateDistanceAndDuration({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      // TODO: يجب إضافة Google Maps API Key هنا
      const String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // ⚠️ يجب استبدالها بمفتاح API الحقيقي
      const String baseUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json';
      
      final String origins = '$originLat,$originLng';
      final String destinations = '$destLat,$destLng';
      
      final String url = '$baseUrl?origins=$origins&destinations=$destinations&language=ar&key=$apiKey';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['rows'].isNotEmpty) {
          final element = data['rows'][0]['elements'][0];
          
          if (element['status'] == 'OK') {
            final distance = element['distance']['value'] / 1000.0; // تحويل من متر إلى كيلومتر
            final duration = element['duration']['text']; // النص باللغة العربية
            
            return {
              'distance': distance,
              'duration': duration,
              'success': true,
            };
          }
        }
      }
      
      // في حالة الفشل، استخدم حساب المسافة التقريبي
      final distance = haversineDistanceKm(
        lat1: originLat,
        lon1: originLng,
        lat2: destLat,
        lon2: destLng,
      );
      
      // تقدير الوقت بناءً على متوسط السرعة (40 كم/ساعة)
      final estimatedMinutes = (distance / 40.0 * 60).round();
      final duration = '${estimatedMinutes} دقيقة';
      
      return {
        'distance': distance,
        'duration': duration,
        'success': false, // يشير إلى أنه تقدير وليس من Google API
      };
    } catch (e) {
      print('خطأ في حساب المسافة والوقت: $e');
      
      // في حالة الفشل، استخدم حساب المسافة التقريبي
      final distance = haversineDistanceKm(
        lat1: originLat,
        lon1: originLng,
        lat2: destLat,
        lon2: destLng,
      );
      
      final estimatedMinutes = (distance / 40.0 * 60).round();
      final duration = '${estimatedMinutes} دقيقة';
      
      return {
        'distance': distance,
        'duration': duration,
        'success': false,
      };
    }
  }

  // ✅ تحديث طلب الطوارئ بالعناوين والمسافة والوقت المقدر
  Future<void> updateRequestWithLocationData({
    required String requestId,
    required GeoPoint patientLocation,
    required GeoPoint doctorLocation,
  }) async {
    try {
      // تحويل إحداثيات المريض إلى عنوان عربي
      final patientAddress = await _getArabicAddressFromCoordinates(
        patientLocation.latitude,
        patientLocation.longitude,
      );
      
      // تحويل إحداثيات الطبيب إلى عنوان عربي
      final doctorAddress = await _getArabicAddressFromCoordinates(
        doctorLocation.latitude,
        doctorLocation.longitude,
      );
      
      // حساب المسافة والوقت المقدر
      final distanceData = await _calculateDistanceAndDuration(
        originLat: patientLocation.latitude,
        originLng: patientLocation.longitude,
        destLat: doctorLocation.latitude,
        destLng: doctorLocation.longitude,
      );
      
      // تحديث الطلب في Firestore
      await _firestore.collection(requestsCollection).doc(requestId).update({
        'patientAddress': patientAddress,
        'doctorAddress': doctorAddress,
        'distance': distanceData['distance'],
        'duration': distanceData['duration'],
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('تم تحديث الطلب بالعناوين والمسافة بنجاح');
    } catch (e) {
      print('خطأ في تحديث بيانات الموقع: $e');
      // لا نرمي خطأ هنا لتجنب تعطيل التطبيق
    }
  }

  // ✅ تحديث طلب موجود بالعناوين والمسافة (للاستخدام مع الطلبات الموجودة)
  Future<void> enrichRequestWithLocationData(String requestId) async {
    try {
      final requestDoc = await _firestore.collection(requestsCollection).doc(requestId).get();
      if (!requestDoc.exists) return;
      
      final requestData = requestDoc.data()!;
      final patientLocation = requestData['patientLocation'] as GeoPoint?;
      final doctorId = requestData['doctorId'] as String?;
      
      if (patientLocation == null || doctorId == null) return;
      
      // جلب موقع الطبيب
      final doctorDoc = await _firestore.collection('users').doc(doctorId).get();
      if (!doctorDoc.exists) return;
      
      final doctorData = doctorDoc.data()!;
      final doctorLocation = doctorData['location'] as GeoPoint?;
      
      if (doctorLocation == null) return;
      
      // تحديث الطلب بالبيانات الجديدة
      await updateRequestWithLocationData(
        requestId: requestId,
        patientLocation: patientLocation,
        doctorLocation: doctorLocation,
      );
    } catch (e) {
      print('خطأ في إثراء الطلب ببيانات الموقع: $e');
    }
  }

  // ✅ مثال على كيفية استخدام الميزات الجديدة في الواجهات
  // يمكن استخدام هذه الدالة في شاشات عرض تفاصيل الطلب
  Widget buildLocationInfoWidget(RequestModel request) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات الموقع',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // عنوان المريض
            if (request.patientAddress != null && request.patientAddress!.isNotEmpty)
              _buildInfoRow('عنوان المريض:', request.patientAddress!),
            
            // عنوان الطبيب
            if (request.doctorAddress != null && request.doctorAddress!.isNotEmpty)
              _buildInfoRow('عنوان الطبيب:', request.doctorAddress!),
            
            // المسافة والوقت المقدر
            if (request.distance != null && request.duration != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.directions_car, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('المسافة: ${request.distance!.toStringAsFixed(1)} كم'),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('الوقت المقدر: ${request.duration}'),
                ],
              ),
            ],
            
            // رسالة في حالة عدم توفر البيانات
            if ((request.patientAddress == null || request.patientAddress!.isEmpty) &&
                (request.doctorAddress == null || request.doctorAddress!.isEmpty))
              const Text(
                'جاري تحميل معلومات الموقع...',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              // style: const TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
