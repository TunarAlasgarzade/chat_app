import 'package:flutter/material.dart';

ThemeData darkMode(Color color) {
  return ThemeData(
      colorScheme: ColorScheme.dark(
      surface: Colors.grey.shade900,
      primary: color,
      secondary: Colors.grey.shade800,
      tertiary: Colors.grey.shade700,
      inversePrimary: Colors.grey.shade300,
    ),
  );
}
