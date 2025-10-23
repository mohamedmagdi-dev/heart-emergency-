// Admin service for managing user accounts and passwords
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reset user password by email (requires admin privileges)
  /// This sends a password reset email to the user
  Future<void> resetUserPasswordByEmail({
    required String userEmail,
    required String adminId,
  }) async {
    try {
      // Verify admin privileges
      await _verifyAdminPrivileges(adminId);

      // Send password reset email
      await _auth.sendPasswordResetEmail(email: userEmail);

      if (kDebugMode) {
        print('✅ Password reset email sent to: $userEmail');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error resetting password: $e');
      }
      rethrow;
    }
  }

  /// Change user password directly (requires admin privileges and new password)
  /// This is more secure as it doesn't require email access
  Future<void> changeUserPassword({
    required String userEmail,
    required String newPassword,
    required String adminId,
  }) async {
    try {
      // Verify admin privileges
      await _verifyAdminPrivileges(adminId);

      // Get user by email
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: 'temp_password', // This will fail, but we need the user
      );

      // Update password
      await userCredential.user!.updatePassword(newPassword);

      if (kDebugMode) {
        print('✅ Password changed for user: $userEmail');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'المستخدم غير موجود';
      } else if (e.code == 'wrong-password') {
        // User exists, now we can change the password using admin privileges
        await _changePasswordAsAdmin(userEmail, newPassword);
      } else {
        throw 'خطأ في تغيير كلمة المرور: ${e.message}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error changing password: $e');
      }
      rethrow;
    }
  }

  /// Change password using admin privileges (alternative method)
  Future<void> _changePasswordAsAdmin(String userEmail, String newPassword) async {
    try {
      // This would typically require a Cloud Function for security
      // For now, we'll use the Firebase Admin SDK approach
      
      // Note: This method requires server-side implementation with Firebase Admin SDK
      // The client-side approach has limitations due to security restrictions
      
      throw 'تغيير كلمة المرور يتطلب صلاحيات إدارية خاصة. يرجى استخدام إعادة تعيين كلمة المرور عبر البريد الإلكتروني.';
    } catch (e) {
      rethrow;
    }
  }

  /// Get all users for admin management
  Future<List<Map<String, dynamic>>> getAllUsers({
    required String adminId,
    String? roleFilter,
  }) async {
    try {
      // Verify admin privileges
      await _verifyAdminPrivileges(adminId);

      Query query = _firestore.collection('users');
      
      if (roleFilter != null) {
        query = query.where('role', isEqualTo: roleFilter);
      }

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting users: $e');
      }
      rethrow;
    }
  }

  /// Update user role (promote/demote users)
  Future<void> updateUserRole({
    required String userId,
    required String newRole,
    required String adminId,
  }) async {
    try {
      // Verify admin privileges
      await _verifyAdminPrivileges(adminId);

      // Update user role in Firestore
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'lastRoleUpdate': FieldValue.serverTimestamp(),
        'updatedBy': adminId,
      });

      if (kDebugMode) {
        print('✅ User role updated: $userId -> $newRole');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating user role: $e');
      }
      rethrow;
    }
  }

  /// Block/Unblock user account
  Future<void> toggleUserBlockStatus({
    required String userId,
    required bool isBlocked,
    required String adminId,
    String? reason,
  }) async {
    try {
      // Verify admin privileges
      await _verifyAdminPrivileges(adminId);

      await _firestore.collection('users').doc(userId).update({
        'isBlocked': isBlocked,
        'blockReason': reason,
        'blockedAt': isBlocked ? FieldValue.serverTimestamp() : null,
        'blockedBy': adminId,
      });

      if (kDebugMode) {
        print('✅ User block status updated: $userId -> $isBlocked');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating user block status: $e');
      }
      rethrow;
    }
  }

  /// Delete user account (permanent deletion)
  Future<void> deleteUserAccount({
    required String userId,
    required String adminId,
  }) async {
    try {
      // Verify admin privileges
      await _verifyAdminPrivileges(adminId);

      // Delete user data from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Note: Firebase Auth user deletion requires server-side implementation
      // with Firebase Admin SDK for security reasons
      
      if (kDebugMode) {
        print('✅ User account deleted: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting user account: $e');
      }
      rethrow;
    }
  }

  /// Verify admin privileges
  Future<void> _verifyAdminPrivileges(String adminId) async {
    try {
      final adminDoc = await _firestore.collection('users').doc(adminId).get();
      
      if (!adminDoc.exists) {
        throw 'المسؤول غير موجود';
      }

      final adminData = adminDoc.data();
      if (adminData?['role'] != 'admin') {
        throw 'ليس لديك صلاحية للوصول إلى هذه الوظيفة';
      }

      // Check if admin is blocked
      if (adminData?['isBlocked'] == true) {
        throw 'حسابك محظور';
      }

    } catch (e) {
      rethrow;
    }
  }

  /// Get user statistics for admin dashboard
  Future<Map<String, int>> getUserStatistics({
    required String adminId,
  }) async {
    try {
      // Verify admin privileges
      await _verifyAdminPrivileges(adminId);

      final usersSnapshot = await _firestore.collection('users').get();
      
      int totalUsers = 0;
      int patients = 0;
      int doctors = 0;
      int admins = 0;
      int blockedUsers = 0;
      int verifiedDoctors = 0;

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        totalUsers++;
        
        switch (data['role']) {
          case 'patient':
            patients++;
            break;
          case 'doctor':
            doctors++;
            if (data['verified'] == true) {
              verifiedDoctors++;
            }
            break;
          case 'admin':
            admins++;
            break;
        }
        
        if (data['isBlocked'] == true) {
          blockedUsers++;
        }
      }

      return {
        'totalUsers': totalUsers,
        'patients': patients,
        'doctors': doctors,
        'admins': admins,
        'blockedUsers': blockedUsers,
        'verifiedDoctors': verifiedDoctors,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user statistics: $e');
      }
      rethrow;
    }
  }
}
