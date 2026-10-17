import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/theme_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ThemeViewModel should default to ThemeMode.dark when no preference exists', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final viewModel = ThemeViewModel(sharedPreferences: prefs);

    expect(viewModel.themeMode, ThemeMode.dark);
    expect(viewModel.isDarkMode, true);
  });

  test('ThemeViewModel should load ThemeMode.light when "light" is stored', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.themeStorageKey: 'light',
    });
    final prefs = await SharedPreferences.getInstance();
    final viewModel = ThemeViewModel(sharedPreferences: prefs);

    expect(viewModel.themeMode, ThemeMode.light);
    expect(viewModel.isDarkMode, false);
  });

  test('toggleTheme should alternate theme and persist value to SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final viewModel = ThemeViewModel(sharedPreferences: prefs);

    expect(viewModel.isDarkMode, true);

    // Toggle to Light
    await viewModel.toggleTheme();
    expect(viewModel.themeMode, ThemeMode.light);
    expect(viewModel.isDarkMode, false);
    expect(prefs.getString(AppConstants.themeStorageKey), 'light');

    // Toggle back to Dark
    await viewModel.toggleTheme();
    expect(viewModel.themeMode, ThemeMode.dark);
    expect(viewModel.isDarkMode, true);
    expect(prefs.getString(AppConstants.themeStorageKey), 'dark');
  });

  test('setTheme should update themeMode directly and persist', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final viewModel = ThemeViewModel(sharedPreferences: prefs);

    await viewModel.setTheme(ThemeMode.light);
    expect(viewModel.themeMode, ThemeMode.light);
    expect(prefs.getString(AppConstants.themeStorageKey), 'light');
  });
}
