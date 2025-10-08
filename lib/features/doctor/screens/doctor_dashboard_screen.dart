// Doctor Dashboard with real-time Firestore integration



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/request_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/fcm_service.dart';
import '../../../services/request_service.dart';
import '../../../services/rating_service.dart';
import '../../../data/models/rating_model.dart';
import '../../../providers/auth_provider.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FCMService _fcmService = FCMService();
  final RequestService _requestService = RequestService();
  final RatingService _ratingService = RatingService();
  bool _showReviews = true;

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('المستخدم غير مسجل الدخول'));
          }

          // Check if doctor is verified
          if (user.verified != true) {
            return _buildVerificationPendingScreen();
          }

          return _buildDashboard(user);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('خطأ في تحميل البيانات: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(currentUserDataProvider),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationPendingScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.pending,
                  size: 64,
                  color: Colors.orange[600],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'في انتظار التحقق',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'حسابك قيد المراجعة من قبل الإدارة. سيتم إشعارك عند اكتمال عملية التحقق.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final authController = ref.read(authControllerProvider);
                  await authController.signOut();
                  if (mounted) context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(UserModel user) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(currentUserDataProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(user),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatusCard(user),
                  const SizedBox(height: 16),
                  _buildStatsCards(user),
                  const SizedBox(height: 16),
                  _buildPendingRequests(user.uid),
                  const SizedBox(height: 16),
                  _buildPatientRequestsSection(user.uid),
                  const SizedBox(height: 16),
                  _buildWalletCard(user),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                  const SizedBox(height: 16),
                  _buildLatestReviewSection(user.uid),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF059669), Color(0xFF10B981)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: user.profileImage != null
                            ? NetworkImage(user.profileImage!)
                            : null,
                        child: user.profileImage == null
                            ? const Icon(Icons.person,
                                size: 30, color: Color(0xFF059669))
                            : null,
                      ),
                      if (user.verified == true)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'د. ${user.name}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (user.specialization != null)
                          Text(
                            user.specialization!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        if (user.rating != null)
                          Row(
                            children: [
                              Icon(Icons.star,
                                  size: 16, color: Colors.amber[300]),
                              const SizedBox(width: 4),
                              Text(
                                user.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.notifications,
                     size: 30,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/doctor/settings'),
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medical_services,
                color: Colors.green, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الحالة',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: (user.available ?? true)
                            ? Colors.green
                            : Colors
                                .red, // FIXED: Dynamic color based on availability
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (user.available ?? true)
                          ? 'متاح للطوارئ'
                          : 'غير متاح', // FIXED: Dynamic text
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: (user.available ?? true)
                            ? Colors.green
                            : Colors.red, // FIXED: Dynamic color
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // FIXED: Availability toggle switch
          Switch(
            value: user.available ?? true,
            activeColor: Colors.green,
            onChanged: (value) async {
              try {
                await _firestoreService.updateDoctorAvailability(
                    user.uid, value);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                          ? 'تم تفعيل استقبال الطوارئ'
                          : 'تم إيقاف استقبال الطوارئ'),
                      backgroundColor: value ? Colors.green : Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ في تحديث الحالة: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'التقييم',
            value: user.rating?.toStringAsFixed(1) ?? '0.0',
            icon: Icons.star,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'المراجعات',
            value: '${user.reviews?.length ?? 0}',
            icon: Icons.rate_review,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StreamBuilder<List<RequestModel>>(
            stream: _firestoreService.getDoctorRequests(user.uid),
            builder: (context, snapshot) {
              final completedRequests = snapshot.data
                      ?.where((r) => r.status == RequestStatus.completed)
                      .length ??
                  0;
              return _buildStatCard(
                title: 'الطلبات المكتملة',
                value: '$completedRequests',
                icon: Icons.check_circle,
                color: Colors.green,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequests(String doctorId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'الطلبات المعلقة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/doctor/requests'),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<RequestModel>>(
          stream: _requestService.getDoctorEmergencyRequests(doctorId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              // FIXED: Better error handling for Firestore index issues
              final errorMessage = snapshot.error.toString();
              final isIndexError =
                  errorMessage.contains('failed-precondition') ||
                      errorMessage.contains('requires an index');

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isIndexError
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      isIndexError ? Icons.build : Icons.error,
                      color: isIndexError ? Colors.orange : Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isIndexError
                          ? 'جاري إعداد قاعدة البيانات...'
                          : 'خطأ في تحميل الطلبات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            isIndexError ? Colors.orange[700] : Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isIndexError
                          ? 'يرجى الانتظار بضع دقائق حتى يتم إعداد النظام بالكامل.'
                          : 'خطأ: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (isIndexError) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Trigger a rebuild to retry
                          setState(() {});
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }

            final requests = snapshot.data ?? [];

            if (requests.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد طلبات معلقة',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.take(3).length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return _buildRequestCard(request);
              },
            );
          },
        ),
      ],
    );
  }

  //
  //
  Widget _buildRequestCard(RequestModel request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pending, size: 16, color: Colors.orange),
                    SizedBox(width: 4),
                    Text(
                      'في الانتظار',
                      style: TextStyle(
                        color: Colors.orange,
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
          // Patient info will be fetched separately
          FutureBuilder<UserModel?>(
            future: _firestoreService.getUser(request.patientId),
            builder: (context, patientSnapshot) {
              final patient = patientSnapshot.data;
              return Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    patient?.name ?? 'مريض',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              );
            },
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
          const SizedBox(height: 16),
          if (request.status == RequestStatus.pending) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptRequest(request),
                    icon: const Icon(Icons.check),
                    label: const Text('قبول'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectRequest(request),
                    icon: const Icon(Icons.close),
                    label: const Text('رفض'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final lat = request.patientLocation.latitude;
                      final lng = request.patientLocation.longitude;
                      final patient =
                          await _firestoreService.getUser(request.patientId);
                      if (!mounted) return;
                      context.push(
                          '/doctor/emergency/map?lat=$lat&lng=$lng&name=${Uri.encodeComponent(patient?.name ?? 'مريض')}');
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('الخريطة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (request.status == RequestStatus.accepted ||
              request.status == RequestStatus.completed) ...[
            Row(
              children: [
                if (request.status == RequestStatus.accepted)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _completeRequest(request),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('إكمال الطلب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (request.status == RequestStatus.completed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _ratePatient(request),
                      icon: const Icon(Icons.star),
                      label: const Text('تقييم المريض'),
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
        ],
      ),
    );
  }

  Widget _buildWalletCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'رصيد المحفظة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/doctor/wallet'),
                child: const Text('إدارة المحفظة'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${user.walletBalance.toStringAsFixed(2)} ${user.currency.name}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => context.push('/doctor/wallet/withdraw'),
                icon: const Icon(Icons.money),
                label: const Text('سحب الأموال'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'طلبات المرضى',
        'icon': Icons.assignment,
        'color': Colors.blue,
        'route': '/doctor/requests',
      },
      {
        'title': 'تاريخ الطلبات',
        'icon': Icons.history,
        'color': Colors.orange,
        'route': '/doctor/requests-history',
      },
      {
        'title': 'الملف الشخصي',
        'icon': Icons.person,
        'color': Colors.purple,
        'route': '/doctor/profile',
      },
      {
        'title': 'المراجعات',
        'icon': Icons.star_rate,
        'color': Colors.amber,
        'route': '/doctor/reviews',
      },
      {
        'title': 'الإحصائيات',
        'icon': Icons.analytics,
        'color': Colors.green,
        'route': '/doctor/analytics',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الخدمات السريعة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    final route = action['route'] as String;
                    if (route == '/doctor/reviews') {
                      final currentUser = ref
                          .read(currentUserDataProvider)
                          .maybeWhen(data: (u) => u, orElse: () => null);
                      if (currentUser != null) {
                        context.push(route, extra: currentUser.uid);
                      } else {
                        context.push(route);
                      }
                    } else {
                      context.push(route);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (action['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            action['icon'] as IconData,
                            size: 32,
                            color: action['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          action['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLatestReviewSection(String doctorId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'المراجعات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => setState(() => _showReviews = !_showReviews),
              icon: Icon(_showReviews ? Icons.expand_less : Icons.expand_more),
              tooltip: _showReviews ? 'إخفاء' : 'إظهار',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!_showReviews)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.reviews, color: Colors.grey),
                const SizedBox(width: 8),
                const Expanded(child: Text('المراجعات مخفية')),
                TextButton(
                  onPressed: () => setState(() => _showReviews = true),
                  child: const Text('إظهار'),
                ),
              ],
            ),
          )
        else
          StreamBuilder<List<RatingModel>>(
            stream: _ratingService.getRatingsByUser(doctorId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final ratings = snapshot.data ?? [];
              if (ratings.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text('لا توجد مراجعات بعد',
                      style: TextStyle(color: Colors.grey)),
                );
              }
              final r =
                  ratings.first; // latest (stream ordered desc by createdAt)
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star,
                                color: Colors.amber[600], size: 18),
                            const SizedBox(width: 4),
                            Text('${r.rating}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(
                              _formatDateTime(r.createdAt),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        if (r.comment != null && r.comment!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(r.comment!,
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () =>
                          context.push('/doctor/reviews', extra: doctorId),
                      child: const Text('عرض الكل'),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildPatientRequestsSection(String doctorId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'طلبات المرضى',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/doctor/requests'),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<RequestModel>>(
          stream: _firestoreService.getDoctorRequests(doctorId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('خطأ: ${snapshot.error}');
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: const Text('لا توجد طلبات',
                    style: TextStyle(color: Colors.grey)),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length > 3 ? 3 : items.length,
              itemBuilder: (context, index) {
                final r = items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _statusChip(r.status),
                          const Spacer(),
                          Text(_formatDateTime(r.createdAt),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(r.symptoms,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                              '(${r.patientLocation.latitude.toStringAsFixed(4)}, ${r.patientLocation.longitude.toStringAsFixed(4)})',
                              style: const TextStyle(color: Colors.grey)),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              final lat = r.patientLocation.latitude;
                              final lng = r.patientLocation.longitude;
                              context.push(
                                  '/doctor/emergency/map?lat=$lat&lng=$lng&name=${Uri.encodeComponent('مريض')}');
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('إظهار المسار'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _statusChip(RequestStatus status) {
    Color color;
    String text;
    switch (status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Future<void> _acceptRequest(RequestModel request) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قبول الطلب'),
        content: const Text('هل أنت متأكد من قبول هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('قبول', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _requestService.acceptEmergencyRequest(request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم قبول الطلب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في قبول الطلب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest(RequestModel request) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الطلب'),
        content: const Text('هل أنت متأكد من رفض هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('رفض', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _requestService.rejectEmergencyRequest(request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفض الطلب'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في رفض الطلب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeRequest(RequestModel request) async {
    try {
      await _requestService.completeEmergencyRequest(request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إكمال الطلب بنجاح'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إكمال الطلب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _ratePatient(RequestModel request) async {
    try {
      final patient = await _requestService.getUserDetails(request.patientId);
      if (patient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم العثور على بيانات المريض'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // context.push(
      //   '/doctor/rate-patient',
      //   extra: patient,
      //   queryParameters: {'requestId': request.id},
      // );
      context.push(
        '/doctor/rate-patient?requestId=${request.id}',
        extra: patient,
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
