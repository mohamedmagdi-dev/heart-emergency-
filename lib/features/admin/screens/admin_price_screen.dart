import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/request_model.dart';
import '../../../data/models/user_model.dart';
import '../../../services/firestore_service.dart';
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
class PricesScreen extends ConsumerStatefulWidget {
  const PricesScreen({super.key});

  @override
  ConsumerState<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends ConsumerState<PricesScreen> {
  String _filter = 'all'; // all, today, week, month

  @override
  Widget build(BuildContext context) {
    // هتجيب الـ FirestoreService مباشرة من الـ ref
    final firestoreService = ref.read(firestoreServiceProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('أسعار الخدمات'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('الكل')),
              const PopupMenuItem(value: 'today', child: Text('اليوم')),
              const PopupMenuItem(value: 'week', child: Text('أسبوع')),
              const PopupMenuItem(value: 'month', child: Text('شهر')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Cards
          _buildPriceStatistics(firestoreService),
          // Prices List
          Expanded(child: _buildPricesList(firestoreService)),
        ],
      ),
    );
  }

  Widget _buildPriceStatistics(FirestoreService firestoreService) {
    return StreamBuilder<List<RequestModel>>(
      stream: firestoreService.getAllRequests(),
      builder: (context, snapshot) {
        final allRequests = snapshot.data ?? [];
        final pricedRequests = allRequests.where((r) => r.price != null && r.price! > 0).toList();

        // Apply filter
        final filteredRequests = _applyFilter(pricedRequests);

        final totalRevenue = filteredRequests.fold<double>(0, (sum, r) => sum + (r.price ?? 0));
        final averagePrice = filteredRequests.isNotEmpty ? totalRevenue / filteredRequests.length : 0;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '${filteredRequests.length}',
                  'الخدمات',
                  Icons.assignment,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '${totalRevenue.toStringAsFixed(0)}',
                  'إجمالي SAR',
                  Icons.monetization_on,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '${averagePrice.toStringAsFixed(0)}',
                  'متوسط السعر',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  List<RequestModel> _applyFilter(List<RequestModel> requests) {
    final now = DateTime.now();

    switch (_filter) {
      case 'today':
        return requests.where((r) =>
        r.createdAt.year == now.year &&
            r.createdAt.month == now.month &&
            r.createdAt.day == now.day
        ).toList();
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return requests.where((r) => r.createdAt.isAfter(weekAgo)).toList();
      case 'month':
        final monthAgo = now.subtract(const Duration(days: 30));
        return requests.where((r) => r.createdAt.isAfter(monthAgo)).toList();
      default:
        return requests;
    }
  }

  Widget _buildPricesList(FirestoreService firestoreService) {
    return StreamBuilder<List<RequestModel>>(
      stream: firestoreService.getAllRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allRequests = snapshot.data ?? [];
        final pricedRequests = allRequests.where((r) => r.price != null && r.price! > 0).toList();
        final filteredRequests = _applyFilter(pricedRequests);

        if (filteredRequests.isEmpty) {
          return _buildEmptyState();
        }

        // Sort by date (newest first)
        filteredRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredRequests.length,
          itemBuilder: (context, index) {
            final request = filteredRequests[index];
            return _buildPriceItem(request, firestoreService);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.money_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'لا توجد أسعار مسجلة',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'تغيير الفلتر قد يساعد في العثور على نتائج',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(RequestModel request, FirestoreService firestoreService) {
    return FutureBuilder<UserModel?>(
      future: firestoreService.getUser(request.doctorId ?? ''),
      builder: (context, userSnapshot) {
        final doctor = userSnapshot.data;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Doctor info and Price
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: doctor?.profileImage != null
                        ? NetworkImage(doctor!.profileImage!)
                        : null,
                    child: doctor?.profileImage == null
                        ? Text(doctor?.name.substring(0, 1) ?? '?')
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'د. ${doctor?.name ?? 'غير معروف'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (doctor?.specialization != null)
                          Text(
                            doctor!.specialization!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green[100]!),
                    ),
                    child: Text(
                      '${(request.price ?? 0).toStringAsFixed(2)} SAR',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Symptoms
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الأعراض:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.symptoms,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Footer with date and status
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatFullDate(request.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(request.status),
                      style: TextStyle(
                        color: _getStatusColor(request.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) { case RequestStatus.price_set: // ✅ أضف دي
    // كود الحالة price_set
   return Colors.purple;

      break;

      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.accepted:
        return Colors.blue;
      case RequestStatus.rejected:
        return Colors.red;
      case RequestStatus.completed:
        return Colors.green;
    }
  }

  String _getStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.price_set: // ✅ أضف دي
      // كود الحالة price_set
       return"تم تحديد السعر";

      case RequestStatus.pending:
        return 'قيد الانتظار';
      case RequestStatus.accepted:
        return 'مقبول';
      case RequestStatus.rejected:
        return 'مرفوض';
      case RequestStatus.completed:
        return 'مكتمل';
    }
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}