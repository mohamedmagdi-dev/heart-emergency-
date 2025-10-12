import 'dart:ui';

import 'package:flutter/material.dart';

abstract class AppColor{
  static const circleAvatarColor1=Color(0xfffecaca);
  static const circleAvatarColor2=Color(0xffDBEAFE);
  static const circleAvatarColor3=Color(0xffF3E8FF);
  static const circleAvatarIconColor4=Color(0xff8427D6);

  static const textContainerColor=Color(0xffacb0b7);
  static const containerButtonColor=Color(0xffed4141);
  static const containerButtonColor2=Color(0xff2563EB);
  static const containerButtonColor3=Color(0xff9D46EC);


  // 🌞 Light Mode Colors
  static const Color lightPrimary = Color(0xFF1565C0); // Blue
  static const Color lightSecondary = Color(0xFF42A5F5); // Light Blue
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Colors.black;
  static const Color lightTextSecondary = Colors.grey;

  // 🌙 Dark Mode Colors
  static const Color darkPrimary = Color(0xFF0D47A1);
  static const Color darkSecondary = Color(0xFF1976D2);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Colors.grey;
}