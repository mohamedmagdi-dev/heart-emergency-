//
//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../notifications/notification_request_service.dart';
//
// class PatientNotificationsScreen extends StatelessWidget {
//   final String userId;
//
//   const PatientNotificationsScreen({super.key, required this.userId});
//
//   @override
//   Widget build(BuildContext context) {
//     final NotificationRequestService _notificationService = NotificationRequestService();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('الإشعارات'),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF1E40AF),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.done_all),
//             tooltip: 'تحديد الكل كمقروء',
//             onPressed: () async {
//               await _notificationService.markAllAsRead(userId);
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _notificationService.getUserNotifications(userId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text('حدث خطأ أثناء تحميل الإشعارات: ${snapshot.error}'));
//           }
//
//           final notifications = snapshot.data?.docs ?? [];
//
//           if (notifications.isEmpty) {
//             return const Center(
//               child: Text(
//                 'لا توجد إشعارات حالياً',
//                 style: TextStyle(color: Colors.grey, fontSize: 16),
//               ),
//             );
//           }
//
//           return ListView.builder(
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final notification = notifications[index];
//               final data = notification.data() as Map<String, dynamic>;
//
//               return Card(
//                 color: data['read'] == true ? Colors.grey.shade200 : Colors.white,
//                 margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 elevation: 2,
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: Colors.blueAccent.withOpacity(0.1),
//                     child: const Icon(Icons.notifications, color: Colors.blueAccent),
//                   ),
//                   title: Text(
//                     data['title'] ?? 'إشعار',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(data['body'] ?? ''),
//                   trailing: data['read'] == false
//                       ? const Icon(Icons.fiber_new, color: Colors.red)
//                       : null,
//                   onTap: () async {
//                     if (data['read'] == false) {
//                       await _notificationService.markAsRead(notification.id);
//                     }
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../notifications/notification_request_service.dart';
//
// class PatientNotificationsScreen extends StatelessWidget {
//   final String userId;
//   const PatientNotificationsScreen({super.key, required this.userId});
//
//   @override
//   Widget build(BuildContext context) {
//     final NotificationRequestService _notificationService = NotificationRequestService();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('الإشعارات'),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF1E40AF),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.done_all),
//             tooltip: 'تحديد الكل كمقروء',
//             onPressed: () async {
//               await _notificationService.markAllAsRead(userId);
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _notificationService.getUserNotifications(userId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text('حدث خطأ أثناء تحميل الإشعارات: ${snapshot.error}'));
//           }
//
//           final notifications = snapshot.data?.docs ?? [];
//
//           if (notifications.isEmpty) {
//             return const Center(
//               child: Text(
//                 'لا توجد إشعارات حالياً',
//                 style: TextStyle(color: Colors.grey, fontSize: 16),
//               ),
//             );
//           }
//
//           return ListView.builder(
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final notification = notifications[index];
//               final data = notification.data() as Map<String, dynamic>;
//
//               return InkWell(
//                 onTap: () async {
//                   // ✅ When patient taps, mark notification as read
//                   if (data['read'] == false) {
//                     await notification.reference.update({'read': true});
//                   }
//                 },
//                 child: Card(
//                   color: data['read'] == true ? Colors.grey.shade200 : Colors.white,
//                   margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   elevation: 2,
//                   child: ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: Colors.blueAccent.withOpacity(0.1),
//                       child: const Icon(Icons.notifications, color: Colors.blueAccent),
//                     ),
//                     title: Text(
//                       data['title'] ?? 'إشعار',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text(data['body'] ?? ''),
//                     trailing: data['read'] == false
//                         ? const Icon(Icons.fiber_new, color: Colors.red)
//                         : null,
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// In patient_notifications_screen.dart
// In patient_notifications_screen.dart
// In patient_notifications_screen.dart

// In patient_notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../notifications/notification_request_service.dart';

class PatientNotificationsScreen extends ConsumerStatefulWidget {
  final String userId;
  const PatientNotificationsScreen({super.key, required this.userId});

  @override
  ConsumerState<PatientNotificationsScreen> createState() =>
      _PatientNotificationsScreenState();
}

class _PatientNotificationsScreenState extends ConsumerState<PatientNotificationsScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final NotificationRequestService _notificationService = NotificationRequestService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: const Color(0xFF1E40AF),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'تحديد الكل كمقروء',
            onPressed: () async {
              await _notificationService.markAllAsRead(widget.userId);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'غير مقروءة'),
            Tab(text: 'مقروءة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // التاب الأول بيعرض الإشعارات غير المقروءة
          _buildNotificationsList(widget.userId, read: false),
          // التاب التاني بيعرض الإشعارات المقروءة
          _buildNotificationsList(widget.userId, read: true),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(String userId, {required bool read}) {
    return StreamBuilder<QuerySnapshot>(
      // --- ✅ التعديل هنا: بننده على الدالة الجديدة وبنبعتلها الفلتر ---
      stream: _notificationService.getUserNotifications(userId, read: read),
      // ------------------------------------------------------------------
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              read ? 'لا توجد إشعارات مقروءة' : 'لا توجد إشعارات جديدة',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        final notifications = snapshot.data!.docs;
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notificationDoc = notifications[index];
            final data = notificationDoc.data() as Map<String, dynamic>;

            return ListTile(
              leading: Icon(
                read ? Icons.mark_email_read_outlined : Icons.notifications_active,
                color: read ? Colors.grey : Theme.of(context).primaryColor,
              ),
              title: Text(
                data['title'] ?? 'إشعار',
                style: TextStyle(fontWeight: read ? FontWeight.normal : FontWeight.bold),
              ),
              subtitle: Text(data['body'] ?? ''),
              onTap: () {
                // لما تدوس، لو الإشعار غير مقروء، غير حالته في الفايرستور
                // الـ StreamBuilder هيحس بالتغيير وهينقله للتاب التاني لوحده
                if (!read) {
                  notificationDoc.reference.update({'read': true});
                }
              },
            );
          },
        );
      },
    );
  }
}