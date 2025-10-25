// // // Firebase Patient Authentication Screen (Login & Signup)
// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:geolocator/geolocator.dart';
// // import '../../../providers/auth_provider.dart';
// // import '../../../core/utils/validators.dart';
// //
// // class FirebasePatientAuthScreen extends ConsumerStatefulWidget {
// //   const FirebasePatientAuthScreen({super.key});
// //   @override
// //   ConsumerState<FirebasePatientAuthScreen> createState() => _FirebasePatientAuthScreenState();
// // }
// //
// // class _FirebasePatientAuthScreenState extends ConsumerState<FirebasePatientAuthScreen> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _nameController = TextEditingController();
// //   final _emailController = TextEditingController();
// //   final _phoneController = TextEditingController();
// //   final _passwordController = TextEditingController();
// //   final _confirmPasswordController = TextEditingController();
// //   bool _isLogin = true;
// //   bool _isLoading = false;
// //   bool _obscurePassword = true;
// //   bool _obscureConfirmPassword = true;
// //   bool _usePhoneOnly = true; // 🟢 Added: Phone-only mode toggle
// //   Position? _currentPosition;
// //   String? _verificationId; // For Firebase Phone Auth OTP
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     if (!_isLogin) {
// //       _getCurrentLocation();
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _nameController.dispose();
// //     _emailController.dispose();
// //     _phoneController.dispose();
// //     _passwordController.dispose();
// //     _confirmPasswordController.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _getCurrentLocation() async {
// //     try {
// //       final permission = await Geolocator.checkPermission();
// //       if (permission == LocationPermission.denied) {
// //         await Geolocator.requestPermission();
// //       }
// //
// //       _currentPosition = await Geolocator.getCurrentPosition(
// //         locationSettings: const LocationSettings(
// //           accuracy: LocationAccuracy.high,
// //         ),
// //       );
// //     } catch (e) {
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('فشل الحصول على الموقع: $e')),
// //         );
// //       }
// //     }
// //   }
// //
// //   Future<void> _handleAuth() async {
// //     setState(() => _isLoading = true);
// //
// //     try {
// //       final authController = ref.read(authControllerProvider);
// //
// //       if (_isLogin) {
// //         // ========================= PHONE OTP LOGIN =========================
// //         final phoneNumber = _phoneController.text.trim();
// //         if (phoneNumber.isEmpty) {
// //           if (mounted) {
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               const SnackBar(content: Text('يرجى إدخال رقم الهاتف')),
// //             );
// //           }
// //           return;
// //         }
// //
// //         // Start phone OTP verification
// //         await authController.signInWithPhoneOTP(
// //           phoneNumber: phoneNumber,
// //           onCodeSent: (String verificationId, int? resendToken) async {
// //             _verificationId = verificationId;
// //             if (mounted) {
// //               await _showOTPDialog();
// //             }
// //           },
// //           onVerificationFailed: (FirebaseAuthException e) {
// //             if (mounted) {
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 SnackBar(content: Text('فشل إرسال رمز التحقق: ${e.message ?? e.code}')),
// //               );
// //             }
// //           },
// //           onVerificationCompleted: (PhoneAuthCredential credential) async {
// //             try {
// //               final userData = await authController.verifyOTPAndCompleteLogin(
// //                 verificationId: _verificationId ?? '',
// //                 smsCode: '', // Auto-verification doesn't need SMS code
// //               );
// //               if (userData != null && mounted) {
// //                 context.go('/patient/dashboard');
// //               }
// //             } catch (e) {
// //               if (mounted) {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   SnackBar(content: Text('فشل التحقق التلقائي: $e')),
// //                 );
// //               }
// //             }
// //           },
// //           onCodeAutoRetrievalTimeout: (String verificationId) {
// //             _verificationId = verificationId;
// //           },
// //         );
// //         // ========================= END PHONE OTP LOGIN =========================
// //       } else {
// //         // Signup (keep existing signup logic)
// //         if (!_isLogin && _currentPosition == null) {
// //           await _getCurrentLocation();
// //         }
// //
// //         final user = _usePhoneOnly
// //           ? await authController.signUpWithPhoneOnly(
// //               phone: _phoneController.text.trim(),
// //               password: _passwordController.text,
// //               name: _nameController.text.trim(),
// //             )
// //           : await authController.signUpWithEmail(
// //               email: _emailController.text.trim(),
// //               password: _passwordController.text,
// //               name: _nameController.text.trim(),
// //               phone: _phoneController.text.trim(),
// //               role: 'patient',
// //               latitude: _currentPosition?.latitude,
// //               longitude: _currentPosition?.longitude,
// //             );
// //
// //         if (user != null && mounted) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //               content: Text('تم إنشاء الحساب بنجاح!'),
// //               backgroundColor: Colors.green,
// //             ),
// //           );
// //           context.go('/patient/dashboard');
// //         }
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         final errorMessage = e.toString();
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text(errorMessage),
// //             backgroundColor: Colors.red,
// //             duration: const Duration(seconds: 4),
// //             action: SnackBarAction(
// //               label: 'إغلاق',
// //               textColor: Colors.white,
// //               onPressed: () {
// //                 ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //               },
// //             ),
// //           ),
// //         );
// //       }
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isLoading = false);
// //       }
// //     }
// //   }
// //
// //
// //   Future<void> _showOTPDialog() async {
// //     if (_verificationId == null) return;
// //
// //     String otpCode = '';
// //
// //     await showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: const Text('أدخل رمز التحقق (OTP)'),
// //           content: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               const Text('تم إرسال رمز التحقق إلى رقم هاتفك'),
// //               const SizedBox(height: 16),
// //               TextField(
// //                 keyboardType: TextInputType.number,
// //                 decoration: const InputDecoration(
// //                   hintText: 'رمز التحقق المرسل عبر SMS',
// //                   border: OutlineInputBorder(),
// //                 ),
// //                 onChanged: (value) {
// //                   otpCode = value.trim();
// //                 },
// //               ),
// //             ],
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.of(context).pop(),
// //               child: const Text('إلغاء'),
// //             ),
// //             ElevatedButton(
// //               onPressed: () async {
// //                 if (otpCode.isEmpty) return;
// //                 try {
// //                   final authController = ref.read(authControllerProvider);
// //                   final userData = await authController.verifyOTPAndCompleteLogin(
// //                     verificationId: _verificationId!,
// //                     smsCode: otpCode,
// //                   );
// //                   if (mounted) {
// //                     Navigator.of(context).pop();
// //                     if (userData != null) {
// //                       context.go('/patient/dashboard');
// //                     }
// //                   }
// //                 } catch (e) {
// //                   if (mounted) {
// //                     ScaffoldMessenger.of(context).showSnackBar(
// //                       SnackBar(content: Text('فشل التحقق من الرمز: $e')),
// //                     );
// //                   }
// //                 }
// //               },
// //               child: const Text('تأكيد'),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// //
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.all(24.0),
// //           child: Form(
// //             key: _formKey,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.stretch,
// //               children: [
// //                 const SizedBox(height: 40),
// //
// //                 // Logo
// //                 Icon(
// //                   Icons.favorite,
// //                   size: 80,
// //                   color: Theme.of(context).primaryColor,
// //                 ),
// //                 const SizedBox(height: 16),
// //
// //                 // Title
// //                 Text(
// //                   _isLogin ? 'تسجيل دخول المريض' : 'إنشاء حساب مريض',
// //                   textAlign: TextAlign.center,
// //                   style: const TextStyle(
// //                     fontSize: 28,
// //                     fontWeight: FontWeight.bold,
// //                     fontFamily: 'Janna',
// //                   ),
// //                 ),
// //                 const SizedBox(height: 32),
// //
// //                 // Phone field for login (always visible)
// //                 if (_isLogin) ...[
// //                   TextFormField(
// //                     controller: _phoneController,
// //                     decoration: const InputDecoration(
// //                       labelText: 'رقم الهاتف',
// //                       prefixIcon: Icon(Icons.phone),
// //                       border: OutlineInputBorder(),
// //                       hintText: 'أدخل رقم هاتفك المسجل',
// //                     ),
// //                     keyboardType: TextInputType.phone,
// //                     validator: (value) {
// //                       if (value == null || value.trim().isEmpty) {
// //                         return 'يرجى إدخال رقم الهاتف';
// //                       }
// //                       return null;
// //                     },
// //                   ),
// //                   const SizedBox(height: 24),
// //                 ],
// //
// //                 // 🟢 Added: Phone-only mode toggle (only for signup)
// //                 if (!_isLogin) ...[
// //                   Container(
// //                     padding: const EdgeInsets.all(16),
// //                     decoration: BoxDecoration(
// //                       color: Colors.blue.withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(color: Colors.blue.withOpacity(0.3)),
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         Icon(
// //                           _usePhoneOnly ? Icons.phone : Icons.email,
// //                           color: _usePhoneOnly ? Colors.green : Colors.blue,
// //                         ),
// //                         const SizedBox(width: 12),
// //                         Expanded(
// //                           child: Text(
// //                             _usePhoneOnly
// //                               ? 'تسجيل دخول بالهاتف فقط (بدون إيميل)'
// //                               : 'تسجيل دخول بالإيميل والهاتف',
// //                             style: const TextStyle(fontWeight: FontWeight.w600),
// //                           ),
// //                         ),
// //                         Switch(
// //                           value: _usePhoneOnly,
// //                           onChanged: (value) {
// //                             setState(() {
// //                               _usePhoneOnly = value;
// //                             });
// //                           },
// //                           activeColor: Colors.green,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   const SizedBox(height: 24),
// //                 ],
// //
// //                 // Name field (signup only)
// //                 if (!_isLogin) ...[
// //                   TextFormField(
// //                     controller: _nameController,
// //                     decoration: const InputDecoration(
// //                       labelText: 'الاسم الكامل',
// //                       prefixIcon: Icon(Icons.person),
// //                       border: OutlineInputBorder(),
// //                     ),
// //                     validator: Validators.name,
// //                   ),
// //                   const SizedBox(height: 16),
// //                 ],
// //
// //                 // Phone field (signup only)
// //                 if (!_isLogin) ...[
// //                   TextFormField(
// //                     controller: _phoneController,
// //                     decoration: const InputDecoration(
// //                       labelText: 'رقم الهاتف',
// //                       prefixIcon: Icon(Icons.phone),
// //                       border: OutlineInputBorder(),
// //                     ),
// //                     keyboardType: TextInputType.phone,
// //                     validator: Validators.phone,
// //                   ),
// //                   const SizedBox(height: 16),
// //                 ],
// //
// //                 // Email field (only show when not using phone-only mode)
// //                 if (!_usePhoneOnly) ...[
// //                   TextFormField(
// //                     controller: _emailController,
// //                     decoration: const InputDecoration(
// //                       labelText: 'البريد الإلكتروني',
// //                       prefixIcon: Icon(Icons.email),
// //                       border: OutlineInputBorder(),
// //                     ),
// //                     keyboardType: TextInputType.emailAddress,
// //                     validator: Validators.email,
// //                   ),
// //                   const SizedBox(height: 16),
// //                 ],
// //
// //                 // Password field (signup only)
// //                 if (!_isLogin) ...[
// //                   TextFormField(
// //                     controller: _passwordController,
// //                     decoration: InputDecoration(
// //                       labelText: 'كلمة المرور',
// //                       prefixIcon: const Icon(Icons.lock),
// //                       border: const OutlineInputBorder(),
// //                       suffixIcon: IconButton(
// //                         icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
// //                         onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
// //                       ),
// //                     ),
// //                     obscureText: _obscurePassword,
// //                     validator: Validators.password,
// //                   ),
// //                   const SizedBox(height: 16),
// //                 ],
// //
// //                 // Confirm Password field (signup only)
// //                 if (!_isLogin) ...[
// //                   TextFormField(
// //                     controller: _confirmPasswordController,
// //                     decoration: InputDecoration(
// //                       labelText: 'تأكيد كلمة المرور',
// //                       prefixIcon: const Icon(Icons.lock_outline),
// //                       border: const OutlineInputBorder(),
// //                       suffixIcon: IconButton(
// //                         icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
// //                         onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
// //                       ),
// //                     ),
// //                     obscureText: _obscureConfirmPassword,
// //                     validator: (value) {
// //                       if (value != _passwordController.text) {
// //                         return 'كلمتا المرور غير متطابقتين';
// //                       }
// //                       return null;
// //                     },
// //                   ),
// //                   const SizedBox(height: 16),
// //                 ],
// //
// //                 // Info text for login mode
// //                 if (_isLogin)
// //                   Container(
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.blue.withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(8),
// //                       border: Border.all(color: Colors.blue.withOpacity(0.3)),
// //                     ),
// //                     child: const Row(
// //                       children: [
// //                         Icon(Icons.info_outline, color: Colors.blue, size: 20),
// //                         SizedBox(width: 8),
// //                         Expanded(
// //                           child: Text(
// //                             'سيتم إرسال رمز التحقق إلى رقم هاتفك المسجل',
// //                             style: TextStyle(fontSize: 14, color: Colors.blue),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //
// //                 const SizedBox(height: 24),
// //
// //                 // Submit button
// //                 ElevatedButton(
// //                   onPressed: _isLoading ? null : _handleAuth,
// //                   style: ElevatedButton.styleFrom(
// //                     padding: const EdgeInsets.symmetric(vertical: 16),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                   ),
// //                   child: _isLoading
// //                       ? const CircularProgressIndicator(color: Colors.white)
// //                       : Text(
// //                           _isLogin ? 'تسجيل الدخول' : 'إنشاء الحساب',
// //                           style: const TextStyle(fontSize: 18, fontFamily: 'Janna'),
// //                         ),
// //                 ),
// //                 const SizedBox(height: 16),
// //
// //                 // Toggle login/signup
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Text(_isLogin ? 'ليس لديك حساب؟' : 'لديك حساب بالفعل؟'),
// //                     TextButton(
// //                       onPressed: () {
// //                         setState(() {
// //                           _isLogin = !_isLogin;
// //                           if (!_isLogin) {
// //                             _getCurrentLocation();
// //                           }
// //                         });
// //                       },
// //                       child: Text(_isLogin ? 'إنشاء حساب' : 'تسجيل الدخول'),
// //                     ),
// //                   ],
// //                 ),
// //
// //                 // Back button
// //                 TextButton(
// //                   onPressed: () => context.go('/'),
// //                   child: const Text('العودة للصفحة الرئيسية'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
//
// // Firebase Patient Auth Screen - Email & Password Only
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../../core/utils/validators.dart';
// import '../../../providers/auth_provider.dart';
//
// class FirebasePatientAuthScreen extends ConsumerStatefulWidget {
//   const FirebasePatientAuthScreen({super.key});
//   @override
//   ConsumerState<FirebasePatientAuthScreen> createState() => _FirebasePatientAuthScreenState();
// }
//
// class _FirebasePatientAuthScreenState extends ConsumerState<FirebasePatientAuthScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _isLogin = true;
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleAuth() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isLoading = true);
//
//     try {
//       final authController = ref.read(authControllerProvider);
//
//       if (_isLogin) {
//         // تسجيل الدخول بالإيميل والباسورد
//         final userData = await authController.signInWithEmail(
//           email: _emailController.text.trim(),
//           password: _passwordController.text,
//         );
//         if (userData != null && mounted) {
//           context.go('/patient/dashboard');
//         }
//       } else {
//         // إنشاء حساب بالإيميل والباسورد
//         final user = await authController.signUpWithEmail(
//           email: _emailController.text.trim(),
//           password: _passwordController.text,
//           name: _nameController.text.trim(),
//           phone: '', // اختياري
//           role: 'patient',
//         );
//         if (user != null && mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('تم إنشاء الحساب بنجاح!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           context.go('/patient/dashboard');
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.toString()),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 40),
//                 Icon(Icons.favorite, size: 80, color: Theme.of(context).primaryColor),
//                 const SizedBox(height: 16),
//                 Text(
//                   _isLogin ? 'تسجيل دخول المريض' : 'إنشاء حساب مريض',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Janna'),
//                 ),
//                 const SizedBox(height: 32),
//
//                 if (!_isLogin)
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(
//                       labelText: 'الاسم الكامل',
//                       prefixIcon: Icon(Icons.person),
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: Validators.name,
//                   ),
//                 if (!_isLogin) const SizedBox(height: 16),
//
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(
//                     labelText: 'البريد الإلكتروني',
//                     prefixIcon: Icon(Icons.email),
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: Validators.email,
//                 ),
//                 const SizedBox(height: 16),
//
//                 TextFormField(
//                   controller: _passwordController,
//                   decoration: InputDecoration(
//                     labelText: 'كلمة المرور',
//                     prefixIcon: const Icon(Icons.lock),
//                     border: const OutlineInputBorder(),
//                     suffixIcon: IconButton(
//                       icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
//                       onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//                     ),
//                   ),
//                   obscureText: _obscurePassword,
//                   validator: Validators.password,
//                 ),
//                 const SizedBox(height: 16),
//
//                 if (!_isLogin)
//                   TextFormField(
//                     controller: _confirmPasswordController,
//                     decoration: InputDecoration(
//                       labelText: 'تأكيد كلمة المرور',
//                       prefixIcon: const Icon(Icons.lock_outline),
//                       border: const OutlineInputBorder(),
//                       suffixIcon: IconButton(
//                         icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
//                         onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
//                       ),
//                     ),
//                     obscureText: _obscureConfirmPassword,
//                     validator: (value) {
//                       if (value != _passwordController.text) {
//                         return 'كلمتا المرور غير متطابقتين';
//                       }
//                       return null;
//                     },
//                   ),
//                 if (!_isLogin) const SizedBox(height: 16),
//
//                 ElevatedButton(
//                   onPressed: _isLoading ? null : _handleAuth,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(_isLogin ? 'تسجيل الدخول' : 'إنشاء الحساب', style: const TextStyle(fontSize: 18, fontFamily: 'Janna')),
//                 ),
//                 const SizedBox(height: 16),
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(_isLogin ? 'ليس لديك حساب؟' : 'لديك حساب بالفعل؟'),
//                     TextButton(
//                       onPressed: () => setState(() => _isLogin = !_isLogin),
//                       child: Text(_isLogin ? 'إنشاء حساب' : 'تسجيل الدخول'),
//                     ),
//                   ],
//                 ),
//
//                 TextButton(
//                   onPressed: () => context.go('/'),
//                   child: const Text('العودة للصفحة الرئيسية'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';

class FirebasePatientAuthScreen extends ConsumerStatefulWidget {
  const FirebasePatientAuthScreen({super.key});
  @override
  ConsumerState<FirebasePatientAuthScreen> createState() => _FirebasePatientAuthScreenState();
}

class _FirebasePatientAuthScreenState extends ConsumerState<FirebasePatientAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authController = ref.read(authControllerProvider);

      if (_isLogin) {
        // تسجيل الدخول بالإيميل والباسورد
        final userData = await authController.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (userData != null && mounted) {
          context.go('/patient/dashboard');
        }
      } else {
        // إنشاء حساب بالإيميل والباسورد
        final user = await authController.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: 'patient',
        );
        if (user != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء الحساب بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/patient/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(Icons.favorite, size: 80, color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                Text(
                  _isLogin ? 'تسجيل دخول المريض' : 'إنشاء حساب مريض',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Janna'),
                ),
                const SizedBox(height: 32),

                if (!_isLogin)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.name,
                  ),
                if (!_isLogin) const SizedBox(height: 16),

                if (!_isLogin)
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال رقم الهاتف';
                      }
                      if (!RegExp(r'^\+?\d{9,15}$').hasMatch(value.trim())) {
                        return 'رقم الهاتف غير صالح';
                      }
                      return null;
                    },
                  ),
                if (!_isLogin) const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),

                if (!_isLogin)
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'كلمتا المرور غير متطابقتين';
                      }
                      return null;
                    },
                  ),
                if (!_isLogin) const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isLogin ? 'تسجيل الدخول' : 'إنشاء الحساب', style: const TextStyle(fontSize: 18, fontFamily: 'Janna')),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_isLogin ? 'ليس لديك حساب؟' : 'لديك حساب بالفعل؟'),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(_isLogin ? 'إنشاء حساب' : 'تسجيل الدخول'),
                    ),
                  ],
                ),
                TextButton(onPressed: (){
                  context.push('/doctor/forgot-password');
                }, child: Text("نسيت كلمة المرور؟")

                ),

                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('العودة للصفحة الرئيسية'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

