// Firebase Authentication Provider with Riverpod and Local Storage
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // FIXED: Added for real-time user data
import '../services/cloudinary_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/image_upload_service.dart';
import '../services/local_storage_service.dart';
import '../services/fcm_service.dart';
import '../data/models/user_model.dart';
import '../core/utils/shared_preferences_helper.dart'; // 🟢 Added: For user data storage
import 'dart:io';

// Auth service provider
final authServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

// Local storage service provider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});
// upload images from firebase
final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return ImageUploadService();
});
// FCM service provider
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService();
});

// Current user stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user data provider - FIXED: Using StreamProvider for real-time updates
final currentUserDataProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(null);
      }
      // Return real-time stream from Firestore
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
        if (!doc.exists) return null;
        return UserModel.fromMap(doc.data()!);
      });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Auth controller
class AuthController {
  final FirebaseAuthService _authService;
  final LocalStorageService _localStorageService;
  final FCMService _fcmService;
  final ImageUploadService _imageUploadService;
  AuthController(this._authService, this._localStorageService, this._fcmService,
      this._imageUploadService,
      );

  // 🟢 Added: Phone-only signup for patients
  Future<UserModel?> signUpWithPhoneOnly({
    required String phone,
    required String password,
    required String name,
  }) async {
    try {
      final fcmToken = await _fcmService.getToken();
      final userData = await _authService.signUpWithPhoneOnly(
        phone: phone,
        password: password,
        name: name,
        fcmToken: fcmToken,
      );

      if (userData != null) {
        // Save user data locally using SharedPreferences
        await SharedPreferencesHelper.setString('user_id', userData.uid);
        await SharedPreferencesHelper.setString('user_role', userData.role);
        await SharedPreferencesHelper.setString('user_name', userData.name);
        await SharedPreferencesHelper.setString('user_email', userData.email);
        await SharedPreferencesHelper.setString('user_phone', userData.phone);
      }

      return userData;
    } catch (e) {
      rethrow;
    }
  }

  // 🟢 Added: Phone-only signin for patients
  Future<UserModel?> signInWithPhoneOnly({
    required String phone,
    required String password,
  }) async {
    try {
      final userData = await _authService.signInWithPhoneOnly(
        phone: phone,
        password: password,
      );

      if (userData != null) {
        // Update FCM token
        final fcmToken = await _fcmService.getToken();
        if (fcmToken != null) {
          await _authService.updateUserData(userData.uid, {'fcmToken': fcmToken});
        }

        // Save user data locally using SharedPreferences
        await SharedPreferencesHelper.setString('user_id', userData.uid);
        await SharedPreferencesHelper.setString('user_role', userData.role);
        await SharedPreferencesHelper.setString('user_name', userData.name);
        await SharedPreferencesHelper.setString('user_email', userData.email);
        await SharedPreferencesHelper.setString('user_phone', userData.phone);
      }

      return userData;
    } catch (e) {
      rethrow;
    }
  }
// sign two steps
  // 📍 داخل FirebaseAuthService

// 1. الدالة الأولى: لإنشاء حساب Firebase Auth فقط




  // Sign up with email and password
  // Future<UserModel?> signUpWithEmail({
  //   required String email,
  //   required String password,
  //   required String name,
  //   required String phone,
  //   required String role,
  //   Currency currency = Currency.egp,
  //   String? specialization,
  //   String? experience,
  //   List<File>? certificates,
  //   File? idDocument,
  //   double? latitude,
  //   double? longitude,
  // }) async {
  //   try {
  //     // Upload certificates if doctor
  //     List<String>? certificateUrls;
  //     String? idDocumentUrl;
  //
  //     if (role == 'doctor' && certificates != null && certificates.isNotEmpty) {
  //       certificateUrls = [];
  //       for (var cert in certificates) {
  //         // Validate file exists
  //         if (await cert.exists()) {
  //           final localPath = await _localStorageService.saveDoctorCertificate(
  //             cert,
  //             DateTime.now().millisecondsSinceEpoch.toString(),
  //           );
  //           certificateUrls.add(localPath);
  //         }
  //       }
  //     }
  //
  //     if (role == 'doctor' && idDocument != null) {
  //       // Validate file exists
  //       if (await idDocument.exists()) {
  //         idDocumentUrl = await _localStorageService.saveIdDocument(
  //           idDocument,
  //           DateTime.now().millisecondsSinceEpoch.toString(),
  //         );
  //       }
  //     }
  //
  //     // Get FCM token
  //     final fcmToken = await _fcmService.getToken();
  //
  //     final userData = await _authService.signUp(
  //       email: email,
  //       password: password,
  //       name: name,
  //       phone: phone,
  //       role: role,
  //       currency: currency,
  //       specialization: specialization,
  //       certificates: certificateUrls,
  //       profileImage: idDocumentUrl,
  //       fcmToken: fcmToken,
  //     );
  //
  //     return userData;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    Currency currency = Currency.egp,
    String? specialization,
    String? experience,
    List<File>? certificates,
    File? idDocument,
    File? medicalLicense,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Upload certificates if doctor
      List<String>? certificateUrls;
      String? idDocumentUrl;

      // نعمل instance من خدمة Cloudinary
      final cloudinary = CloudinaryService();

      if (role == 'doctor' && certificates != null && certificates.isNotEmpty) {
        certificateUrls = [];
        for (var cert in certificates) {
          if (await cert.exists()) {
            final imageUrl = await cloudinary.uploadFile(cert);
            if (imageUrl != null) {
              certificateUrls.add(imageUrl);
            }
          }
        }
      }

      if (role == 'doctor' && idDocument != null) {
        if (await idDocument.exists()) {
          final imageUrl = await cloudinary.uploadFile(idDocument);
          if (imageUrl != null) {
            idDocumentUrl = imageUrl;
          }
        }
      }

      // رفع رخصة مزاولة المهنة وتخزين الرابط في حقل منفصل
      String? medicalLicenseUrl;
      if (role == 'doctor' && medicalLicense != null) {
        if (await medicalLicense.exists()) {
          final imageUrl = await cloudinary.uploadFile(medicalLicense);
          if (imageUrl != null) {
            medicalLicenseUrl = imageUrl;
          }
        }
      }

      // Get FCM token
      final fcmToken = await _fcmService.getToken();

      // تسجيل المستخدم بعد رفع الصور
      final userData = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
        currency: currency,
        specialization: specialization,
        certificates: certificateUrls,
        profileImage: idDocumentUrl,
        fcmToken: fcmToken,
      );

      // حفظ رابط رخصة مزاولة المهنة في وثيقة المستخدم (إن وجد)
      if (userData != null && medicalLicenseUrl != null) {
        await _authService.updateUserData(userData.uid, {
          'medicalLicenseUrl': medicalLicenseUrl,
        });
      }

      return userData;
    } catch (e) {
      print("❌ خطأ أثناء التسجيل: $e");
      rethrow;
    }
  }



// 📍 داخل AuthController
// 📍 داخل AuthController

// 📍 داخل AuthController في دالة signUpWithEmail

// 📍 داخل AuthController
//
//   Future<UserModel?> signUpWithEmail({
//     required String email,
//     required String password,
//     required String name,
//     required String phone,
//     required String role,
//     Currency currency = Currency.egp,
//     String? specialization,
//     String? experience,
//     List<File>? certificates,
//     File? idDocument,
//     double? latitude,
//     double? longitude,
//   }) async {
//     try {
//       // 1. 🚨 الخطوة الأولى: إنشاء الحساب في Firebase Auth
//       // هذا يضمن وجود المستخدم وتوافر الـ Auth Token للرفع.
//       final userCredential = await _authService.createUserWithEmailAndPassword(
//           email: email,
//           password: password
//       );
//       final uid = userCredential.user!.uid; // 🟢 الآن الـ UID والـ Token جاهزين للرفع
//
//       // 2. رفع الملفات إلى Firebase Storage
//       List<String>? certificateUrls;
//       String? idDocumentUrl;
//
//       if (role == 'doctor' && certificates != null && certificates.isNotEmpty) {
//         certificateUrls = [];
//         for (var cert in certificates) {
//           if (await cert.exists()) {
//             final uploadUrl = await _imageUploadService.uploadLocalFileToStorage(
//               cert.path,
//               // استخدام الـ UID لترتيب المجلدات في Storage
//               storageFolder: 'certificates/$uid',
//             );
//             certificateUrls.add(uploadUrl);
//           }
//         }
//       }
//
//       if (role == 'doctor' && idDocument != null) {
//         if (await idDocument.exists()) {
//           idDocumentUrl = await _imageUploadService.uploadLocalFileToStorage(
//             idDocument.path,
//             // استخدام الـ UID لترتيب المجلدات في Storage
//             storageFolder: 'id_documents/$uid',
//           );
//         }
//       }
//
//       // 3. الحصول على FCM Token
//       final fcmToken = await _fcmService.getToken();
//
//       // 4. بناء خريطة البيانات لتخزينها في Firestore
//       final userDataMap = UserModel(
//         uid: uid,
//         email: email,
//         name: name,
//         phone: phone,
//         role: role,
//         currency: currency,
//         specialization: specialization,
//         experience: experience,
//         certificates: certificateUrls, // الآن هي URLs شبكية
//         profileImage: idDocumentUrl,   // الآن هو URL شبكي
//         fcmToken: fcmToken,
//         createdAt: DateTime.now(),
//         available: role == 'doctor' ? true : null,
//         verified: role == 'doctor' ? false : null,
//         walletBalance: 0.0,
//         rating: role == 'doctor' ? 0.0 : null,
//         // ... (أي حقول أخرى مطلوبة في الـ Model)
//       ).toMap();
//
//       // 5. 🚨 الخطوة الأخيرة: تخزين البيانات في Firestore
//       final savedUser = await _authService.saveUserDataToFirestore(uid, userDataMap);
//
//       return savedUser;
//
//     } catch (e) {
//       rethrow;
//     }
//   }
  // في auth_controller.dart - الدالة المعدلة

  // update
  // AuthController -> signInWithEmail فقط
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // تسجيل الدخول باستخدام FirebaseAuth
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user!.uid;

      // جلب بيانات المستخدم من Firestore مباشرة
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) throw Exception('حساب المستخدم غير موجود في قاعدة البيانات.');

      final userData = UserModel.fromMap(doc.data()!);

      // تحديث FCM token
      final fcmToken = await _fcmService.getToken();
      if (fcmToken != null) {
        await _authService.updateUserData(uid, {'fcmToken': fcmToken});
      }

      return userData; // الآن role موجود بشكل صحيح
    } catch (e) {
      rethrow;
    }
  }



  // 🟢 Added: Phone OTP login for patients
  Future<UserModel?> signInWithPhoneOTP({
    required String phoneNumber,
    required PhoneCodeSent onCodeSent,
    required PhoneVerificationFailed onVerificationFailed,
    required PhoneVerificationCompleted onVerificationCompleted,
    required PhoneCodeAutoRetrievalTimeout onCodeAutoRetrievalTimeout,
  }) async {
    try {
      // First, check if phone number exists in Firestore and is a patient
      final userData = await _authService.findUserByPhone(phoneNumber);
      if (userData == null) {
        throw 'هذا الرقم غير مسجل كمريض';
      }
      
      if (userData.role != 'patient') {
        throw 'هذا الرقم غير مسجل كمريض';
      }

      // Send OTP to phone
      await _authService.sendOTPToPhone(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
        onVerificationFailed: onVerificationFailed,
        onVerificationCompleted: onVerificationCompleted,
        onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      );

      return userData;
    } catch (e) {
      rethrow;
    }
  }

  // 🟢 Added: Verify OTP and complete login
  Future<UserModel?> verifyOTPAndCompleteLogin({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // Verify OTP and sign in with Firebase Auth
      final userCredential = await _authService.verifyOTPAndSignIn(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw 'فشل التحقق من الهوية';
      }

      // Get user data from Firestore
      final userData = await _authService.getUserData(uid);
      if (userData == null) {
        throw 'بيانات المستخدم غير موجودة';
      }

      // Update FCM token
      final fcmToken = await _fcmService.getToken();
      if (fcmToken != null) {
        await _authService.updateUserData(uid, {'fcmToken': fcmToken});
      }

      // Save user data locally using SharedPreferences
      await SharedPreferencesHelper.setString('user_id', userData.uid);
      await SharedPreferencesHelper.setString('user_role', userData.role);
      await SharedPreferencesHelper.setString('user_name', userData.name);
      await SharedPreferencesHelper.setString('user_email', userData.email);
      await SharedPreferencesHelper.setString('user_phone', userData.phone);

      return userData;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      rethrow;
    }
  }
  // token


  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }


  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        await _authService.updateUserData(currentUser.uid, data);
      }
    } catch (e) {
      rethrow;
    }
  }
  // في auth_controller.dart - إضافة هذه الدوال
  User? get currentUser => _authService.currentUser;

  Future<void> changePassword(String newPassword) async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      rethrow;
    }
  }
  // في firestore_service.dart
  // في firestore_service.dart - إصلاح الخطأ هنا
  Future<void> updateUserCurrency(String userId, Currency currency) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'currency': currency.name,
    });
  }
}

// Auth controller provider
final authControllerProvider = Provider<AuthController>((ref) {
  final authService = ref.watch(authServiceProvider);
  final localStorageService = ref.watch(localStorageServiceProvider);
  final fcmService = ref.watch(fcmServiceProvider);
  final imageUploadService = ref.watch(imageUploadServiceProvider);
  return AuthController(authService, localStorageService, fcmService,
    imageUploadService,
  );
});

