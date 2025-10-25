// CHANGED_FOR_FIREBASE_INTEGRATION: Firebase Cloud Messaging service for push notifications
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Top-level handler for background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize FCM
  Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Configure FCM
      await _configureFCM();

      // Get and save FCM token
      await _saveFCMToken();
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  // Get FCM token
  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  // Configure FCM handlers
  Future<void> _configureFCM() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.messageId}');
      _showLocalNotification(message);
    });

    // Handle when user taps on notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped: ${message.messageId}');
      _handleNotificationTap(message);
    });

    // Check if app was opened from a notification
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      // 🟢 Added: Show WhatsApp-style notification bubble
      _showNotificationBubble(notification.title ?? 'تنبيه', notification.body ?? '');
      
      // Also show system notification
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            playSound: true,
            category: AndroidNotificationCategory.message,
            ticker: 'ticker',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: _encodePayload(message),
      );
    }
  }

  // 🟢 Added: Show WhatsApp-style notification bubble
  void _showNotificationBubble(String title, String message) {
    // This would need to be called from a widget context
    // For now, we'll store the notification data to be shown when the app is active
    _pendingNotification = {'title': title, 'message': message};
  }

  Map<String, String>? _pendingNotification;

  // 🟢 Added: Get pending notification to show in UI
  Map<String, String>? getPendingNotification() {
    final notification = _pendingNotification;
    _pendingNotification = null;
    return notification;
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) async {
    try {
      final data = _decodePayload(response.payload);
      if (data == null) return;
      await _markNotificationAsRead(data);
      // TODO: Optionally navigate based on data['route'] or data['requestId']
    } catch (e) {
      print('Error handling local notification tap: $e');
    }
  }

  // Handle FCM notification tap
  void _handleNotificationTap(RemoteMessage message) async {
    try {
      await _markNotificationAsRead(message.data);
      // TODO: Optionally navigate based on message.data
    } catch (e) {
      print('Error handling FCM notification tap: $e');
    }
  }

  String _encodePayload(RemoteMessage message) {
    try {
      final map = <String, dynamic>{
        ...message.data,
        'title': message.notification?.title,
        'body': message.notification?.body,
      };
      return map.toString();
    } catch (_) {
      return message.data.toString();
    }
  }

  Map<String, dynamic>? _decodePayload(String? payload) {
    if (payload == null) return null;
    try {
      // payload from toString() won't be strict JSON; fallback to key parsing
      final map = <String, dynamic>{};
      final trimmed = payload.trim();
      final content = trimmed.startsWith('{') && trimmed.endsWith('}')
          ? trimmed.substring(1, trimmed.length - 1)
          : trimmed;
      for (final part in content.split(',')) {
        final kv = part.split(':');
        if (kv.length >= 2) {
          final k = kv[0].trim().replaceAll("'", '');
          final v = kv.sublist(1).join(':').trim().replaceAll("'", '');
          map[k] = v;
        }
      }
      return map;
    } catch (e) {
      print('Failed to decode payload: $e');
      return null;
    }
  }

  Future<void> _markNotificationAsRead(Map<String, dynamic> data) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Try direct notification document by id
      final notifId = data['notificationId'] as String? ?? data['id'] as String?;
      if (notifId != null && notifId.isNotEmpty) {
        await _firestore.collection('notifications').doc(notifId).update({
          'read': true,
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      // Otherwise, mark latest unread for this user with same title/body as read
      final title = data['title'] as String?;
      final body = data['body'] as String?;
      final q = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUserId)
          .where('read', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      for (final d in q.docs) {
        final m = d.data();
        if ((title == null || m['title'] == title) && (body == null || m['body'] == body)) {
          await d.reference.update({
            'read': true,
            'isRead': true,
            'readAt': FieldValue.serverTimestamp(),
          });
          break;
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Save FCM token to Firestore
  Future<void> _saveFCMToken() async {
    try {
      final token = await _fcm.getToken();
      final userId = _auth.currentUser?.uid;

      if (token != null && userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) async {
        final userId = _auth.currentUser?.uid;
        if (userId != null) {
          await _firestore.collection('users').doc(userId).update({
            'fcmToken': newToken,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Send notification to specific user by token
  Future<void> sendNotificationToUser({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Store notification in Firestore for record keeping
      await _firestore.collection('notifications').add({
        'token': token,
        'title': title,
        'body': body,
        'data': data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'sent': true, // Assuming successful for now
      });

      print('Notification queued: $title to token: ${token.substring(0, 20)}...');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Send notification to specific user by userId
  Future<void> sendNotificationToUserId({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final token = userData?['fcmToken'] as String?;

      if (token != null) {
        await sendNotificationToUser(
          token: token,
          title: title,
          body: body,
          data: data,
        );
      } else {
        print('No FCM token found for user: $userId');
      }
    } catch (e) {
      print('Error sending notification to user: $e');
    }
  }

  // Broadcast notification to all users of a specific role
  Future<void> broadcastNotificationToRole({
    required String role,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .where('fcmToken', isNotEqualTo: null)
          .get();

      for (final doc in usersSnapshot.docs) {
        final userData = doc.data();
        final token = userData['fcmToken'] as String?;

        if (token != null) {
          await sendNotificationToUser(
            token: token,
            title: title,
            body: body,
            data: data,
          );
        }
      }
    } catch (e) {
      print('Error broadcasting notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Clear specific notification
  Future<void> clearNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}

