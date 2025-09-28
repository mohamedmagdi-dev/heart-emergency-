import 'package:flutter/material.dart';

class PatientAuthScreen extends StatelessWidget {
  const PatientAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Auth')),
      body: const Center(child: Text('Patient Auth Screen')),
    );
  }
}
