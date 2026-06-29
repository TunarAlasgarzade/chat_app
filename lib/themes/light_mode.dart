import 'package:flutter/material.dart';

ThemeData lightMode(Color color) {
  return ThemeData(
      colorScheme: ColorScheme.light(
      surface: Colors.grey.shade300,
      primary: color,
      secondary: Colors.yellow.shade300,
      tertiary: Colors.grey.shade500,
      inversePrimary: Colors.grey.shade900
    ),
  );
}
