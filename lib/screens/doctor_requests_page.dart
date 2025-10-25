import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../services/request_service.dart';
import '../data/models/request_model.dart';

class DoctorRequestsPage extends ConsumerWidget {
  const DoctorRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات المرضى'),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('يرجى تسجيل الدخول'));
          }
          final stream = FirestoreService().getDoctorRequests(user.uid);
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
                return const Center(child: Text('لا توجد طلبات حالياً'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final r = requests[index];
                  return _DoctorRequestTile(request: r);
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

class _DoctorRequestTile extends StatelessWidget {
  final RequestModel request;
  const _DoctorRequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == RequestStatus.pending;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Expanded(child: Text('مريض: ${request.patientId}')),
                Chip(
                  label: Text(_statusText(request.status)),
                  backgroundColor: _statusColor(request.status).withOpacity(0.15),
                  labelStyle: TextStyle(color: _statusColor(request.status)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 6),
                Text(_formatDate(request.createdAt)),
              ],
            ),
            const SizedBox(height: 12),
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await RequestService().respondToRequest(request.id, request.patientId, true);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('قبول'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await RequestService().respondToRequest(request.id, request.patientId, false);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('رفض'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

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
        case RequestStatus.price_set:
        return Colors.purple;
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
      case RequestStatus.price_set:
        return"تم تحديد السعر";
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}


