// // lib/providers/theme_cubit.dart
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// enum AppTheme { light, dark }
//
// class ThemeCubit extends Cubit<AppTheme> {
//   ThemeCubit() : super(AppTheme.light) {
//     _loadTheme();
//   }
//
//   static const String _themeKey = 'app_theme';
//
//   Future<void> _loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     final themeIndex = prefs.getInt(_themeKey) ?? 0;
//     emit(AppTheme.values[themeIndex]);
//   }
//
//   Future<void> toggleTheme() async {
//     final newTheme = state == AppTheme.light ? AppTheme.dark : AppTheme.light;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(_themeKey, newTheme.index);
//     emit(newTheme);
//   }
//
//   Future<void> setTheme(AppTheme theme) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(_themeKey, theme.index);
//     emit(theme);
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_emergency/core/theme/app_theme.dart';
import 'package:heart_emergency/core/utils/shared_preferences_helper.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(AppTheme.lightTheme) {
    _loadTheme();
  }

  bool get isDark => state.brightness == Brightness.dark;

  Future<void> _loadTheme() async {
    try {
      bool isDark = await SharedPreferencesHelper.getBool("isDarkMode");
      debugPrint('ThemeCubit: loadTheme isDark: $isDark');
      emit(isDark ? AppTheme.darkTheme : AppTheme.lightTheme);
    } catch (e) {
      debugPrint('ThemeCubit: Error loading theme: $e');
      emit(AppTheme.lightTheme);
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    try {
      debugPrint('ThemeCubit: toggleTheme toDark: $isDark');
      await SharedPreferencesHelper.setBool("isDarkMode", isDark);
      emit(isDark ? AppTheme.darkTheme : AppTheme.lightTheme);
    } catch (e) {
      debugPrint('ThemeCubit: Error toggling theme: $e');
    }
  }

  Future<void> setTheme(bool isDark) async {
    try {
      debugPrint('ThemeCubit: setTheme isDark: $isDark');
      await SharedPreferencesHelper.setBool("isDarkMode", isDark);
      emit(isDark ? AppTheme.darkTheme : AppTheme.lightTheme);
    } catch (e) {
      debugPrint('ThemeCubit: Error setting theme: $e');
    }
  }
}
