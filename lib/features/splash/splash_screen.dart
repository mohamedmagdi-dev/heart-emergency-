
import 'dart:async';


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heart_emergency/core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation controller for smooth fade-in and scaling effect
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    // Navigate to Home Screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      context.go('/');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive sizes using MediaQuery
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.6; // 40% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                AppStrings.appLogo, // replace with your logo
                  width: logoSize,
                  height: logoSize,
                ),
                SizedBox(height: size.height * 0.03),
                Text(
                  "Welcome",
                  style: TextStyle(
                      fontSize: size.width * 0.1,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
