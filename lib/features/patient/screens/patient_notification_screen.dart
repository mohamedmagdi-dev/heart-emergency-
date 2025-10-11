import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../notifications/notification_request_service.dart';

class PatientNotificationsScreen extends StatelessWidget {
  final String userId;

  const PatientNotificationsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final NotificationRequestService _notificationService = NotificationRequestService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E40AF),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationService.getUserNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ أثناء تحميل الإشعارات: ${snapshot.error}'));
          }

          final notifications = snapshot.data?.docs ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد إشعارات حالياً',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final data = notification.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    child: const Icon(Icons.notifications, color: Colors.blueAccent),
                  ),
                  title: Text(
                    data['title'] ?? 'إشعار',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(data['body'] ?? ''),
                  trailing: data['read'] == false
                      ? const Icon(Icons.fiber_new, color: Colors.red)
                      : null,
                  onTap: () async {
                    // وضع الإشعار كمقروء
                    await _notificationService.markAsRead(notification.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
