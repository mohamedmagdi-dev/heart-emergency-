// Firebase Welcome Screen with Role Selection
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FirebaseWelcomeScreen extends StatelessWidget {
  const FirebaseWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              const Icon(
                Icons.favorite,
                size: 120,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              
              // App title
              const Text(
                'من قلب الطوارئ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Janna',
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              
              const Text(
                'خدمات طبية طارئة سريعة وآمنة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Janna',
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 64),
              
              // Patient button
              _RoleCard(
                icon: Icons.person,
                title: 'مريض',
                subtitle: 'احصل على رعاية طبية طارئة',
                color: Colors.blue,
                onTap: () => context.go('/patient/auth'),
              ),
              const SizedBox(height: 16),
              
              // Doctor button
              _RoleCard(
                icon: Icons.local_hospital,
                title: 'طبيب',
                subtitle: 'قدم خدمات طبية طارئة',
                color: Colors.green,
                onTap: () => context.go('/doctor/auth'),
              ),
              const SizedBox(height: 16),
              
              // Admin button
              _RoleCard(
                icon: Icons.admin_panel_settings,
                title: 'مسؤول',
                subtitle: 'إدارة النظام',
                color: Colors.orange,
                onTap: () => context.go('/admin/login'),
              ),
              
              const SizedBox(height: 32),
              
              // Info text
              Text(
                'اختر نوع حسابك للمتابعة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Janna',
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Janna',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Janna',
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

