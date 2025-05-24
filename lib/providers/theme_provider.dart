import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkTheme') ?? false;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = themeNotifier.value == ThemeMode.dark;
    themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
    await prefs.setBool('isDarkTheme', !isDark);
  }
}



/* import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDark = prefs.getBool('isDarkMode');
    _themeMode = isDark == true ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
 */