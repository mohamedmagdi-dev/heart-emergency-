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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_emergency/core/cubits/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(isDark: false));

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    emit(ThemeState(isDark: isDark));
  }

  Future<void> setDark(bool isDark) async {
    emit(ThemeState(isDark: isDark));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }
}

