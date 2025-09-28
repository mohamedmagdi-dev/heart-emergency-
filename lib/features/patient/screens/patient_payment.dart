import 'package:flutter/material.dart';

class PatientPaymentScreen extends StatelessWidget {
  const PatientPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Payment')),
      body: const Center(child: Text('Patient Payment Screen')),
    );
  }
}
