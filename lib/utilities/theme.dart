import 'package:flutter/material.dart';

class AppTheme {
  // Defining the app colors here
  static const Color primaryColor = Color(0xFF1A1A2E);
  static const Color inputFieldColor = Color(0xFFD7DAE5);
  static const Color navBgColor = Color(0xFFD9D9D9);
  static const Color gradientStart = Color(0xFF1A1A2E);
  static const Color gradientEnd = Color(0xFFE5E5E8);
  static const Color textColorDark = Color(0xFF000000);
  static const Color textColorLight = Color(0xFFFFFFFF);
  static const Color transparentColor = Color(0x00000000);

  // defining font family
  static const String fontFamily = "Montserrat";

  // defining light theme

  static ThemeData theme = ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: fontFamily,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, color: textColorDark),
        bodyMedium: TextStyle(fontSize: 14, color: textColorDark),
      ));
}

class AppGradient {
  static BoxDecoration get gradientBG {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}