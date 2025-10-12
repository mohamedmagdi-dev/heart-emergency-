// // Patient Settings Screen
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import '../../../core/cubits/theme_cubit.dart';
// import '../../../core/cubits/theme_state.dart';
// import '../../../data/models/user_model.dart';
// import '../../../services/firestore_service.dart';
// import '../../../providers/auth_provider.dart';
//
// class PatientSettingsScreen extends ConsumerStatefulWidget {
//   const PatientSettingsScreen({super.key});
//
//   @override
//   ConsumerState<PatientSettingsScreen> createState() => _PatientSettingsScreenState();
// }
//
// class _PatientSettingsScreenState extends ConsumerState<PatientSettingsScreen> {
//   final FirestoreService _firestoreService = FirestoreService();
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUserAsync = ref.watch(currentUserDataProvider);
//     final themeCubit = context.read<ThemeCubit>();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('إعدادات المريض'),
//         backgroundColor: Colors.indigo[600],
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             onPressed: () => _showLogoutDialog(),
//             icon: const Icon(Icons.logout),
//             tooltip: 'تسجيل الخروج',
//           ),
//         ],
//       ),
//       body: currentUserAsync.when(
//         data: (user) {
//           if (user == null) {
//             return const Center(child: Text('المستخدم غير مسجل الدخول'));
//           }
//           return _buildSettingsContent(user, themeCubit);
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, stack) => Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error, size: 64, color: Colors.red),
//               const SizedBox(height: 16),
//               Text('خطأ في تحميل البيانات: $error'),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () => ref.refresh(currentUserDataProvider),
//                 child: const Text('إعادة المحاولة'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSettingsContent(UserModel user, ThemeCubit themeCubit) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildProfileSection(user),
//           const SizedBox(height: 24),
//           _buildAppearanceSection(themeCubit),
//           const SizedBox(height: 24),
//           _buildCurrencySection(user),
//           const SizedBox(height: 24),
//           // _buildNotificationSection(),
//           // const SizedBox(height: 24),
//           // _buildPrivacySection(),
//           // const SizedBox(height: 24),
//           _buildAccountSection(),
//           const SizedBox(height: 24),
//           _buildSupportSection(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProfileSection(UserModel user) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//            Text(
//             'الملف الشخصي',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 40,
//                 backgroundColor: Colors.indigo[100],
//                 backgroundImage: user.profileImage != null
//                     ? NetworkImage(user.profileImage!)
//                     : null,
//                 child: user.profileImage == null
//                     ? const Icon(Icons.person, size: 40, color: Colors.indigo)
//                     : null,
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       user.name,
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       user.email,
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'رقم الهوية: ${user.uid.substring(0, 8)}...',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // IconButton(
//               //   onPressed: () => _editProfile(user),
//               //   icon: const Icon(Icons.edit),
//               //   tooltip: 'تعديل الملف الشخصي',
//               // ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAppearanceSection(ThemeCubit themeCubit) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'المظهر',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           BlocBuilder<ThemeCubit, ThemeState>(
//             builder: (context, state) {
//               return ListTile(
//                 leading: const Icon(Icons.brightness_6),
//                 title: const Text('الوضع الليلي'),
//                 subtitle: const Text('تفعيل الوضع المظلم'),
//                 trailing: Switch(
//                   value: state.isDark,
//                   onChanged: (value) async => await themeCubit.setDark(value),
//                 ),
//                 contentPadding: EdgeInsets.zero,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCurrencySection(UserModel user) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'العملة',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ListTile(
//             leading: const Icon(Icons.currency_exchange),
//             title: const Text('العملة الحالية'),
//             subtitle: Text('${user.currency.name}'),
//             trailing: const Icon(Icons.arrow_forward_ios),
//             onTap: () => _showCurrencyDialog(user),
//             contentPadding: EdgeInsets.zero,
//           ),
//         ],
//       ),
//     );
//   }
//   //
//   // Widget _buildNotificationSection() {
//   //   return Container(
//   //     padding: const EdgeInsets.all(20),
//   //     decoration: BoxDecoration(
//   //       color: Colors.white,
//   //       borderRadius: BorderRadius.circular(16),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: Colors.black.withOpacity(0.1),
//   //           blurRadius: 10,
//   //           offset: const Offset(0, 2),
//   //         ),
//   //       ],
//   //     ),
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         const Text(
//   //           'الإشعارات',
//   //           style: TextStyle(
//   //             fontSize: 18,
//   //             fontWeight: FontWeight.bold,
//   //           ),
//   //         ),
//   //         const SizedBox(height: 16),
//   //         ListTile(
//   //           leading: const Icon(Icons.notifications),
//   //           title: const Text('إشعارات الطوارئ'),
//   //           subtitle: const Text('تلقي إشعارات فورية للطوارئ'),
//   //           trailing: Switch(
//   //             value: true, // This should be connected to actual notification settings
//   //             onChanged: (value) {
//   //               // Handle notification toggle
//   //             },
//   //           ),
//   //           contentPadding: EdgeInsets.zero,
//   //         ),
//   //         ListTile(
//   //           leading: const Icon(Icons.message),
//   //           title: const Text('إشعارات الرسائل'),
//   //           subtitle: const Text('تلقي إشعارات الرسائل من الأطباء'),
//   //           trailing: Switch(
//   //             value: true, // This should be connected to actual notification settings
//   //             onChanged: (value) {
//   //               // Handle notification toggle
//   //             },
//   //           ),
//   //           contentPadding: EdgeInsets.zero,
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   // Widget _buildPrivacySection() {
//   //   return Container(
//   //     padding: const EdgeInsets.all(20),
//   //     decoration: BoxDecoration(
//   //       color: Colors.white,
//   //       borderRadius: BorderRadius.circular(16),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: Colors.black.withOpacity(0.1),
//   //           blurRadius: 10,
//   //           offset: const Offset(0, 2),
//   //         ),
//   //       ],
//   //     ),
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         const Text(
//   //           'الخصوصية',
//   //           style: TextStyle(
//   //             fontSize: 18,
//   //             fontWeight: FontWeight.bold,
//   //           ),
//   //         ),
//   //         const SizedBox(height: 16),
//   //         ListTile(
//   //           leading: const Icon(Icons.location_off),
//   //           title: const Text('إخفاء الموقع'),
//   //           subtitle: const Text('عدم مشاركة موقعك مع الأطباء'),
//   //           trailing: Switch(
//   //             value: false, // This should be connected to actual privacy settings
//   //             onChanged: (value) {
//   //               // Handle privacy toggle
//   //             },
//   //           ),
//   //           contentPadding: EdgeInsets.zero,
//   //         ),
//   //         ListTile(
//   //           leading: const Icon(Icons.visibility_off),
//   //           title: const Text('الملف الشخصي الخاص'),
//   //           subtitle: const Text('إخفاء معلوماتك الشخصية'),
//   //           trailing: Switch(
//   //             value: false, // This should be connected to actual privacy settings
//   //             onChanged: (value) {
//   //               // Handle privacy toggle
//   //             },
//   //           ),
//   //           contentPadding: EdgeInsets.zero,
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   Widget _buildAccountSection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'الحساب',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           // ListTile(
//           //   leading: const Icon(Icons.lock),
//           //   title: const Text('تغيير كلمة المرور'),
//           //   trailing: const Icon(Icons.arrow_forward_ios),
//           //   onTap: () => _changePassword(),
//           //   contentPadding: EdgeInsets.zero,
//           // ),
//           ListTile(
//             leading: const Icon(Icons.delete),
//             title: const Text('حذف الحساب'),
//             subtitle: const Text('حذف الحساب نهائياً'),
//             trailing: const Icon(Icons.arrow_forward_ios),
//             onTap: () => _deleteAccount(),
//             contentPadding: EdgeInsets.zero,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSupportSection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'الدعم',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           // ListTile(
//           //   leading: const Icon(Icons.help),
//           //   title: const Text('مركز المساعدة'),
//           //   trailing: const Icon(Icons.arrow_forward_ios),
//           //   onTap: () => _openHelpCenter(),
//           //   contentPadding: EdgeInsets.zero,
//           // ),
//           // ListTile(
//           //   leading: const Icon(Icons.contact_support),
//           //   title: const Text('اتصل بنا'),
//           //   trailing: const Icon(Icons.arrow_forward_ios),
//           //   onTap: () => _contactSupport(),
//           //   contentPadding: EdgeInsets.zero,
//           // ),
//           ListTile(
//             leading: const Icon(Icons.info),
//             title: const Text('حول التطبيق'),
//             trailing: const Icon(Icons.arrow_forward_ios),
//             onTap: () => _showAboutApp(),
//             contentPadding: EdgeInsets.zero,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // void _editProfile(UserModel user) {
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) => AlertDialog(
//   //       title: const Text('تعديل الملف الشخصي'),
//   //       content: const Text('هذه الميزة قيد التطوير'),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(context),
//   //           child: const Text('إغلاق'),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   void _showCurrencyDialog(UserModel user) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('اختر العملة'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: Currency.values.map((currency) {
//             return ListTile(
//               title: Text(currency.name),
//               trailing: user.currency == currency ? const Icon(Icons.check) : null,
//               onTap: () async {
//                 try {
//                   await _firestoreService.updateUserCurrency(user.uid, currency);
//                   ref.invalidate(currentUserDataProvider);
//                   if (mounted) {
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('تم تحديث العملة بنجاح')),
//                     );
//                   }
//                 } catch (e) {
//                   if (mounted) {
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('خطأ في تحديث العملة: $e')),
//                     );
//                   }
//                 }
//               },
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
//   // void _changePassword() {
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) => AlertDialog(
//   //       title: const Text('تغيير كلمة المرور'),
//   //       content: const Text('هذه الميزة قيد التطوير'),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(context),
//   //           child: const Text('إغلاق'),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   void _deleteAccount() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('حذف الحساب'),
//         content: const Text('هل أنت متأكد من رغبتك في حذف الحساب نهائياً؟ لا يمكن التراجع عن هذا الإجراء.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('هذه الميزة قيد التطوير'),
//                   backgroundColor: Colors.orange,
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('حذف', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _openHelpCenter() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('مركز المساعدة'),
//         content: const Text('هذه الميزة قيد التطوير'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إغلاق'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _contactSupport() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('اتصل بنا'),
//         content: const Text('هذه الميزة قيد التطوير'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إغلاق'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showAboutApp() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('حول التطبيق'),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('من قلب الطوارئ'),
//             SizedBox(height: 8),
//             Text('الإصدار: 1.0.0'),
//             SizedBox(height: 8),
//             Text('تطبيق طوارئ طبية متقدم'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إغلاق'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تسجيل الخروج'),
//         content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               try {
//                 final authController = ref.read(authControllerProvider);
//                 await authController.signOut();
//                 if (mounted) {
//                   context.go('/');
//                 }
//               } catch (e) {
//                 if (mounted) {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('خطأ في تسجيل الخروج: $e')),
//                   );
//                 }
//               }
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }
// Patient Settings Screen
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/cubits/theme_cubit.dart';

import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_service.dart';

class PatientSettingsScreen extends ConsumerStatefulWidget {
  const PatientSettingsScreen({super.key});

  @override
  ConsumerState<PatientSettingsScreen> createState() =>
      _PatientSettingsScreenState();
}

class _PatientSettingsScreenState extends ConsumerState<PatientSettingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserDataProvider);
    final themeCubit = context.read<ThemeCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات المريض'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(),
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('المستخدم غير مسجل الدخول'));
          }
          return _buildSettingsContent(user, themeCubit);
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

  Widget _buildSettingsContent(UserModel user, ThemeCubit themeCubit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileSection(context, user),
          const SizedBox(height: 24),
          _buildAppearanceSection(context, themeCubit),
          const SizedBox(height: 24),
          _buildCurrencySection(context, user),
          const SizedBox(height: 24),
          _buildAccountSection(),
          const SizedBox(height: 24),
          _buildSupportSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الملف الشخصي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
                      user.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'رقم الهوية: ${user.uid.substring(0, 8)}...',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildAppearanceSection(BuildContext context, ThemeCubit themeCubit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المظهر',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<ThemeCubit, ThemeData>(
            builder: (context, state) {
              return ListTile(
                leading: Icon(
                  Icons.brightness_6,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('الوضع الليلي'),
                subtitle: const Text('تفعيل الوضع المظلم'),
                trailing: Switch(
                  value: themeCubit.isDark,
                  onChanged: (value) async => await themeCubit.toggleTheme(value),
                ),
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ],
      ),
    );
  }


  // Widget _buildAppearanceSection(BuildContext context,ThemeCubit themeCubit) {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).colorScheme.surface,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Theme.of(context).shadowColor.withOpacity(0.1),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'المظهر',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //             color: Theme.of(context).colorScheme.onSurface,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         BlocBuilder<ThemeCubit, ThemeState>(
  //           builder: (context, state) {
  //             return ListTile(
  //               leading: Icon(Icons.brightness_6, color: Theme.of(context).colorScheme.primary),
  //               title: const Text('الوضع الليلي'),
  //               subtitle: const Text('تفعيل الوضع المظلم'),
  //               trailing: Switch(
  //                 value: state.isDark,
  //                 onChanged: (value) async => await themeCubit.setDark(value),
  //               ),
  //               contentPadding: EdgeInsets.zero,
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCurrencySection(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'العملة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.currency_exchange, color: Theme.of(context).colorScheme.primary),
            title: const Text('العملة الحالية'),
            subtitle: Text(user.currency.name),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showCurrencyDialog(user),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الحساب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('حذف الحساب'),
            subtitle: const Text('حذف الحساب نهائياً'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _deleteAccount(),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الدعم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
            title: const Text('حول التطبيق'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showAboutApp(),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(UserModel user) {
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
                  await _firestoreService.updateUserCurrency(
                    user.uid,
                    currency,
                  );
                  ref.invalidate(currentUserDataProvider);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث العملة بنجاح')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
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

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف الحساب نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('هذه الميزة قيد التطوير'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حول التطبيق'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('من قلب الطوارئ'),
            SizedBox(height: 8),
            Text('الإصدار: 1.0.0'),
            SizedBox(height: 8),
            Text('تطبيق طوارئ طبية متقدم'),
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
}
