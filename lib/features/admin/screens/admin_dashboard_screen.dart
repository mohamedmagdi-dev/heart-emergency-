import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heart_emergency/core/cubits/theme_cubit.dart';

import '../../../data/models/rating_model.dart';
import '../../../data/models/request_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/user_model.dart';
import '../../../features/common/widgets/local_file_viewer.dart'; // FIXED: Added for file viewing
import '../../../providers/auth_provider.dart';
import '../../../services/fcm_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/rating_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final FCMService _fcmService = FCMService();
  final RatingService _ratingService = RatingService();
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
    final currentUserAsync = ref.watch(currentUserDataProvider);
    final themeCubit = context.read<ThemeCubit>();
    return Scaffold(
      body: currentUserAsync.when(
        data: (user) {
          if (user == null || user.role != 'admin') {
            return const Center(child: Text('غير مصرح لك بالوصول'));
          }
          return _buildDashboard(themeCubit, user);
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

  Widget _buildDashboard(ThemeCubit themeCubit, UserModel user) {
    return Column(
      children: [
        _buildHeader(user),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildUsersTab(),
              _buildRatingsTab(),
              _buildSettingsTab(themeCubit, user),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(UserModel user) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? const Icon(
                        Icons.admin_panel_settings,
                        size: 25,
                        color: Color(0xFF7C3AED),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'لوحة تحكم الإدارة',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showLogoutDialog(),
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: const Color(0xFF7C3AED),
      unselectedLabelColor: Colors.grey,
      indicatorColor: const Color(0xFF7C3AED),
      tabs: const [
        Tab(icon: Icon(Icons.dashboard), text: 'نظرة عامة'),
        Tab(icon: Icon(Icons.people), text: 'المستخدمون'),
        Tab(icon: Icon(Icons.star), text: 'التقييمات'),
        Tab(icon: Icon(Icons.settings), text: 'الإعدادات'),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatsCards(),
          const SizedBox(height: 20),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return StreamBuilder<List<UserModel>>(
      stream: _firestoreService.getAllUsers(),
      builder: (context, usersSnapshot) {
        final users = usersSnapshot.data ?? [];
        final patients = users.where((u) => u.role == 'patient').length;
        final doctors = users.where((u) => u.role == 'doctor').length;
        final verifiedDoctors = users
            .where((u) => u.role == 'doctor' && u.verified == true)
            .length;

        return StreamBuilder<List<RequestModel>>(
          stream: _firestoreService.getAllRequests(),
          builder: (context, requestsSnapshot) {
            final requests = requestsSnapshot.data ?? [];
            final totalRequests = requests.length;

            return StreamBuilder<List<TransactionModel>>(
              stream: _firestoreService.getAllTransactions(),
              builder: (context, transactionsSnapshot) {
                final transactions = transactionsSnapshot.data ?? [];
                final totalRevenue = transactions
                    .where((t) => t.status == TransactionStatus.success)
                    .fold<double>(0, (sum, t) => sum + t.commission);

                return GridView.count(
                  childAspectRatio: MediaQuery.of(context).size.width < 400
                      ? 1
                      : 1.2,

                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  // childAspectRatio: 1.2,
                  children: [
                    _buildStatCard(
                      title: 'المرضى',
                      value: '$patients',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      title: 'الأطباء',
                      value: '$doctors',
                      icon: Icons.local_hospital,
                      color: Colors.green,
                      subtitle: '$verifiedDoctors محقق',
                    ),
                    _buildStatCard(
                      title: 'إجمالي الطلبات',
                      value: '$totalRequests',
                      icon: Icons.assignment,
                      color: Colors.orange,
                    ),
                    _buildStatCard(
                      title: 'إجمالي العمولات',
                      value: totalRevenue.toStringAsFixed(2),
                      icon: Icons.monetization_on,
                      color: Colors.purple,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
  //

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.all(constraints.maxWidth * 0.06),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: constraints.maxWidth * 0.2, color: color),
              SizedBox(height: constraints.maxHeight * 0.05),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.09,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: constraints.maxHeight * 0.02),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: constraints.maxHeight * 0.02),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.08,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
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
          const Text(
            'النشاط الأخير',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<RequestModel>>(
            stream: _firestoreService.getAllRequests(),
            builder: (context, snapshot) {
              final requests = snapshot.data ?? [];
              final recentRequests = requests.take(5).toList();

              if (recentRequests.isEmpty) {
                return const Center(child: Text('لا توجد أنشطة حديثة'));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentRequests.length,
                itemBuilder: (context, index) {
                  final request = recentRequests[index];
                  return _buildActivityItem(request);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(RequestModel request) {
    Color statusColor;
    IconData statusIcon;

    switch (request.status) {
      case RequestStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case RequestStatus.accepted:
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      case RequestStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case RequestStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلب طوارئ جديد',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatDateTime(request.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFF7C3AED),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF7C3AED),
            tabs: [
              Tab(text: 'المرضى'),
              Tab(text: 'الأطباء'),
            ],
          ),

          Expanded(
            child: TabBarView(
              children: [_buildPatientsTab(), _buildDoctorsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsTab() {
    return StreamBuilder<List<UserModel>>(
      stream: _firestoreService.getUsersByRole('patient'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('خطأ في تحميل المرضى: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final patients = snapshot.data ?? [];

        if (patients.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('لا يوجد مرضى مسجلين'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return _buildUserCard(patient);
          },
        );
      },
    );
  }

  Widget _buildDoctorsTab() {
    return StreamBuilder<List<UserModel>>(
      stream: _firestoreService.getUsersByRole('doctor'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('خطأ في تحميل الأطباء: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final doctors = snapshot.data ?? [];

        if (doctors.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_hospital_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text('لا يوجد أطباء مسجلين'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return _buildDoctorCard(doctor);
          },
        );
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              CircleAvatar(
                radius: 25,
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? Text(user.name.substring(0, 1))
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    // Text(
                    //   'رصيد المحفظة: ${user.walletBalance.toStringAsFixed(2)} ${user.currency.name}',
                    //   style: const TextStyle(
                    //     color: Colors.green,
                    //     fontSize: 14,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleUserAction(value, user),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Text('عرض التفاصيل'),
                  ),
                  const PopupMenuItem(
                    value: 'verify',
                    child: Text('توثيق الطبيب'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('حذف المستخدم'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(UserModel doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: doctor.profileImage != null
                        ? NetworkImage(doctor.profileImage!)
                        : null,
                    child: doctor.profileImage == null
                        ? Text(doctor.name.substring(0, 1))
                        : null,
                  ),
                  if (doctor.verified == true)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified,
                          size: 12,
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
                      'د. ${doctor.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (doctor.specialization != null)
                      Text(
                        doctor.specialization!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: doctor.verified == true
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            doctor.verified == true ? 'محقق' : 'غير محقق',
                            style: TextStyle(
                              color: doctor.verified == true
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (doctor.rating != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.star, size: 16, color: Colors.amber[600]),
                          const SizedBox(width: 4),
                          Text(
                            doctor.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleDoctorAction(value, doctor),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Text('عرض التفاصيل'),
                  ),
                  // FIXED: Added verification documents option
                  const PopupMenuItem(
                    value: 'view_documents',
                    child: Text('عرض ملفات التحقق'),
                  ),
                  PopupMenuItem(
                    value: doctor.verified == true ? 'unverify' : 'verify',
                    child: Text(
                      doctor.verified == true ? 'إلغاء التحقق' : 'تحقق',
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('حذف الطبيب'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(ThemeCubit themeCubit, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileSection(context, user),
          _buildAppearanceSection(context, themeCubit),
          _buildSettingsCard(
            title: 'إعدادات النظام',
            items: [
              _buildSettingItem(
                icon: Icons.percent,
                title: 'نسبة العمولة',
                subtitle: '12%',
                onTap: () => _showCommissionDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
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
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, UserModel user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الملف الشخصي', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF7C3AED).withOpacity(0.1),
                  backgroundImage: user.profileImage != null
                      ? NetworkImage(user.profileImage!)
                      : null,
                  child: user.profileImage == null
                      ? Icon(Icons.person, size: 40, color: Color(0xFF7C3AED))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'د. ${user.name}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      if (user.specialization != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.specialization!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, ThemeCubit themeCubit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المظهر', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            BlocBuilder<ThemeCubit, ThemeData>(
              builder: (context, state) {
                return ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('الوضع الليلي'),
                  subtitle: const Text('تفعيل الوضع المظلم'),
                  trailing: Switch(
                    value: themeCubit.isDark,
                    onChanged: (value) async => themeCubit.toggleTheme(value),
                  ),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF7C3AED)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _handleUserAction(String action, UserModel user) async {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      // verfiy notfication
      case 'verify':
        final newStatus = !(user.verified ?? false);
        await _firestoreService.updateDoctorVerification(user.uid, newStatus);

        // إرسال إشعار للدكتور
        await _firestoreService.sendNotification(
          userId: user.uid,
          title: newStatus ? 'تم توثيق حسابك ✅' : 'تم رفض توثيق حسابك ❌',
          body: newStatus
              ? 'مبروك! تم توثيق حسابك من قبل الإدارة ويمكنك استقبال المرضى الآن.'
              : 'نأسف، تم رفض طلب التوثيق. يرجى التواصل مع الدعم.',
          type: 'doctor_verification',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus ? 'تم توثيق الطبيب ✅' : 'تم إلغاء التوثيق ❌',
            ),
          ),
        );
        break;

      case 'delete':
        _showDeleteUserDialog(user);
        break;
    }
  }

  void _handleDoctorAction(String action, UserModel doctor) {
    switch (action) {
      case 'view':
        _showUserDetails(doctor);
        break;
      case 'view_documents': // FIXED: Added verification documents handling
        _showVerificationDocuments(doctor);
        break;
      case 'verify':
        _verifyDoctor(doctor, true);
        break;
      case 'unverify':
        _verifyDoctor(doctor, false);
        break;
      case 'delete':
        _showDeleteUserDialog(doctor);
        break;
    }
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('البريد الإلكتروني: ${user.email}'),
            Text('الهاتف: ${user.phone}'),
            Text('العملة: ${user.currency.name}'),
            // Text('رصيد المحفظة: ${user.walletBalance.toStringAsFixed(2)}'),
            Text('تاريخ التسجيل: ${_formatDateTime(user.createdAt)}'),
            if (user.role == 'doctor') ...[
              Text('التخصص: ${user.specialization ?? 'غير محدد'}'),
              Text('التحقق: ${user.verified == true ? 'محقق' : 'غير محقق'}'),
              if (user.rating != null)
                Text('التقييم: ${user.rating!.toStringAsFixed(1)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المستخدم "${user.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.deleteUser(user.uid);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف المستخدم بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ في حذف المستخدم: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyDoctor(UserModel doctor, bool verified) async {
    try {
      await _firestoreService.updateDoctorVerification(doctor.uid, verified);

      // Send notification to doctor
      if (doctor.fcmToken != null) {
        await _fcmService.sendNotificationToUser(
          token: doctor.fcmToken!,
          title: verified ? 'تم تحقق حسابك' : 'تم إلغاء تحقق حسابك',
          body: verified
              ? 'تم تحقق حسابك بنجاح. يمكنك الآن استقبال طلبات الطوارئ.'
              : 'تم إلغاء تحقق حسابك. يرجى مراجعة الإدارة.',
          data: {
            'type': 'verification_update',
            'verified': verified.toString(),
          },
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              verified ? 'تم تحقق الطبيب بنجاح' : 'تم إلغاء تحقق الطبيب',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث حالة التحقق: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCommissionDialog() {
    final controller = TextEditingController(text: '12');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحديث نسبة العمولة'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'نسبة العمولة (%)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement commission update
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تحديث نسبة العمولة'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final authController = ref.read(authControllerProvider);
                await authController.signOut();
                if (mounted) {
                  context.go('/');
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في تسجيل الخروج: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Show verification documents dialog
  void _showVerificationDocuments(UserModel doctor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ملفات التحقق - د. ${doctor.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Verification Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: doctor.verified == true
                      ? Colors.green[50]
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: doctor.verified == true
                        ? Colors.green[200]!
                        : Colors.orange[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      doctor.verified == true
                          ? Icons.check_circle
                          : Icons.pending,
                      color: doctor.verified == true
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      doctor.verified == true
                          ? 'طبيب محقق'
                          : 'في انتظار التحقق',
                      style: TextStyle(
                        color: doctor.verified == true
                            ? Colors.green[700]
                            : Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Certificates Section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الشهادات والمؤهلات:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (doctor.certificates != null &&
                          doctor.certificates!.isNotEmpty)
                        LocalFilesList(
                          filePaths: doctor.certificates!,
                          onFileSelected: (filePath) {
                            _showFullScreenImage(filePath);
                          },
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'لم يتم رفع أي شهادات بعد',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  if (doctor.verified != true)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _verifyDoctor(doctor, true);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('موافقة وتحقق'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (doctor.verified != true) const SizedBox(width: 12),
                  if (doctor.verified == true)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _verifyDoctor(doctor, false);
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('إلغاء التحقق'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (doctor.verified == true) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('إغلاق'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FIXED: Show full screen image viewer
  void _showFullScreenImage(String filePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: LocalFileViewer(filePath: filePath, fit: BoxFit.contain),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Ratings Statistics
          _buildRatingsStats(),
          const SizedBox(height: 20),
          // All Ratings List
          _buildAllRatingsList(),
        ],
      ),
    );
  }

  Widget _buildRatingsStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _ratingService.getRatingStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats =
            snapshot.data ??
            {
              'totalRatings': 0,
              'averageRating': 0.0,
              'ratingDistribution': <String, int>{},
              'recentRatings': 0,
            };

        return Row(
          children: [
            Expanded(
              child: _buildRatingStatCard(
                '${stats['totalRatings']}',
                'إجمالي التقييمات',
                Icons.star,
                Colors.amber[600]!,
                Colors.amber[100]!,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRatingStatCard(
                '${stats['averageRating'].toStringAsFixed(1)}',
                'متوسط التقييم',
                Icons.star_half,
                Colors.blue[600]!,
                Colors.blue[100]!,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRatingStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAllRatingsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'جميع التقييمات',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<RatingModel>>(
          stream: _ratingService.getAllRatings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'خطأ في تحميل التقييمات: ${snapshot.error}',
                  style: TextStyle(color: Colors.red[600]),
                ),
              );
            }

            final ratings = snapshot.data ?? [];

            if (ratings.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.star_border, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد تقييمات حتى الآن',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                final rating = ratings[index];
                return _buildRatingCard(rating);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRatingCard(RatingModel rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rating.role == 'doctor'
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rating.role == 'doctor' ? 'تقييم طبيب' : 'تقييم مريض',
                  style: TextStyle(
                    color: rating.role == 'doctor'
                        ? Colors.blue[700]
                        : Colors.green[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber[600],
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                rating.rating.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<UserModel?>(
            future: _ratingService.getUserDetails(rating.fromUserId),
            builder: (context, fromUserSnapshot) {
              final fromUser = fromUserSnapshot.data;
              return FutureBuilder<UserModel?>(
                future: _ratingService.getUserDetails(rating.toUserId),
                builder: (context, toUserSnapshot) {
                  final toUser = toUserSnapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'من: ${fromUser?.name ?? 'مستخدم غير معروف'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'إلى: ${toUser?.name ?? 'مستخدم غير معروف'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                rating.comment!,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            _formatDateTime(rating.createdAt),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
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
