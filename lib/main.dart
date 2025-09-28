import 'package:flutter/material.dart';
import 'config/router.dart';

void main() {
  runApp(const EmergencyApp());
}

class EmergencyApp extends StatelessWidget {
  const EmergencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'من قلب الطوارئ',
      routerConfig: appRouter,
      theme: ThemeData.light(),
    );
  }
}
