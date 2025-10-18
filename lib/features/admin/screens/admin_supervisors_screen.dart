// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../../../data/models/user_model.dart';
// import '../../../core/auth/role_manager.dart';
//
// class AdminSupervisorsScreen extends StatefulWidget {
//   const AdminSupervisorsScreen({super.key});
//
//   @override
//   State<AdminSupervisorsScreen> createState() => _AdminSupervisorsScreenState();
// }
//
// class _AdminSupervisorsScreenState extends State<AdminSupervisorsScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   Future<bool> _ensureAdmin() async {
//     final user = _auth.currentUser;
//     if (user == null) return false;
//     final me = await RoleManager.fetchUser(user.uid);
//     return me != null && RoleManager.isAdmin(me);
//   }
//
//   Stream<List<UserModel>> _streamDoctors() {
//     return _firestore
//         .collection('users')
//         .where('role', isEqualTo: RoleManager.roleDoctor)
//         .snapshots()
//         .map((s) => s.docs.map((d) => UserModel.fromMap(d.data())).toList());
//   }
//
//   Stream<List<UserModel>> _streamSupervisors() {
//     return _firestore
//         .collection('users')
//         .where('role', isEqualTo: RoleManager.roleSupervisor)
//         .snapshots()
//         .map((s) => s.docs.map((d) => UserModel.fromMap(d.data())).toList());
//   }
//
//   Future<void> _promoteToSupervisor(UserModel doctor) async {
//     await _firestore.collection('users').doc(doctor.uid).update({
//       'role': RoleManager.roleSupervisor,
//       'assignedDoctorIds': [],
//       'permissions': {
//         'viewCases': true,
//         'viewPrices': true,
//         'edit': true,
//         'delete': true,
//       },
//     });
//   }
//
//   Future<void> _demoteToDoctor(UserModel supervisor) async {
//     await _firestore.collection('users').doc(supervisor.uid).update({
//       'role': RoleManager.roleDoctor,
//       'assignedDoctorIds': FieldValue.delete(),
//       'permissions': FieldValue.delete(),
//     });
//   }
//
//   Future<void> _assignDoctor(String supervisorId, String doctorId) async {
//     await _firestore.collection('users').doc(supervisorId).update({
//       'assignedDoctorIds': FieldValue.arrayUnion([doctorId]),
//     });
//   }
//
//   Future<void> _removeDoctor(String supervisorId, String doctorId) async {
//     await _firestore.collection('users').doc(supervisorId).update({
//       'assignedDoctorIds': FieldValue.arrayRemove([doctorId]),
//     });
//   }
//
//   Future<void> _togglePermission(String supervisorId, String key, bool value) async {
//     await _firestore.collection('users').doc(supervisorId).set({
//       'permissions': { key: value },
//     }, SetOptions(merge: true));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: _ensureAdmin(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState != ConnectionState.done) {
//           return const Scaffold(body: Center(child: CircularProgressIndicator()));
//         }
//         if (snapshot.data != true) {
//           return const Scaffold(body: Center(child: Text('Unauthorized')));
//         }
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('إدارة المشرفين'),
//           ),
//           body: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.all(12.0),
//                       child: Text('الأطباء', style: TextStyle(fontWeight: FontWeight.bold)),
//                     ),
//                     Expanded(
//                       child: StreamBuilder<List<UserModel>>(
//                         stream: _streamDoctors(),
//                         builder: (context, snapshot) {
//                           if (!snapshot.hasData) {
//                             return const Center(child: CircularProgressIndicator());
//                           }
//                           final doctors = snapshot.data!;
//                           return ListView.builder(
//                             itemCount: doctors.length,
//                             itemBuilder: (context, index) {
//                               final d = doctors[index];
//                               return ListTile(
//                                 title: Text(d.name),
//                                 subtitle: Text(d.email),
//                                 trailing: ElevatedButton(
//                                   onPressed: () => _promoteToSupervisor(d),
//                                   child: const Text('ترقية لمشرف'),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const VerticalDivider(width: 1),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.all(12.0),
//                       child: Text('المشرفون', style: TextStyle(fontWeight: FontWeight.bold)),
//                     ),
//                     Expanded(
//                       child: StreamBuilder<List<UserModel>>(
//                         stream: _streamSupervisors(),
//                         builder: (context, snapshot) {
//                           if (!snapshot.hasData) {
//                             return const Center(child: CircularProgressIndicator());
//                           }
//                           final supervisors = snapshot.data!;
//                           return ListView.builder(
//                             itemCount: supervisors.length,
//                             itemBuilder: (context, index) {
//                               final s = supervisors[index];
//                               final assigned = s.assignedDoctorIds ?? [];
//                               return Card(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Expanded(child: Text(s.name)),
//                                           TextButton(
//                                             onPressed: () => _demoteToDoctor(s),
//                                             child: const Text('إرجاع لطبيب'),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 8),
//                                       const Text('الأطباء المعينون:'),
//                                       Wrap(
//                                         spacing: 8,
//                                         children: assigned
//                                             .map((id) => Chip(
//                                                   label: Text(id),
//                                                   onDeleted: () => _removeDoctor(s.uid, id),
//                                                 ))
//                                             .toList(),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       const Text('صلاحيات المشرف:'),
//                                       Builder(builder: (context) {
//                                         final perms = s.permissions ?? {};
//                                         return Column(
//                                           children: [
//                                             SwitchListTile(
//                                               title: const Text('عرض الحالات'),
//                                               value: perms['viewCases'] ?? true,
//                                               onChanged: (v) => _togglePermission(s.uid, 'viewCases', v),
//                                             ),
//                                             SwitchListTile(
//                                               title: const Text('عرض الأسعار'),
//                                               value: perms['viewPrices'] ?? true,
//                                               onChanged: (v) => _togglePermission(s.uid, 'viewPrices', v),
//                                             ),
//                                             SwitchListTile(
//                                               title: const Text('تعديل'),
//                                               value: perms['edit'] ?? true,
//                                               onChanged: (v) => _togglePermission(s.uid, 'edit', v),
//                                             ),
//                                             SwitchListTile(
//                                               title: const Text('حذف'),
//                                               value: perms['delete'] ?? true,
//                                               onChanged: (v) => _togglePermission(s.uid, 'delete', v),
//                                             ),
//                                           ],
//                                         );
//                                       }),
//                                       const SizedBox(height: 8),
//                                       Align(
//                                         alignment: Alignment.centerLeft,
//                                         child: ElevatedButton(
//                                           onPressed: () async {
//                                             // Simple dialog to type doctorId to assign
//                                             final controller = TextEditingController();
//                                             await showDialog(
//                                               context: context,
//                                               builder: (context) => AlertDialog(
//                                                 title: const Text('تعيين طبيب'),
//                                                 content: TextField(
//                                                   controller: controller,
//                                                   decoration: const InputDecoration(hintText: 'أدخل Doctor UID'),
//                                                 ),
//                                                 actions: [
//                                                   TextButton(
//                                                     onPressed: () => Navigator.pop(context),
//                                                     child: const Text('إلغاء'),
//                                                   ),
//                                                   ElevatedButton(
//                                                     onPressed: () async {
//                                                       final id = controller.text.trim();
//                                                       if (id.isNotEmpty) {
//                                                         await _assignDoctor(s.uid, id);
//                                                       }
//                                                       if (mounted) Navigator.pop(context);
//                                                     },
//                                                     child: const Text('حفظ'),
//                                                   ),
//                                                 ],
//                                               ),
//                                             );
//                                           },
//                                           child: const Text('تعيين طبيب'),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../core/auth/role_manager.dart';

class AdminSupervisorsScreen extends StatefulWidget {
  const AdminSupervisorsScreen({super.key});

  @override
  State<AdminSupervisorsScreen> createState() => _AdminSupervisorsScreenState();
}

class _AdminSupervisorsScreenState extends State<AdminSupervisorsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> _ensureAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final me = await RoleManager.fetchUser(user.uid);
    return me != null && RoleManager.isAdmin(me);
  }

  Stream<List<UserModel>> _streamDoctors() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: RoleManager.roleDoctor)
        .snapshots()
        .map((s) => s.docs.map((d) => UserModel.fromMap(d.data())).toList());
  }

  Stream<List<UserModel>> _streamSupervisors() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: RoleManager.roleSupervisor)
        .snapshots()
        .map((s) => s.docs.map((d) => UserModel.fromMap(d.data())).toList());
  }

  Future<void> _promoteToSupervisor(UserModel doctor) async {
    await _firestore.collection('users').doc(doctor.uid).update({
      'role': RoleManager.roleSupervisor,
      'assignedDoctorIds': [],
      'permissions': {
        'viewCases': true,
        'viewPrices': true,
        'edit': true,
        'delete': true,
      },
    });
  }

  Future<void> _demoteToDoctor(UserModel supervisor) async {
    await _firestore.collection('users').doc(supervisor.uid).update({
      'role': RoleManager.roleDoctor,
      'assignedDoctorIds': FieldValue.delete(),
      'permissions': FieldValue.delete(),
    });
  }

  Future<void> _assignDoctor(String supervisorId, String doctorId) async {
    await _firestore.collection('users').doc(supervisorId).update({
      'assignedDoctorIds': FieldValue.arrayUnion([doctorId]),
    });
  }

  Future<void> _removeDoctor(String supervisorId, String doctorId) async {
    await _firestore.collection('users').doc(supervisorId).update({
      'assignedDoctorIds': FieldValue.arrayRemove([doctorId]),
    });
  }

  Future<void> _togglePermission(String supervisorId, String key, bool value) async {
    await _firestore.collection('users').doc(supervisorId).set({
      'permissions': {key: value},
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _ensureAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data != true) {
          return const Scaffold(body: Center(child: Text('Unauthorized')));
        }

        return Scaffold(
          appBar: AppBar(title: const Text('إدارة المشرفين')),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800; // threshold for responsiveness

              final doctorsSection = Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('الأطباء', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: StreamBuilder<List<UserModel>>(
                        stream: _streamDoctors(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final doctors = snapshot.data!;
                          return ListView.builder(
                            itemCount: doctors.length,
                            itemBuilder: (context, index) {
                              final d = doctors[index];
                              return ListTile(
                                title: Text(d.name),
                                subtitle: Text(d.email),
                                trailing: ElevatedButton(
                                  onPressed: () => _promoteToSupervisor(d),
                                  child: const Text('ترقية لمشرف'),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );

              final supervisorsSection = Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('المشرفون', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: StreamBuilder<List<UserModel>>(
                        stream: _streamSupervisors(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final supervisors = snapshot.data!;
                          return ListView.builder(
                            itemCount: supervisors.length,
                            itemBuilder: (context, index) {
                              final s = supervisors[index];
                              final assigned = s.assignedDoctorIds ?? [];
                              return Card(
                                margin: const EdgeInsets.all(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: Text(s.name)),
                                          TextButton(
                                            onPressed: () => _demoteToDoctor(s),
                                            child: const Text('إرجاع لطبيب'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Text('الأطباء المعينون:'),
                                      Wrap(
                                        spacing: 8,
                                        children: assigned
                                            .map((id) => Chip(
                                          label: Text(id),
                                          onDeleted: () => _removeDoctor(s.uid, id),
                                        ))
                                            .toList(),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text('صلاحيات المشرف:'),
                                      Builder(builder: (context) {
                                        final perms = s.permissions ?? {};
                                        return Column(
                                          children: [
                                            SwitchListTile(
                                              title: const Text('عرض الحالات'),
                                              value: perms['viewCases'] ?? true,
                                              onChanged: (v) => _togglePermission(s.uid, 'viewCases', v),
                                            ),
                                            SwitchListTile(
                                              title: const Text('عرض الأسعار'),
                                              value: perms['viewPrices'] ?? true,
                                              onChanged: (v) => _togglePermission(s.uid, 'viewPrices', v),
                                            ),
                                            SwitchListTile(
                                              title: const Text('تعديل'),
                                              value: perms['edit'] ?? true,
                                              onChanged: (v) => _togglePermission(s.uid, 'edit', v),
                                            ),
                                            SwitchListTile(
                                              title: const Text('حذف'),
                                              value: perms['delete'] ?? true,
                                              onChanged: (v) => _togglePermission(s.uid, 'delete', v),
                                            ),
                                          ],
                                        );
                                      }),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final controller = TextEditingController();
                                            await showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('تعيين طبيب'),
                                                content: TextField(
                                                  controller: controller,
                                                  decoration: const InputDecoration(hintText: 'أدخل Doctor UID'),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('إلغاء'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      final id = controller.text.trim();
                                                      if (id.isNotEmpty) {
                                                        await _assignDoctor(s.uid, id);
                                                      }
                                                      if (mounted) Navigator.pop(context);
                                                    },
                                                    child: const Text('حفظ'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: const Text('تعيين طبيب'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );

              // 🧭 Responsive layout
              return isWide
                  ? Row(children: [doctorsSection, const VerticalDivider(width: 1), supervisorsSection])
                  : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: doctorsSection,
                    ),
                    const Divider(height: 1),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: supervisorsSection,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

