//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../providers/auth_provider.dart';
//
// class DoctorNotificationsScreen extends ConsumerStatefulWidget {
//   const DoctorNotificationsScreen({super.key});
//
//   @override
//   ConsumerState<DoctorNotificationsScreen> createState() =>
//       _DoctorNotificationsScreenState();
// }
//
// class _DoctorNotificationsScreenState
//     extends ConsumerState<DoctorNotificationsScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   Future<void> markAllAsRead(String userId) async {
//     final unread = await _firestore
//         .collection('notifications')
//         .where('userId', isEqualTo: userId)
//         .where('read', isEqualTo: false)
//         .get();
//
//     for (var doc in unread.docs) {
//       await doc.reference.update({'read': true});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final userAsync = ref.watch(currentUserDataProvider);
//
//     return userAsync.when(
//       data: (user) {
//         if (user == null) {
//           return const Scaffold(
//             body: Center(child: Text('لم يتم تسجيل الدخول')),
//           );
//         }
//
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('الإشعارات'),
//             actions: [
//               TextButton(
//                 onPressed: () => markAllAsRead(user.uid),
//                 child: const Text(
//                   'تحديد الكل كمقروء',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//             bottom: TabBar(
//               controller: _tabController,
//               tabs: const [
//                 Tab(text: 'غير مقروءة'),
//                 Tab(text: 'مقروءة'),
//               ],
//             ),
//           ),
//           body: TabBarView(
//             controller: _tabController,
//             children: [
//               _buildNotificationsList(user.uid, read: false),
//               _buildNotificationsList(user.uid, read: true),
//             ],
//           ),
//         );
//       },
//       loading: () =>
//       const Scaffold(body: Center(child: CircularProgressIndicator())),
//       error: (error, stack) =>
//           Scaffold(body: Center(child: Text('خطأ: $error'))),
//     );
//   }
//
//   Widget _buildNotificationsList(String userId, {required bool read}) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore
//           .collection('notifications')
//           .where('userId', isEqualTo: userId)
//           .where('read', isEqualTo: read)
//           .orderBy('createdAt', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return Center(
//             child: Text(read ? 'لا توجد إشعارات مقروءة' : 'لا توجد إشعارات جديدة'),
//           );
//         }
//
//         final notifications = snapshot.data!.docs;
//
//         return ListView.builder(
//           itemCount: notifications.length,
//           itemBuilder: (context, index) {
//             final notif = notifications[index].data() as Map<String, dynamic>;
//
//             return ListTile(
//               leading: Icon(
//                 notif['read'] == true
//                     ? Icons.mark_email_read
//                     : Icons.notifications_active,
//                 color: notif['read'] == true ? Colors.grey : Colors.blue,
//               ),
//               title: Text(notif['title'] ?? 'بدون عنوان'),
//               subtitle: Text(notif['body'] ?? ''),
//               trailing: Text(
//                 (notif['createdAt'] as Timestamp)
//                     .toDate()
//                     .toLocal()
//                     .toString()
//                     .split('.')[0],
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//               onTap: () {
//                 if (notif['read'] == false) {
//                   snapshot.data!.docs[index].reference.update({'read': true});
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
import '../../../providers/auth_provider.dart';
import '../../../services/fcm_service.dart';


class DoctorNotificationsScreen extends ConsumerStatefulWidget {
  const DoctorNotificationsScreen({super.key});

  @override
  ConsumerState<DoctorNotificationsScreen> createState() =>
      _DoctorNotificationsScreenState();
}

class _DoctorNotificationsScreenState
    extends ConsumerState<DoctorNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FCMService? _fcmService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = ref.read(currentUserDataProvider).value;
      if (user != null) {
        _fcmService = FCMService();
        await _fcmService!.initialize();
      }
    });
  }

  Future<void> markAllAsRead(String userId) async {
    final unread = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in unread.docs) {
      await doc.reference.update({'read': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const Scaffold(body: Center(child: Text('لم يتم تسجيل الدخول')));

        return Scaffold(
          appBar: AppBar(
            title: const Text('الإشعارات'),
            actions: [
              TextButton(
                onPressed: () => markAllAsRead(user.uid),
                child: const Text('تحديد الكل كمقروء', style: TextStyle(color: Colors.white)),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'غير مقروءة'), Tab(text: 'مقروءة')],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationsList(user.uid, read: false),
              _buildNotificationsList(user.uid, read: true),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('خطأ: $error'))),
    );
  }

  Widget _buildNotificationsList(String userId, {required bool read}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: read)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Center(child: Text(read ? 'لا توجد إشعارات مقروءة' : 'لا توجد إشعارات جديدة'));

        final notifications = snapshot.data!.docs;
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notif = notifications[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: Icon(notif['read'] == true ? Icons.mark_email_read : Icons.notifications_active,
                  color: notif['read'] == true ? Colors.grey : Colors.blue),
              title: Text(notif['title'] ?? 'بدون عنوان'),
              subtitle: Text(notif['body'] ?? ''),
              trailing: Text(
                  (notif['createdAt'] as Timestamp).toDate().toLocal().toString().split('.')[0],
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              onTap: () {
                if (notif['read'] == false) notifications[index].reference.update({'read': true});
              },
            );
          },
        );
      },
    );
  }
}
