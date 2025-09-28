import 'package:flutter/material.dart';

class TestDashboard extends StatelessWidget {
  const TestDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Dashboard')),
      body: const Center(child: Text('Test Dashboard')),
    );
  }
}
