import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = ThemeData.light();
  ThemeData get currentTheme => _currentTheme;

  late SharedPreferences _prefs;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final bool isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _currentTheme = isDarkMode ? ThemeData.dark() : ThemeData.light();
    notifyListeners();
  }

  void toggleTheme() {
    if (_currentTheme == ThemeData.light()) {
      _currentTheme = ThemeData.dark();
      _prefs.setBool('isDarkMode', true);
    } else {
      _currentTheme = ThemeData.light();
      _prefs.setBool('isDarkMode', false);
    }
    notifyListeners();
  }
}