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

  // /// جلب الإشعارات الخاصة بالمستخدم الحالي
  // Stream<QuerySnapshot> getUserNotifications(String userId) {
  //   return _firestore
  //       .collection('request_notifications')
  //       .where('userId', isEqualTo: userId)
  //       .orderBy('createdAt', descending: true)
  //       .snapshots();
  // }
  // --- ✅ الدالة المعدلة والمرنة ---
  /// جلب الإشعارات الخاصة بالمستخدم مع فلترة اختيارية للحالة (مقروء/غير مقروء)
  Stream<QuerySnapshot> getUserNotifications(String userId, {bool? read}) {
    // 1. ابدأ ببناء الـ Query الأساسي
    Query query = _firestore
        .collection('request_notifications') // اتأكد إن ده اسم الكولكشن الصح
        .where('userId', isEqualTo: userId);

    // 2. لو المستخدم طلب فلترة، ضيفها للـ Query
    if (read != null) {
      query = query.where('read', isEqualTo: read);
    }

    // 3. في النهاية، رتب الداتا ورجع الـ Stream
    return query.orderBy('createdAt', descending: true).snapshots();
  }

  /// وضع الإشعار كمقروء
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('request_notifications')
        .doc(notificationId)
        .update({'read': true});
  }
  Future<void> markAllAsRead(String userId) async {
    final query = await _firestore
        .collection('request_notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in query.docs) {
      await doc.reference.update({'read': true});
    }
  }
  Stream<QuerySnapshot> getUnreadUserNotifications(String userId) {
    return _firestore
        .collection('request_notifications') // Make sure this collection name is correct
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false) // بنفلتر هنا من الأول
        .snapshots();
  }

}
