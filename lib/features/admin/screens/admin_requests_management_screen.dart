import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/request_model.dart';
import '../../../data/models/user_model.dart';
import '../../../services/firestore_service.dart';

class AdminRequestsManagementScreen extends StatefulWidget {
  const AdminRequestsManagementScreen({super.key});

  @override
  State<AdminRequestsManagementScreen> createState() => _AdminRequestsManagementScreenState();
}

class _AdminRequestsManagementScreenState extends State<AdminRequestsManagementScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('إدارة الطلبات'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'في الانتظار'),
            Tab(text: 'تم القبول'),
            Tab(text: 'مرفوضة'),
          ],
        ),
      ),
      body: StreamBuilder<List<RequestModel>>(
        stream: _firestoreService.getAllRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }
          final requests = snapshot.data ?? [];
          return TabBarView(
            controller: _tabController,
            children: [
              _buildRequestsList(requests),
              _buildRequestsList(requests.where((r) => r.status == RequestStatus.pending).toList()),
              _buildRequestsList(requests.where((r) => r.status == RequestStatus.accepted).toList()),
              _buildRequestsList(requests.where((r) => r.status == RequestStatus.rejected).toList()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestsList(List<RequestModel> items) {
    if (items.isEmpty) {
      return const Center(child: Text('لا توجد طلبات'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final r = items[index];
        return _buildRequestCard(r);
      },
    );
  }

  Widget _buildRequestCard(RequestModel r) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    switch (r.status) {
      case RequestStatus.price_set:
        statusColor =Colors.blue;
        statusText="تم تحديد السعر";
        statusIcon=Icons.attach_money;
      case RequestStatus.pending:
        statusColor = Colors.orange;
        statusText = 'في الانتظار';
        statusIcon = Icons.pending;
        break;
      case RequestStatus.accepted:
        statusColor = Colors.blue;
        statusText = 'تم القبول';
        statusIcon = Icons.check_circle;
        break;
      case RequestStatus.rejected:
        statusColor = Colors.red;
        statusText = 'مرفوضة';
        statusIcon = Icons.cancel;
        break;
      case RequestStatus.completed:
        statusColor = Colors.green;
        statusText = 'مكتمل';
        statusIcon = Icons.check_circle_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 6),
                    Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Spacer(),
              Text(_formatDateTime(r.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              FutureBuilder<UserModel?>(
                future: _firestoreService.getUser(r.patientId),
                builder: (context, snapshot) => Text(snapshot.data?.name ?? 'مريض',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              if (r.doctorId != null) ...[
                const SizedBox(width: 12),
                const Icon(Icons.local_hospital, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                FutureBuilder<UserModel?>(
                  future: _firestoreService.getUser(r.doctorId!),
                  builder: (context, snapshot) => Text(snapshot.data?.name ?? 'طبيب',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text('(${r.patientLocation.latitude.toStringAsFixed(4)}, ${r.patientLocation.longitude.toStringAsFixed(4)})',
                    style: const TextStyle(color: Colors.grey)),
              ),
              if (r.price != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.attach_money, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text('${r.price!.toStringAsFixed(2)} SAR',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ],
          ),
          if (r.etaMinutes != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.orange),
                const SizedBox(width: 6),
                Text('الزمن المقدر للوصول: ${r.etaMinutes} دقيقة'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) return 'منذ ${difference.inDays} يوم';
    if (difference.inHours > 0) return 'منذ ${difference.inHours} ساعة';
    if (difference.inMinutes > 0) return 'منذ ${difference.inMinutes} دقيقة';
    return 'الآن';
  }
}


