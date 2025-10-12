import 'package:flutter/material.dart';

import '../constants/app_colors.dart';


class AppTheme {
  // 🌞 Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Janna',
    useMaterial3: true,
    primaryColor: AppColor.lightPrimary,
    scaffoldBackgroundColor: AppColor.lightBackground,
    colorScheme: ColorScheme.light(
      primary: AppColor.lightPrimary,
      secondary: AppColor.lightSecondary,
      surface: AppColor.lightSurface,
      background: AppColor.lightBackground,
      onPrimary: Colors.white,
      onSurface: AppColor.lightTextPrimary,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColor.lightTextPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: AppColor.lightTextSecondary, fontSize: 14),
      titleLarge: TextStyle(color: AppColor.lightTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColor.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  // 🌙 Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Janna',
    useMaterial3: true,
    primaryColor: AppColor.darkPrimary,
    scaffoldBackgroundColor: AppColor.darkBackground,
    colorScheme: ColorScheme.dark(
      primary: AppColor.darkPrimary,
      secondary: AppColor.darkSecondary,
      surface: AppColor.darkSurface,
      background: AppColor.darkBackground,
      onPrimary: Colors.white,
      onSurface: AppColor.darkTextPrimary,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColor.darkTextPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: AppColor.darkTextSecondary, fontSize: 14),
      titleLarge: TextStyle(color: AppColor.darkTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColor.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.darkPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
