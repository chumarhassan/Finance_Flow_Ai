import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🎨 THEME PROVIDER
// Manages theme mode (light/dark) and persists user preference

class ThemeProvider extends ChangeNotifier {
  // Theme mode - defaults to system
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // Is dark mode enabled?
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Check system brightness
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  // SharedPreferences key
  static const String _themeKey = 'theme_mode';

  // Constructor - load saved theme
  ThemeProvider() {
    _loadTheme();
  }

  // ==================== THEME MANAGEMENT ====================

  /// Load saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeKey);

      if (themeModeIndex != null) {
        _themeMode = ThemeMode.values[themeModeIndex];
        notifyListeners();
      }
    } catch (e) {
      // If error, use system theme
      _themeMode = ThemeMode.system;
    }
  }

  /// Save theme to SharedPreferences
  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
    } catch (e) {
      // Silently fail - theme will reset on restart
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();
    await _saveTheme();
  }

  /// Toggle between light and dark mode (ignoring system)
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  /// Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Set system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Check if currently using light theme
  bool get isLightMode => _themeMode == ThemeMode.light;

  /// Check if currently using system theme
  bool get isSystemMode => _themeMode == ThemeMode.system;
}