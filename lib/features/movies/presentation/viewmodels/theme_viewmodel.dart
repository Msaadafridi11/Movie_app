import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/core/constants/app_constants.dart';

class ThemeViewModel extends ChangeNotifier {
  final SharedPreferences sharedPreferences;

  ThemeViewModel({required this.sharedPreferences}) {
    _loadThemeFromPrefs();
  }

  ThemeMode _themeMode = ThemeMode.dark; // Dark by default
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadThemeFromPrefs() {
    final savedTheme = sharedPreferences.getString(AppConstants.themeStorageKey);
    if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark; // Default
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await sharedPreferences.setString(
      AppConstants.themeStorageKey,
      _themeMode == ThemeMode.light ? 'light' : 'dark',
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await sharedPreferences.setString(
      AppConstants.themeStorageKey,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
  }
}
