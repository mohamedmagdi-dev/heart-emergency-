import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../data/models/request_model.dart';

class PatientRequestsPage extends ConsumerWidget {
  const PatientRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتـي'), // My requests
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('يرجى تسجيل الدخول'));
          }

          final stream = FirestoreService().getPatientRequests(user.uid);

          return StreamBuilder<List<RequestModel>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('حدث خطأ: ${snapshot.error}'));
              }
              final requests = snapshot.data ?? const [];
              if (requests.isEmpty) {
                return const Center(child: Text('لا توجد طلبات حتى الآن'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final r = requests[index];
                  return _RequestTile(request: r);
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
}

class _RequestTile extends StatelessWidget {
  final RequestModel request;
  const _RequestTile({required this.request});

  Color _statusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.accepted:
        return Colors.green;
      case RequestStatus.rejected:
        return Colors.red;
      case RequestStatus.completed:
        return Colors.blueGrey;
    }
  }

  String _statusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'قيد الانتظار';
      case RequestStatus.accepted:
        return 'تم القبول';
      case RequestStatus.rejected:
        return 'تم الرفض';
      case RequestStatus.completed:
        return 'مكتمل';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(request.status).withOpacity(0.15),
          child: Icon(Icons.local_hospital, color: _statusColor(request.status)),
        ),
        title: Text('طلب للطبيب: ${request.doctorId ?? '-'}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('الحالة: ${_statusText(request.status)}'),
            const SizedBox(height: 2),
            Text('التاريخ: ${_formatDate(request.createdAt)}'),
          ],
        ),
        trailing: Text(
          request.urgencyLevel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}


