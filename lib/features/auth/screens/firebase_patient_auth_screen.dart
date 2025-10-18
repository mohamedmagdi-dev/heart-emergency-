// Firebase Patient Authentication Screen (Login & Signup)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/utils/validators.dart';

class FirebasePatientAuthScreen extends ConsumerStatefulWidget {
  const FirebasePatientAuthScreen({super.key});

  @override
  ConsumerState<FirebasePatientAuthScreen> createState() => _FirebasePatientAuthScreenState();
}

class _FirebasePatientAuthScreenState extends ConsumerState<FirebasePatientAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _usePhoneOnly = true; // 🟢 Added: Phone-only mode toggle
  Position? _currentPosition;
  String? _verificationId; // For Firebase Phone Auth OTP

  @override
  void initState() {
    super.initState();
    if (!_isLogin) {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحصول على الموقع: $e')),
        );
      }
    }
  }

  Future<void> _handleAuth() async {
    // Old validation for email/password login
    // if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authController = ref.read(authControllerProvider);

      if (_isLogin) {
        // ========================= NEW PHONE AUTH (OTP) LOGIN =========================
        // 1) Validate phone input only (do not enforce password/email for OTP flow)
        final rawPhone = _phoneController.text.trim();
        if (rawPhone.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('يرجى إدخال رقم الهاتف')),
            );
          }
          return;
        }

        // 2) Normalize phone (basic trim only; do not force country code)
        final phone = rawPhone;

        // 3) Check Firestore if phone exists in users collection
        final phoneExists = await _doesPhoneExist(phone);
        if (!phoneExists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This phone number is not registered.')),
            );
          }
          return;
        }

        // 4) Start Firebase Phone Verification
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            try {
              final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
              await _postPhoneLoginNavigateIfPatient(userCredential.user?.uid);
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('فشل التحقق التلقائي: $e')),
                );
              }
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('فشل إرسال رمز التحقق: ${e.message ?? e.code}')),
              );
            }
          },
          codeSent: (String verificationId, int? resendToken) async {
            _verificationId = verificationId;
            await _promptForOtpAndSignIn();
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
        );

        // ========================= END NEW PHONE AUTH (OTP) LOGIN =========================

        // Old email/phone+password login kept for reference (commented):
        // final user = _usePhoneOnly
        //   ? await authController.signInWithPhoneOnly(
        //       phone: _phoneController.text.trim(),
        //       password: _passwordController.text,
        //     )
        //   : await authController.signInWithEmail(
        //       email: _emailController.text.trim(),
        //       password: _passwordController.text,
        //     );
        // if (user != null && mounted) {
        //   if (user.role == 'patient') {
        //     context.go('/patient/dashboard');
        //   } else {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(content: Text('هذا الحساب ليس لمريض')),
        //     );
        //     await authController.signOut();
        //   }
        // }
      } else {
        // Signup
        if (!_isLogin && _currentPosition == null) {
          await _getCurrentLocation();
        }

        final user = _usePhoneOnly
          ? await authController.signUpWithPhoneOnly(
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
              name: _nameController.text.trim(),
            )
          : await authController.signUpWithEmail(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              role: 'patient',
              latitude: _currentPosition?.latitude,
              longitude: _currentPosition?.longitude,
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
        // FIXED: Enhanced error handling with dialog for critical errors
        final errorMessage = e.toString();
        if (errorMessage.contains('البريد الإلكتروني مستخدم بالفعل') ||
            errorMessage.contains('كلمة المرور غير صحيحة') ||
            errorMessage.contains('المستخدم غير موجود')) {
          _showErrorDialog('خطأ في المصادقة', errorMessage);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'إغلاق',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _doesPhoneExist(String phone) async {
    try {
      // Search exact match on 'users' collection phone field
      final qs = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      return qs.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _promptForOtpAndSignIn() async {
    if (_verificationId == null) return;

    String otpCode = '';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('أدخل رمز التحقق (OTP)'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'رمز التحقق المرسل عبر SMS'),
            onChanged: (value) {
              otpCode = value.trim();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (otpCode.isEmpty) return;
                try {
                  final credential = PhoneAuthProvider.credential(
                    verificationId: _verificationId!,
                    smsCode: otpCode,
                  );
                  final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
                  if (mounted) Navigator.of(context).pop();
                  await _postPhoneLoginNavigateIfPatient(userCredential.user?.uid);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('فشل التحقق من الرمز: $e')),
                    );
                  }
                }
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _postPhoneLoginNavigateIfPatient(String? uid) async {
    if (uid == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        // Not found in users collection
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حساب المستخدم غير موجود في قاعدة البيانات')),
          );
        }
        await FirebaseAuth.instance.signOut();
        return;
      }
      final data = userDoc.data()!;
      final role = data['role'] as String?;
      if (role == 'patient') {
        if (mounted) {
          context.go('/patient/dashboard');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('هذا الحساب ليس لمريض')),
          );
        }
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إكمال تسجيل الدخول: $e')),
        );
      }
    }
  }

  // FIXED: Show error dialog for critical authentication errors
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red[600]),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
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

                // Logo
                Icon(
                  Icons.favorite,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  _isLogin ? 'تسجيل دخول المريض' : 'إنشاء حساب مريض',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Janna',
                  ),
                ),
                const SizedBox(height: 32),

                // 🟢 Added: Phone-only mode toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _usePhoneOnly ? Icons.phone : Icons.email,
                        color: _usePhoneOnly ? Colors.green : Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _usePhoneOnly
                            ? 'تسجيل دخول بالهاتف فقط (بدون إيميل)'
                            : 'تسجيل دخول بالإيميل والهاتف',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Switch(
                        value: _usePhoneOnly,
                        onChanged: (value) {
                          setState(() {
                            _usePhoneOnly = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Name field (signup only)
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.name,
                  ),
                  const SizedBox(height: 16),
                ],

                // Phone field (signup only)
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 16),
                ],

                // Email field (only show when not using phone-only mode)
                if (!_usePhoneOnly) ...[
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
                ],

                // Password field
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

                // Confirm Password field (signup only)
                if (!_isLogin) ...[
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
                  const SizedBox(height: 16),
                ],

                // Forgot password (login only)
                if (_isLogin)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                      context.go("/doctor/forgot-password");
                      },
                      child: const Text('نسيت كلمة المرور؟'),
                    ),
                  ),

                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isLogin ? 'تسجيل الدخول' : 'إنشاء الحساب',
                          style: const TextStyle(fontSize: 18, fontFamily: 'Janna'),
                        ),
                ),
                const SizedBox(height: 16),

                // Toggle login/signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_isLogin ? 'ليس لديك حساب؟' : 'لديك حساب بالفعل؟'),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          if (!_isLogin) {
                            _getCurrentLocation();
                          }
                        });
                      },
                      child: Text(_isLogin ? 'إنشاء حساب' : 'تسجيل الدخول'),
                    ),
                  ],
                ),

                // Back button
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

