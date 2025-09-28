import 'package:flutter/material.dart';

class DoctorAuthScreen extends StatelessWidget {
  const DoctorAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Auth')),
      body: const Center(child: Text('Doctor Auth Screen')),
    );
  }
}
