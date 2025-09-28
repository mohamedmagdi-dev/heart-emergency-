import 'package:flutter/material.dart';

class EmergencyRequestScreen extends StatelessWidget {
  const EmergencyRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Request')),
      body: const Center(child: Text('Emergency Request Screen')),
    );
  }
}
