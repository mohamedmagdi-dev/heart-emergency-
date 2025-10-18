// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
//
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _plugin =
//   FlutterLocalNotificationsPlugin();
//
//
//   static Future<void> init() async {
//     const AndroidInitializationSettings androidInit =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//
//     const InitializationSettings initSettings =
//     InitializationSettings(android: androidInit);
//
//
//     await _plugin.initialize(initSettings,
//         onDidReceiveNotificationResponse: (details) {
// // هنا يمكن التعامل مع الضغط على الاشعار لو عايز توجّه لصفحة
// // سيتم إرسال payload في كل إشعار لو حبيت
//         });
//   }
//
//
//   static Future<void> showLocalNotification({
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails('default_channel', 'General',
//         importance: Importance.max, priority: Priority.high);
//
//
//     const NotificationDetails details = NotificationDetails(android: androidDetails);
//
//
//     await _plugin.show(
//         DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details,
//         payload: payload);
//   }
// }

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();


  // ⬅️🔑 لازم السطر ده يتضاف عشان نقدر نوصل للـ plugin من main.dart
  static FlutterLocalNotificationsPlugin get plugin => _plugin;
  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // لما المستخدم يضغط على الإشعار
        print("Notification clicked: ${details.payload}");
      },
    );

    // اطلب إذن الإشعارات
    await _requestNotificationPermission();
  }

  static Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isDenied) {
      print('🔕 Notification permission denied');
    }
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'default_channel',
      'General',
      channelDescription: 'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
