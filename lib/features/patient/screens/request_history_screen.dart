// Request History Screen for Patients
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/request_model.dart';
import '../../../data/models/user_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/request_service.dart';
import '../../../providers/auth_provider.dart';

class RequestHistoryScreen extends ConsumerStatefulWidget {
  const RequestHistoryScreen({super.key});

  @override
  ConsumerState<RequestHistoryScreen> createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends ConsumerState<RequestHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final RequestService _requestService = RequestService();
  List<RequestModel> _requests = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadRequestHistory();
  }

  Future<void> _loadRequestHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final currentUserAsync = ref.read(currentUserDataProvider);
      final currentUser = currentUserAsync.when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );

      if (currentUser == null) {
        setState(() {
          _error = 'المستخدم غير مسجل الدخول';
          _isLoading = false;
        });
        return;
      }

      // Get all requests for this patient
      final requests = await _firestoreService.getPatientRequests(currentUser.uid).first;
      
      // Sort by creation date (most recent first)
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<RequestModel> get _filteredRequests {
    switch (_selectedFilter) {
      case 'pending':
        return _requests.where((r) => r.status == RequestStatus.pending).toList();
      case 'accepted':
        return _requests.where((r) => r.status == RequestStatus.accepted).toList();
      case 'completed':
        return _requests.where((r) => r.status == RequestStatus.completed).toList();
      case 'rejected':
        return _requests.where((r) => r.status == RequestStatus.rejected).toList();
      default:
        return _requests;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تاريخ الطلبات'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadRequestHistory,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'الكل'},
      {'key': 'pending', 'label': 'معلق'},
      {'key': 'accepted', 'label': 'مقبول'},
      {'key': 'completed', 'label': 'مكتمل'},
      {'key': 'rejected', 'label': 'مرفوض'},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['key']!;
                });
              },
              selectedColor: Colors.purple[100],
              checkmarkColor: Colors.purple[800],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل تاريخ الطلبات...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'خطأ في تحميل البيانات',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRequestHistory,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final filteredRequests = _filteredRequests;

    if (filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'all' ? 'لا توجد طلبات' : 'لا توجد طلبات بهذا الحالة',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'لم تقم بإنشاء أي طلبات بعد',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/patient/emergency-request'),
              child: const Text('إنشاء طلب جديد'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequestHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredRequests.length,
        itemBuilder: (context, index) {
          final request = filteredRequests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(RequestModel request) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (request.status) {
      case RequestStatus.pending:
        statusColor = Colors.orange;
        statusText = 'في الانتظار';
        statusIcon = Icons.pending;
        break;
      case RequestStatus.accepted:
        statusColor = Colors.blue;
        statusText = 'مقبول';
        statusIcon = Icons.check_circle;
        break;
      case RequestStatus.rejected:
        statusColor = Colors.red;
        statusText = 'مرفوض';
        statusIcon = Icons.cancel;
        break;
      case RequestStatus.completed:
        statusColor = Colors.green;
        statusText = 'مكتمل';
        statusIcon = Icons.check_circle_outline;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showRequestDetails(request),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDateTime(request.createdAt),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'الأعراض: ${request.symptoms}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'خط العرض: ${request.patientLocation.latitude.toStringAsFixed(4)}, خط الطول: ${request.patientLocation.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                if (request.doctorId != null) ...[
                  const SizedBox(height: 8),
                  FutureBuilder<UserModel?>(
                    future: _firestoreService.getUser(request.doctorId!),
                    builder: (context, snapshot) {
                      final doctor = snapshot.data;
                      return Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'الطبيب: ${doctor?.name ?? 'غير محدد'}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRequestDetails(request),
                        icon: const Icon(Icons.info),
                        label: const Text('التفاصيل'),
                      ),
                    ),
                    if (request.status == RequestStatus.completed && request.doctorId != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _rateDoctor(request),
                          icon: const Icon(Icons.star),
                          label: const Text('تقييم الطبيب'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRequestDetails(RequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الأعراض: ${request.symptoms}'),
            const SizedBox(height: 8),
            Text('الحالة: ${_getStatusText(request.status)}'),
            const SizedBox(height: 8),
            Text('تاريخ الإنشاء: ${_formatDateTime(request.createdAt)}'),
            if (request.doctorId != null) ...[
              const SizedBox(height: 8),
              FutureBuilder<UserModel?>(
                future: _firestoreService.getUser(request.doctorId!),
                builder: (context, snapshot) {
                  final doctor = snapshot.data;
                  return Text('الطبيب: ${doctor?.name ?? 'غير محدد'}');
                },
              ),
            ],
            const SizedBox(height: 8),
            Text('الموقع: ${request.patientLocation.latitude.toStringAsFixed(4)}, ${request.patientLocation.longitude.toStringAsFixed(4)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          if (request.status == RequestStatus.completed && request.doctorId != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _rateDoctor(request);
              },
              child: const Text('تقييم الطبيب'),
            ),
        ],
      ),
    );
  }

  Future<void> _rateDoctor(RequestModel request) async {
    try {
      final doctor = await _requestService.getUserDetails(request.doctorId!);
      if (doctor == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم العثور على بيانات الطبيب'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      context.push(
        '/patient/rate-doctor?requestId=${request.id}',
        extra: doctor,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في فتح صفحة التقييم: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'في الانتظار';
      case RequestStatus.accepted:
        return 'مقبول';
      case RequestStatus.rejected:
        return 'مرفوض';
      case RequestStatus.completed:
        return 'مكتمل';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
