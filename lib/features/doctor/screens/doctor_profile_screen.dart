import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('لم يتم العثور على المستخدم'));
          }
          return _buildProfile(context, user);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.green[100],
                  backgroundImage: user.profileImage != null ? NetworkImage(user.profileImage!) : null,
                  child: user.profileImage == null
                      ? Text(
                          user.name.isNotEmpty ? user.name.substring(0, 1) : 'د',
                          style: TextStyle(color: Colors.green[700], fontSize: 24, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('د. ${user.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      if (user.specialization != null) ...[
                        const SizedBox(height: 4),
                        Text(user.specialization!, style: const TextStyle(color: Colors.grey)),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.verified, color: (user.verified ?? false) ? Colors.green : Colors.grey, size: 18),
                          const SizedBox(width: 6),
                          Text((user.verified ?? false) ? 'موثق' : 'غير موثق', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _infoTile(title: 'البريد الإلكتروني', value: user.email, icon: Icons.email),
          _infoTile(title: 'رقم الهاتف', value: user.phone, icon: Icons.phone),
          if (user.location != null)
            _infoTile(
              title: 'الموقع',
              value: '(${user.location!.latitude.toStringAsFixed(5)}, ${user.location!.longitude.toStringAsFixed(5)})',
              icon: Icons.location_on,
            ),
          if (user.rating != null)
            _infoTile(title: 'التقييم', value: user.rating!.toStringAsFixed(1), icon: Icons.star),
          if (user.certificates != null && user.certificates!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الشهادات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...user.certificates!.map((c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(c, style: const TextStyle(color: Colors.blue)),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoTile({required String title, required String value, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


