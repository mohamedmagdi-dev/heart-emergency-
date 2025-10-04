// CHANGED_FOR_FIREBASE_INTEGRATION: Complete Firebase Authentication service with role-based access
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    Currency currency = Currency.EGP,
    String? specialization,
    List<String>? certificates,
    String? profileImage,
    String? fcmToken,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      // Create user document in Firestore
      final userData = UserModel(
        uid: user.uid,
        role: role,
        name: name,
        email: email,
        phone: phone,
        currency: currency,
        walletBalance: 0.0,
        createdAt: DateTime.now(),
        profileImage: profileImage,
        specialization: specialization,
        verified: role == 'admin', // Admin auto-verified, doctors need manual verification
        certificates: certificates,
        fcmToken: fcmToken,
      );

      await _firestore.collection('users').doc(user.uid).set(userData.toMap());

      // Update display name
      await user.updateDisplayName(name);

      return userData;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'حدث خطأ أثناء إنشاء الحساب: $e';
    }
  }

  // Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw 'فشل تسجيل الدخول';

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        throw 'بيانات المستخدم غير موجودة';
      }

      final userData = UserModel.fromMap(userDoc.data()!);

      // Note: User blocking would be handled by Firestore security rules
      // No isBlocked field in the new UserModel structure

      return userData;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'حدث خطأ أثناء تسجيل الدخول: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'فشل تسجيل الخروج: $e';
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return null;
      return UserModel.fromMap(userDoc.data()!);
    } catch (e) {
      throw 'فشل جلب بيانات المستخدم: $e';
    }
  }

  // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw 'فشل تحديث البيانات: $e';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'فشل إرسال رابط إعادة تعيين كلمة المرور: $e';
    }
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'فشل تغيير كلمة المرور: $e';
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).delete();
      }
      await _auth.currentUser?.delete();
    } catch (e) {
      throw 'فشل حذف الحساب: $e';
    }
  }

  // Check if user is doctor and verified
  Future<bool> isDoctorVerified(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return false;
      final userData = UserModel.fromMap(userDoc.data()!);
      return userData.role == 'doctor' && (userData.verified ?? false);
    } catch (e) {
      return false;
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'too-many-requests':
        return 'عدد كبير جداً من المحاولات. حاول لاحقاً';
      case 'network-request-failed':
        return 'فشل الاتصال بالإنترنت';
      case 'requires-recent-login':
        return 'يجب إعادة تسجيل الدخول لإجراء هذه العملية';
      default:
        return 'حدث خطأ: ${e.message ?? e.code}';
    }
  }
}

