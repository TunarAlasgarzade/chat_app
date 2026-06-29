import 'package:chat_app/themes/dark_mode.dart';
import 'package:chat_app/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  Color _color = Colors.green;

  ThemeData get themeData => _isDarkMode ? darkMode(_color) : lightMode(_color);
  bool get isDarkMode => _isDarkMode;
  Color get color => _color;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool("isDarkMode") ?? false;
    final savedColor = prefs.getInt("accentColor");
    if (savedColor != null) {
      _color = Color(savedColor);
    }
    notifyListeners();
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = !_isDarkMode;
    prefs.setBool("isDarkMode", _isDarkMode);
    notifyListeners();
  }

  void changeColor(Color newColor) async {
    final prefs = await SharedPreferences.getInstance();
    _color = newColor;
    prefs.setInt("accentColor", newColor.toARGB32());
    notifyListeners();
  }
}