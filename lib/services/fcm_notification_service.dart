// FCM Notification Service for sending actual push notifications
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class FCMNotificationService {
  // TODO: Replace with your actual FCM server key
  // You can find this in Firebase Console > Project Settings > Cloud Messaging > Server Key
  static const String _serverKey = 'YOUR_FCM_SERVER_KEY_HERE';
  static const String _fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  // Send notification to specific FCM token
  static Future<bool> sendNotificationToToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$_serverKey',
      };

      final payload = {
        'to': token,
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
        },
        'data': data ?? {},
        'priority': 'high',
      };

      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully to token: ${token.substring(0, 20)}...');
        return true;
      } else {
        print('Failed to send notification: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  // Send notification to user by userId (gets token from Firestore)
  static Future<bool> sendNotificationToUserId({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final userData = userDoc.data();
      final token = userData?['fcmToken'] as String?;

      if (token == null) {
        print('No FCM token found for user: $userId');
        return false;
      }

      return await sendNotificationToToken(
        token: token,
        title: title,
        body: body,
        data: data,
      );
    } catch (e) {
      print('Error sending notification to user: $e');
      return false;
    }
  }

  // Send notification to multiple users
  static Future<Map<String, bool>> sendNotificationToMultipleUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final results = <String, bool>{};

    for (final userId in userIds) {
      results[userId] = await sendNotificationToUserId(
        userId: userId,
        title: title,
        body: body,
        data: data,
      );
    }

    return results;
  }

  // Send notification to all users of a specific role
  static Future<Map<String, bool>> sendNotificationToRole({
    required String role,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: role)
          .where('fcmToken', isNotEqualTo: null)
          .get();

      final userIds = usersSnapshot.docs.map((doc) => doc.id).toList();

      return await sendNotificationToMultipleUsers(
        userIds: userIds,
        title: title,
        body: body,
        data: data,
      );
    } catch (e) {
      print('Error sending notification to role: $e');
      return {};
    }
  }

  // Log notification in Firestore for tracking
  static Future<void> logNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    bool sent = false,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'sent': sent,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging notification: $e');
    }
  }
}
