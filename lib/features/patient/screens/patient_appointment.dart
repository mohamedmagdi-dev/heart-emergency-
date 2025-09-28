import 'package:flutter/material.dart';

class PatientAppointmentScreen extends StatelessWidget {
  const PatientAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Appointment')),
      body: const Center(child: Text('Patient Appointment Screen')),
    );
  }
}
