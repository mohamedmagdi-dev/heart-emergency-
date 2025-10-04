// Firebase Authentication Provider with Riverpod and Local Storage
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // FIXED: Added for real-time user data
import '../services/firebase_auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/fcm_service.dart';
import '../data/models/user_model.dart';
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

  // Sign up with email and password
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    Currency currency = Currency.EGP,
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
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userData = await _authService.signIn(
        email: email,
        password: password,
      );

      // Update FCM token
      final fcmToken = await _fcmService.getToken();
      if (fcmToken != null) {
        await _authService.updateUserData(userData.uid, {'fcmToken': fcmToken});
      }

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
}

// Auth controller provider
final authControllerProvider = Provider<AuthController>((ref) {
  final authService = ref.watch(authServiceProvider);
  final localStorageService = ref.watch(localStorageServiceProvider);
  final fcmService = ref.watch(fcmServiceProvider);
  return AuthController(authService, localStorageService, fcmService);
});

