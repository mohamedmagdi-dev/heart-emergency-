// Firestore notification listener
// Listens to notifications/{userId}/userNotifications in Firestore and triggers
// local notifications via NotificationService when new docs appear.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../features/notifications/notfication_services.dart';


class NotificationListenerService {
  NotificationListenerService._internal();
  static final NotificationListenerService _instance =
      NotificationListenerService._internal();
  factory NotificationListenerService() => _instance;

  static const String notificationsCollection = 'notifications';
  static const String userNotificationsSubCollection = 'userNotifications';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _subscription;

  void start() {
    final user = _auth.currentUser;
    if (user == null) return;

    final userId = user.uid;
    _subscription?.cancel();
    _subscription = _firestore
        .collection(notificationsCollection)
        .doc(userId)
        .collection(userNotificationsSubCollection)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      for (final doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          final data = doc.doc.data();
          if (data == null) continue;
          final String title = data['title']?.toString() ?? 'تنبيه';
          final String body = data['body']?.toString() ?? '';
          final bool delivered = data['delivered'] == true;

          // Avoid duplicate delivery if the sender marked delivered
          if (!delivered) {
            // NotificationService().showInstantNotification(
            //   title: title,
            //   body: body,
            //   payload: data['payload']?.toString(),
            // );
            NotificationService.showLocalNotification(
              title: title,
              body: body,
              payload: data['payload']?.toString(),
            );


            // Mark as delivered
            doc.doc.reference.update({'delivered': true}).catchError((_) {
              if (kDebugMode) {
                // ignore: avoid_print
                print('Failed to mark notification delivered');
              }
            });
          }
        }
      }
    });
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  // Expose unread count stream for dashboards without UI changes
  Stream<int> unreadCountStream(String userId) {
    return _firestore
        .collection(notificationsCollection)
        .doc(userId)
        .collection(userNotificationsSubCollection)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  // Recent notifications stream (most recent first)
  Stream<List<Map<String, dynamic>>> recentNotificationsStream(String userId,
      {int limit = 20}) {
    return _firestore
        .collection(notificationsCollection)
        .doc(userId)
        .collection(userNotificationsSubCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }
}


