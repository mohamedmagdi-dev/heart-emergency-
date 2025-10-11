import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRequestService {
  final _firestore = FirebaseFirestore.instance;

  /// إنشاء إشعار جديد (مثلاً عند إنشاء طلب)
  Future<void> createRequestNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    required String requestId,
  }) async {
    await _firestore.collection('request_notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'requestId': requestId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// جلب الإشعارات الخاصة بالمستخدم الحالي
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('request_notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// وضع الإشعار كمقروء
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('request_notifications')
        .doc(notificationId)
        .update({'read': true});
  }
}
