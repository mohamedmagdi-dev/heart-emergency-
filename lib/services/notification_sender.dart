// Notification sender utilities
// Provides a clean API to store notifications in Firestore under
// notifications/{userId}/userNotifications without touching UI.

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSender {
  NotificationSender._internal();
  static final NotificationSender _instance = NotificationSender._internal();
  factory NotificationSender() => _instance;

  static const String notificationsCollection = 'notifications';
  static const String userNotificationsSubCollection = 'userNotifications';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendNotification({
    required String toUserId,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
    String? type, // e.g., 'admin_approval', 'patient_request', 'doctor_response'
  }) async {
    final docRef = _firestore
        .collection(notificationsCollection)
        .doc(toUserId)
        .collection(userNotificationsSubCollection)
        .doc();

    await docRef.set({
      'id': docRef.id,
      'title': title,
      'body': body,
      'type': type,
      'payload': payload,
      'createdAt': FieldValue.serverTimestamp(),
      'delivered': false,
      'read': false,
    });
  }

  // Convenience helpers for the specified flows
  Future<void> notifyDoctorApproved({
    required String doctorUserId,
  }) async {
    await sendNotification(
      toUserId: doctorUserId,
      title: 'تمت الموافقة',
      body: 'تمت الموافقة على حسابك من قبل الإدارة.',
      type: 'admin_approval',
    );
  }

  Future<void> notifyDoctorRejected({
    required String doctorUserId,
  }) async {
    await sendNotification(
      toUserId: doctorUserId,
      title: 'تم الرفض',
      body: 'تم رفض حسابك من قبل الإدارة.',
      type: 'admin_rejection',
    );
  }

  Future<void> notifyDoctorUnverified({
    required String doctorUserId,
  }) async {
    await sendNotification(
      toUserId: doctorUserId,
      title: 'تم إزالة التحقق',
      body: 'قام المسؤول بإلغاء توثيق حسابك.',
      type: 'admin_unverify',
    );
  }

  Future<void> notifyPatientRequestedDoctor({
    required String doctorUserId,
    required String patientUserId,
    required String requestId,
  }) async {
    await sendNotification(
      toUserId: doctorUserId,
      title: 'طلب جديد',
      body: 'قام مريض بطلبك لحالة طارئة.',
      type: 'patient_request',
      payload: {
        'requestId': requestId,
        'patientUserId': patientUserId,
      },
    );
  }

  Future<void> notifyPatientDoctorAccepted({
    required String patientUserId,
    required String doctorUserId,
    required String requestId,
  }) async {
    await sendNotification(
      toUserId: patientUserId,
      title: 'تم قبول الطلب',
      body: 'قام الطبيب بقبول طلبك.',
      type: 'doctor_accept',
      payload: {
        'requestId': requestId,
        'doctorUserId': doctorUserId,
      },
    );
  }

  Future<void> notifyPatientDoctorRejected({
    required String patientUserId,
    required String doctorUserId,
    required String requestId,
  }) async {
    await sendNotification(
      toUserId: patientUserId,
      title: 'تم رفض الطلب',
      body: 'قام الطبيب برفض طلبك.',
      type: 'doctor_reject',
      payload: {
        'requestId': requestId,
        'doctorUserId': doctorUserId,
      },
    );
  }
}


