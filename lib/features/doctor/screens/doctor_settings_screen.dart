// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../../core/cubits/theme_cubit.dart';
// import '../../../data/models/user_model.dart';
// import '../../../providers/auth_provider.dart';
// import '../../../services/firestore_service.dart';
//
// class DoctorSettingsScreen extends ConsumerWidget {
//   const DoctorSettingsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final themeCubit = ref.watch(themeCubitProvider);
//     // current user stream
//     final currentUserAsync = ref.watch(currentUserDataProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('إعدادات الطبيب'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => _showLogoutDialog(context, ref),
//           ),
//         ],
//       ),
//       body: currentUserAsync.when(
//         data: (user) => user == null
//             ? const Center(child: Text('المستخدم غير مسجل الدخول'))
//             : _buildSettingsBody(context, ref, user, themeCubit),
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, s) => Center(child: Text('خطأ: $e')),
//       ),
//     );
//   }
//
//   Widget _buildSettingsBody(BuildContext context, WidgetRef ref, UserModel user, ThemeCubit themeCubit) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.person),
//             title: Text('الاسم: ${user.name}'),
//           ),
//           ListTile(
//             leading: const Icon(Icons.email),
//             title: Text('البريد: ${user.email}'),
//           ),
//           ListTile(
//             leading: const Icon(Icons.currency_exchange),
//             title: Text('العملة الحالية: ${user.currency.name}'),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () => _showCurrencyDialog(context, ref, user),
//           ),
//           ListTile(
//             leading: const Icon(Icons.brightness_6),
//             title: const Text('الوضع الليلي'),
//             trailing: BlocBuilder<ThemeCubit, ThemeState>(
//               bloc: themeCubit,
//               builder: (context, state) {
//                 return Switch(
//                   value: state.isDark,
//                   onChanged: (v) async {
//                     await themeCubit.setDark(v);
//                   },
//                 );
//               },
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.lock),
//             title: const Text('تغيير كلمة المرور'),
//             onTap: () => _showChangePasswordDialog(context, ref),
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text('إعدادات إضافية'),
//             onTap: () {},
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: () => _showLogoutDialog(context, ref),
//             icon: const Icon(Icons.logout),
//             label: const Text('تسجيل الخروج'),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showCurrencyDialog(BuildContext context, WidgetRef ref, UserModel user) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('اختر العملة'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: Currency.values.map((currency) {
//             return ListTile(
//               title: Text(currency.name),
//               onTap: () async {
//                 try {
//                   final firestore = FirestoreService();
//                   await firestore.updateUserCurrency(user.uid, currency);
//                   ref.invalidate(currentUserDataProvider);
//                   if (context.mounted) Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('تم تحديث العملة بنجاح')),
//                   );
//                 } catch (e) {
//                   if (context.mounted) Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('فشل في تحديث العملة: $e')),
//                   );
//                 }
//               },
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
//   void _showLogoutDialog(BuildContext context, WidgetRef ref) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تأكيد تسجيل الخروج'),
//         content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () async {
//               Navigator.pop(context);
//               try {
//                 final authController = ref.read(authControllerProvider);
//                 await authController.signOut();
//                 if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
//               } catch (e) {
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تسجيل الخروج: $e')));
//                 }
//               }
//             },
//             child: const Text('تسجيل الخروج'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
//     final oldPassController = TextEditingController();
//     final newPassController = TextEditingController();
//     final confirmController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('تغيير كلمة المرور'),
//         content: Form(
//           key: formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // NOTE: Firebase requires recent authentication to change sensitive data.
//               // You may need to re-authenticate the user before calling updatePassword.
//               // Here we collect only the new password (and optional current password for reauth flows).
//
//               TextFormField(
//                 controller: oldPassController,
//                 decoration: const InputDecoration(labelText: 'كلمة المرور الحالية (إن وُجدت)'),
//                 obscureText: true,
//               ),
//               TextFormField(
//                 controller: newPassController,
//                 decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة'),
//                 obscureText: true,
//                 validator: (v) {
//                   if (v == null || v.trim().length < 6) return 'يجب أن تكون كلمة المرور >= 6 أحرف';
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: confirmController,
//                 decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور الجديدة'),
//                 obscureText: true,
//                 validator: (v) {
//                   if (v != newPassController.text) return 'كلمتا المرور غير متطابقتين';
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
//           ElevatedButton(
//             onPressed: () async {
//               if (!formKey.currentState!.validate()) return;
//               final newPass = newPassController.text.trim();
//               Navigator.pop(context);
//
//               try {
//                 final authController = ref.read(authControllerProvider);
//                 await authController.changePassword(newPass);
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')));
//                 }
//               } catch (e) {
//                 // If Firebase requires recent login, show a helpful message
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('فشل تغيير كلمة المرور: $e. قد تحتاج لإعادة تسجيل الدخول.')),
//                   );
//                 }
//               }
//             },
//             child: const Text('حفظ'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../core/cubits/theme_cubit.dart';
// import '../../../core/cubits/theme_state.dart';
//
// class DoctorSettingsScreen extends StatelessWidget {
//   const DoctorSettingsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final themeCubit = context.read<ThemeCubit>();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('إعدادات الطبيب'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => _showLogoutDialog(context),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.brightness_6),
//               title: const Text('الوضع الليلي'),
//               trailing: BlocBuilder<ThemeCubit, ThemeState>(
//                 builder: (context, state) {
//                   return Switch(
//                     value: state.isDark,
//                     onChanged: (v) async => await themeCubit.setDark(v),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () => _showLogoutDialog(context),
//               icon: const Icon(Icons.logout),
//               label: const Text('تسجيل الخروج'),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('تأكيد تسجيل الخروج'),
//         content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               Navigator.pop(context);
//               // your logout logic here
//             },
//             child: const Text('تسجيل الخروج'),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/cubits/theme_cubit.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';

class DoctorSettingsScreen extends ConsumerWidget {
  const DoctorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeCubit = context.read<ThemeCubit>();
    final authController = ref.read(authControllerProvider);
    final currentUserAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الطبيب'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, ref, authController),
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('المستخدم غير مسجل الدخول'));
          }
          return _buildSettingsContent(
            context,
            ref,
            user,
            themeCubit,
            authController,
          );
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

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    ThemeCubit themeCubit,
    AuthController authController,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileSection(context, user),
          const SizedBox(height: 24),
          _buildAppearanceSection(context, themeCubit),
          const SizedBox(height: 24),
          _buildCurrencySection(context, ref, user),
          const SizedBox(height: 24),
          _buildAccountSection(context, ref, authController),
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
            Text(
              'الملف الشخصي',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  backgroundImage: user.profileImage != null
                      ? NetworkImage(user.profileImage!)
                      : null,
                  child: user.profileImage == null
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        )
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
            Text(
              'المظهر',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
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

  Widget _buildCurrencySection(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'العملة',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('العملة الحالية'),
              subtitle: Text(user.currency.name),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showCurrencyDialog(context, ref, user),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    WidgetRef ref,
    AuthController authController,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الحساب',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('تغيير كلمة المرور'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _changePassword(context),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _showLogoutDialog(context, ref, authController),
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر العملة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Currency.values.map((currency) {
            return ListTile(
              title: Text(currency.name),
              trailing: user.currency == currency
                  ? const Icon(Icons.check)
                  : null,
              onTap: () async {
                try {
                  final firestore = FirestoreService();
                  await firestore.updateUserCurrency(user.uid, currency);
                  ref.invalidate(currentUserDataProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث العملة بنجاح')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ في تحديث العملة: $e')),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _changePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: const Text('هذه الميزة قيد التطوير'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
    AuthController authController,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // ✅ Step 1: Sign out from Firebase
              await authController.signOut();

              // ✅ Step 2: Clear local cache (optional if you have one)
              // await ref.read(localStorageServiceProvider).clearUserData();

              // ✅ Step 3: Go to FirebaseWelcomeScreen
              if (context.mounted) {
                context.go('/'); // <-- replace with your welcome route path
              }
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
