import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('يرجى تسجيل الدخول'));
          }

          final stream = FirebaseFirestore.instance
              .collection('notifications')
              .doc(user.uid)
              .collection('userNotifications')
              .orderBy('createdAt', descending: true)
              .snapshots();

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('حدث خطأ: ${snapshot.error}'));
              }
              final docs = snapshot.data?.docs ?? const [];
              if (docs.isEmpty) {
                return const Center(child: Text('لا توجد إشعارات'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final title = (data['title'] ?? '').toString();
                  final body = (data['body'] ?? '').toString();
                  final type = (data['type'] ?? 'general').toString();
                  final read = data['read'] == true;
                  return ListTile(
                    leading: Icon(
                      _iconForType(type),
                      color: read ? Colors.grey : Colors.blue,
                    ),
                    title: Text(title, style: TextStyle(fontWeight: read ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Text(body),
                    onTap: () async {
                      // Mark as read
                      await docs[index].reference.update({'read': true}).catchError((_){});
                    },
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('تعذر تحميل المستخدم')),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'new_request':
        return Icons.inbox;
      case 'request_accepted':
        return Icons.check_circle;
      case 'request_rejected':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }
}


