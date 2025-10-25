// Doctor Verification Pending Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart'; // FIXED: Added for UserModel

class DoctorVerificationPendingScreen extends ConsumerWidget {
  const DoctorVerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIXED: Listen for real-time verification status changes
    final userDataAsync = ref.watch(currentUserDataProvider);
    
    return userDataAsync.when(
      data: (userData) {
        // If user is verified, redirect to dashboard
        if (userData?.verified == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/doctor/dashboard');
          });
        }
        
        // If user is explicitly rejected (verified = false and has been reviewed)
        if (userData?.verified == false && userData?.createdAt != null) {
          // Check if enough time has passed to consider it reviewed (not just new account)
          final daysSinceCreation = DateTime.now().difference(userData!.createdAt).inDays;
          if (daysSinceCreation > 0) {
            return _buildRejectedScreen(context, ref);
          }
        }
        
        return _buildPendingScreen(context, ref, userData);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('خطأ في تحميل البيانات: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingScreen(BuildContext context, WidgetRef ref, UserModel? userData) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.pending_actions,
                  size: 100,
                  color: Colors.orange,
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'حسابك قيد المراجعة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Janna',
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'تم إنشاء حسابك بنجاح!\n\nيتم حالياً مراجعة بياناتك من قبل فريق الإدارة.\n\nسيتم إشعارك عند الموافقة على حسابك.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontFamily: 'Janna',
                  ),
                ),
                const SizedBox(height: 32),
                
                const Card(
                  color: Colors.blue,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'عادة ما تستغرق عملية المراجعة من 24-48 ساعة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Janna',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                ElevatedButton.icon(
                  onPressed: () async {
                    final authController = ref.read(authControllerProvider);
                    await authController.signOut();
                    if (context.mounted) {
                      context.go('/');
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextButton.icon(
                  onPressed: () {
                    // TODO: Contact support
                  },
                  icon: const Icon(Icons.support_agent),
                  label: const Text('التواصل مع الدعم الفني'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FIXED: Screen for rejected doctors
  Widget _buildRejectedScreen(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cancel,
                  size: 100,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'تم رفض طلب التحقق',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Janna',
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'نأسف لإبلاغك أنه تم رفض طلب التحقق من حسابك.\n\nيرجى مراجعة البيانات المرسلة والتأكد من صحتها، ثم إعادة التقديم.\n\nيمكنك التواصل مع الدعم الفني للحصول على مزيد من المعلومات.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontFamily: 'Janna',
                  ),
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final authController = ref.read(authControllerProvider);
                          await authController.signOut();
                          if (context.mounted) {
                            context.go('/doctor/auth');
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة التقديم'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final authController = ref.read(authControllerProvider);
                          await authController.signOut();
                          if (context.mounted) {
                            context.go('/');
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('تسجيل الخروج'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                TextButton.icon(
                  onPressed: () {
                    // TODO: Contact support
                  },
                  icon: const Icon(Icons.support_agent),
                  label: const Text('التواصل مع الدعم الفني'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

