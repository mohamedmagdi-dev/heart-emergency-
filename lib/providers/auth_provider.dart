// Firebase Authentication Provider with Riverpod and Local Storage
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // FIXED: Added for real-time user data
import '../services/firebase_auth_service.dart';
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

  AuthController(this._authService, this._localStorageService, this._fcmService);

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

  // Sign up with email and password
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
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Upload certificates if doctor
      List<String>? certificateUrls;
      String? idDocumentUrl;

      if (role == 'doctor' && certificates != null && certificates.isNotEmpty) {
        certificateUrls = [];
        for (var cert in certificates) {
          // Validate file exists
          if (await cert.exists()) {
            final localPath = await _localStorageService.saveDoctorCertificate(
              cert,
              DateTime.now().millisecondsSinceEpoch.toString(),
            );
            certificateUrls.add(localPath);
          }
        }
      }

      if (role == 'doctor' && idDocument != null) {
        // Validate file exists
        if (await idDocument.exists()) {
          idDocumentUrl = await _localStorageService.saveIdDocument(
            idDocument,
            DateTime.now().millisecondsSinceEpoch.toString(),
          );
        }
      }

      // Get FCM token
      final fcmToken = await _fcmService.getToken();

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

      return userData;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  // Future<UserModel?> signInWithEmail({
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     final userData = await _authService.signIn(
  //       email: email,
  //       password: password,
  //     );
  //
  //     // Update FCM token
  //     final fcmToken = await _fcmService.getToken();
  //     if (fcmToken != null) {
  //       await _authService.updateUserData(userData.uid, {'fcmToken': fcmToken});
  //     }
  //
  //     return userData;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

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
  return AuthController(authService, localStorageService, fcmService);
});

