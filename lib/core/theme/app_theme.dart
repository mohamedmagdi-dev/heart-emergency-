import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Janna',
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColor.lightPrimary,
      secondary: AppColor.lightSecondary,
      surface: AppColor.lightSurface,
      error: AppColor.lightError,
      onPrimary: AppColor.lightOnPrimary,
      onSecondary: AppColor.lightOnSecondary,
      onSurface: AppColor.lightOnSurface,
      onError: AppColor.lightOnError,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.lightPrimary,
      foregroundColor: AppColor.lightOnPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.lightPrimary,
        foregroundColor: AppColor.lightOnPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.lightPrimary, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColor.lightSurface,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Janna',
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColor.darkPrimary,
      secondary: AppColor.darkSecondary,
      surface: AppColor.darkSurface,
      error: AppColor.darkError,
      onPrimary: AppColor.darkOnPrimary,
      onSecondary: AppColor.darkOnSecondary,
      onSurface: AppColor.darkOnSurface,
      onError: AppColor.darkOnError,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.darkSurface,
      foregroundColor: AppColor.darkOnSurface,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.darkPrimary,
        foregroundColor: AppColor.darkOnPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.darkPrimary, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[800],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColor.darkSurface,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}
