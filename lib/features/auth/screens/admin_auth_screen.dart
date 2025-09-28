import 'package:flutter/material.dart';

class AdminAuthScreen extends StatelessWidget {
  const AdminAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Auth')),
      body: const Center(child: Text('Admin Auth Screen')),
    );
  }
}
