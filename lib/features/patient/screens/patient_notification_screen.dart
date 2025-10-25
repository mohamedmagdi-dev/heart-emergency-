
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../notifications/notification_request_service.dart';
//
// class PatientNotificationsScreen extends ConsumerStatefulWidget {
//   final String userId;
//   const PatientNotificationsScreen({super.key, required this.userId});
//
//   @override
//   ConsumerState<PatientNotificationsScreen> createState() =>
//       _PatientNotificationsScreenState();
// }
//
// class _PatientNotificationsScreenState extends ConsumerState<PatientNotificationsScreen>
//     with SingleTickerProviderStateMixin {
//
//   late TabController _tabController;
//   final NotificationRequestService _notificationService = NotificationRequestService();
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('الإشعارات'),
//         backgroundColor: const Color(0xFF1E40AF),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.done_all),
//             tooltip: 'تحديد الكل كمقروء',
//             onPressed: () async {
//               await _notificationService.markAllAsRead(widget.userId);
//             },
//           ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           tabs: const [
//             Tab(text: 'غير مقروءة'),
//             Tab(text: 'مقروءة'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           // التاب الأول بيعرض الإشعارات غير المقروءة
//           _buildNotificationsList(widget.userId, read: false),
//           // التاب التاني بيعرض الإشعارات المقروءة
//           _buildNotificationsList(widget.userId, read: true),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNotificationsList(String userId, {required bool read}) {
//     return StreamBuilder<QuerySnapshot>(
//       // --- ✅ التعديل هنا: بننده على الدالة الجديدة وبنبعتلها الفلتر ---
//       stream: _notificationService.getUserNotifications(userId, read: read),
//       // ------------------------------------------------------------------
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return Center(
//             child: Text(
//               read ? 'لا توجد إشعارات مقروءة' : 'لا توجد إشعارات جديدة',
//               style: const TextStyle(color: Colors.grey, fontSize: 16),
//             ),
//           );
//         }
//
//         final notifications = snapshot.data!.docs;
//         return ListView.builder(
//           itemCount: notifications.length,
//           itemBuilder: (context, index) {
//             final notificationDoc = notifications[index];
//             final data = notificationDoc.data() as Map<String, dynamic>;
//
//             return ListTile(
//               leading: Icon(
//                 read ? Icons.mark_email_read_outlined : Icons.notifications_active,
//                 color: read ? Colors.grey : Theme.of(context).primaryColor,
//               ),
//               title: Text(
//                 data['title'] ?? 'إشعار',
//                 style: TextStyle(fontWeight: read ? FontWeight.normal : FontWeight.bold),
//               ),
//               subtitle: Text(data['body'] ?? ''),
//               onTap: () {
//                 // لما تدوس، لو الإشعار غير مقروء، غير حالته في الفايرستور
//                 // الـ StreamBuilder هيحس بالتغيير وهينقله للتاب التاني لوحده
//                 if (!read) {
//                   notificationDoc.reference.update({'read': true});
//                 }
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../notifications/notification_request_service.dart';
import '../../../services/request_service.dart';
import '../../../data/models/request_model.dart';


class PatientNotificationsScreen extends ConsumerStatefulWidget {
  final String userId;
  const PatientNotificationsScreen({super.key, required this.userId});

  @override
  ConsumerState<PatientNotificationsScreen> createState() =>
      _PatientNotificationsScreenState();
}

class _PatientNotificationsScreenState
    extends ConsumerState<PatientNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationRequestService _notificationService =
      NotificationRequestService();
  final RequestService _requestService = RequestService();

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColor.darkPrimary, AppColor.darkSecondary]
                  : [AppColor.lightPrimary, AppColor.lightSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'الإشعارات',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            tooltip: 'تحديد الكل كمقروء',
            onPressed: () async {
              await _notificationService.markAllAsRead(widget.userId);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'غير مقروءة'),
            Tab(text: 'مقروءة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(widget.userId, read: false),
          _buildNotificationsList(widget.userId, read: true),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(String userId, {required bool read}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: _notificationService.getUserNotifications(userId, read: read),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              read ? 'لا توجد إشعارات مقروءة' : 'لا توجد إشعارات جديدة',
              style: theme.textTheme.bodyLarge!.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          );
        }

        final notifications = snapshot.data!.docs;

        return ListView.builder(
          itemCount: notifications.length,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemBuilder: (context, index) {
            final notificationDoc = notifications[index];
            final data = notificationDoc.data() as Map<String, dynamic>;

            // 🎨 خلفية الكارت
            final Color tileColor = read
                ? (isDark
                ? AppColor.darkSurface.withOpacity(0.8)
                : Colors.white)
                : (isDark
                ? const Color(0xFF1E3A8A)
                : const Color(0xFFE3F2FD));

            // 🎨 لون حدود الكارت
            final Color borderColor = read
                ? Colors.transparent
                : (isDark
                ? AppColor.darkSecondary
                : AppColor.lightSecondary.withOpacity(0.7));

            // 🎨 لون الأيقونة حسب الحالة
            final Color iconColor = read
                ? (isDark
                ? AppColor.lightSecondary
                : AppColor.lightPrimary) // 🔹 أزرق فاتح بدل الرمادي
                : Colors.white;

            final Color circleColor = read
                ? (isDark
                ? AppColor.darkSecondary.withOpacity(0.25)
                : AppColor.lightSecondary.withOpacity(0.15))
                : AppColor.containerButtonColor2;

            return Card(
              elevation: 3,
              color: tileColor,
              shadowColor:
              read ? Colors.black12 : AppColor.lightPrimary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: borderColor, width: read ? 0 : 1.2),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: circleColor,
                  child: Icon(
                    read
                        ? Icons.mark_email_read_outlined
                        : Icons.notifications_active_rounded,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                title: Text(
                  data['title'] ?? 'إشعار',
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: read ? FontWeight.w500 : FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    data['body'] ?? '',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.75),
                    ),
                  ),
                ),
                onTap: () {
                  if (!read) {
                    notificationDoc.reference.update({'read': true});
                  }
                },
                trailing: _buildNotificationTrailing(data, notificationDoc),
              ),
            );
          },
        );
      },
    );
  }

  Widget? _buildNotificationTrailing(Map<String, dynamic> data, QueryDocumentSnapshot notificationDoc) {
    final String? type = data['type'] as String?;
    
    // Show info icon for price_set notifications (no actions for patients)
    if (type == 'price_set') {
      return const Icon(
        Icons.info_outline,
        color: Colors.blue,
        size: 20,
      );
    }
    
    return null;
  }
}
