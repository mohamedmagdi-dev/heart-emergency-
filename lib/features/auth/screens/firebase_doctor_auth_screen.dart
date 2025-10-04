// Firebase Doctor Authentication Screen (Login & Signup)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/utils/validators.dart';

class FirebaseDoctorAuthScreen extends ConsumerStatefulWidget {
  const FirebaseDoctorAuthScreen({super.key});

  @override
  ConsumerState<FirebaseDoctorAuthScreen> createState() => _FirebaseDoctorAuthScreenState();
}

class _FirebaseDoctorAuthScreenState extends ConsumerState<FirebaseDoctorAuthScreen> {
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
  
  String? _selectedSpecialization;
  String? _selectedExperience;
  List<File> _certificates = [];
  File? _idDocument;
  Position? _currentPosition;

  final List<String> _specializations = [
    'قلب وأوعية دموية',
    'طوارئ',
    'جراحة عامة',
    'باطنة',
    'أطفال',
    'نساء وولادة',
    'عظام',
    'أنف وأذن وحنجرة',
  ];

  final List<String> _experiences = [
    '1-3 سنوات',
    '3-5 سنوات',
    '5-10 سنوات',
    'أكثر من 10 سنوات',
  ];

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
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحصول على الموقع: $e')),
        );
      }
    }
  }

  Future<void> _pickCertificates() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _certificates = result.paths
              .where((path) => path != null)
              .map((path) => File(path!))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل اختيار الملفات: $e')),
        );
      }
    }
  }

  Future<void> _pickIdDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _idDocument = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل اختيار الملف: $e')),
        );
      }
    }
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLogin) {
      if (_selectedSpecialization == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار التخصص')),
        );
        return;
      }
      if (_selectedExperience == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار سنوات الخبرة')),
        );
        return;
      }
      // Files are now optional - doctors can add them from profile later
      if (_certificates.isEmpty && _idDocument == null) {
        final shouldContinue = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تنبيه'),
            content: const Text('لم يتم رفع أي مستندات. يمكنك إضافتها لاحقاً من الملف الشخصي. هل تريد المتابعة؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('متابعة'),
              ),
            ],
          ),
        );
        if (shouldContinue != true) return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authController = ref.read(authControllerProvider);

      if (_isLogin) {
        // Login
        final user = await authController.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (user != null && mounted) {
          if (user.role == 'doctor') {
            if (user.verified == true) {
              context.go('/doctor/dashboard');
            } else {
              context.go('/doctor/pending-verification');
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('هذا الحساب ليس لطبيب')),
            );
            await authController.signOut();
          }
        }
      } else {
        // Signup
        if (_currentPosition == null) {
          await _getCurrentLocation();
        }

        final user = await authController.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: 'doctor',
          specialization: _selectedSpecialization,
          experience: _selectedExperience,
          certificates: _certificates,
          idDocument: _idDocument,
          latitude: _currentPosition?.latitude,
          longitude: _currentPosition?.longitude,
        );

        if (user != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء الحساب بنجاح! سيتم مراجعة بياناتك من قبل الإدارة'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
          context.go('/doctor/pending-verification');
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
                const SizedBox(height: 20),
                
                // Logo
                Icon(
                  Icons.local_hospital,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  _isLogin ? 'تسجيل دخول الطبيب' : 'إنشاء حساب طبيب',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Janna',
                  ),
                ),
                const SizedBox(height: 32),

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

                // Specialization (signup only)
                if (!_isLogin) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedSpecialization,
                    decoration: const InputDecoration(
                      labelText: 'التخصص',
                      prefixIcon: Icon(Icons.medical_services),
                      border: OutlineInputBorder(),
                    ),
                    items: _specializations.map((spec) {
                      return DropdownMenuItem(value: spec, child: Text(spec));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedSpecialization = value),
                  ),
                  const SizedBox(height: 16),
                ],

                // Experience (signup only)
                if (!_isLogin) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedExperience,
                    decoration: const InputDecoration(
                      labelText: 'سنوات الخبرة',
                      prefixIcon: Icon(Icons.work),
                      border: OutlineInputBorder(),
                    ),
                    items: _experiences.map((exp) {
                      return DropdownMenuItem(value: exp, child: Text(exp));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedExperience = value),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email field
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

                // Upload certificates (signup only)
                if (!_isLogin) ...[
                  OutlinedButton.icon(
                    onPressed: _pickCertificates,
                    icon: const Icon(Icons.upload_file),
                    label: Text(_certificates.isEmpty
                        ? 'رفع الشهادات'
                        : 'تم رفع ${_certificates.length} شهادة'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Upload ID document (signup only)
                if (!_isLogin) ...[
                  OutlinedButton.icon(
                    onPressed: _pickIdDocument,
                    icon: const Icon(Icons.badge),
                    label: Text(_idDocument == null
                        ? 'رفع وثيقة الهوية'
                        : 'تم رفع وثيقة الهوية'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 8),

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

