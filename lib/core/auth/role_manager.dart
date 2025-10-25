import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

class RoleManager {
  static const String roleAdmin = 'admin';
  static const String roleSupervisor = 'supervisor';
  static const String roleDoctor = 'doctor';
  static const String rolePatient = 'patient';

  static bool isAdmin(UserModel user) => user.role == roleAdmin;
  static bool isSupervisor(UserModel user) => user.role == roleSupervisor;
  static bool isDoctor(UserModel user) => user.role == roleDoctor;
  static bool isPatient(UserModel user) => user.role == rolePatient;

  // Permissions
  static bool canViewAllUsers(UserModel user) {
    return isAdmin(user);
  }

  static bool canViewAllCases(UserModel user) {
    return isAdmin(user) || isSupervisor(user);
  }

  static bool canViewPrices(UserModel user) {
    return isAdmin(user) || isSupervisor(user) || isDoctor(user);
  }

  static bool canAssignSupervisors(UserModel user) {
    return isAdmin(user);
  }

  static bool canManageSupervisors(UserModel user) {
    return isAdmin(user);
  }

  static bool canChangeRoles(UserModel user) {
    return isAdmin(user);
  }

  static bool canDeleteAdmins(UserModel user) {
    return false; // Explicitly disallow for non-admins
  }

  // Convenience fetch current user model
  static Future<UserModel?> fetchUser(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!);
  }
}


