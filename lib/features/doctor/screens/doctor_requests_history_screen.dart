import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/request_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/request_service.dart';

class DoctorRequestsHistoryScreen extends ConsumerWidget {
  const DoctorRequestsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('تاريخ الطلبات'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('غير مسجل الدخول'));
          final service = RequestService();
          return StreamBuilder<List<RequestModel>>(
            stream: service.getDoctorEmergencyRequests(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('خطأ: ${snapshot.error}'));
              }
              final requests = snapshot.data ?? [];
              if (requests.isEmpty) {
                return const Center(child: Text('لا يوجد تاريخ للطلبات'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final r = requests[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _statusChip(r.status),
                            const Spacer(),
                            Text(
                              _formatDateTime(r.createdAt),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          r.symptoms,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الأولوية: ${r.urgencyLevel}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '(${r.patientLocation.latitude.toStringAsFixed(4)}, ${r.patientLocation.longitude.toStringAsFixed(4)})',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  Widget _statusChip(RequestStatus status) {
    Color color;
    String text;
    switch (status) {
      case RequestStatus.price_set:
        color=Colors.blue;
        text="تم تحديد السعر";
      case RequestStatus.pending:
        color = Colors.orange;
        text = 'معلق';
        break;
      case RequestStatus.accepted:
        color = Colors.blue;
        text = 'مقبول';
        break;
      case RequestStatus.rejected:
        color = Colors.red;
        text = 'مرفوض';
        break;
      case RequestStatus.completed:
        color = Colors.green;
        text = 'مكتمل';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
