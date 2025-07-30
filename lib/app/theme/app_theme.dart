import 'package:flutter/material.dart';

class AppTheme {
  // Caribbean Colors
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color secondaryYellow = Color(0xFFFFEB3B);
  static const Color lightYellow = Color(0xFFFFF8E1);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightBlue = Color(0xFF87CEEB);
  static const Color oceanBlue = Color(0xFF1E90FF);
  static const Color sandColor = Color(0xFFF4E4BC);
  static const Color darkText = Color(0xFF2C3E50);
  static const Color lightText = Color(0xFF7F8C8D);

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.yellow,
      primaryColor: primaryYellow,
      scaffoldBackgroundColor: white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryYellow,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: darkText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightYellow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryYellow, width: 2),
        ),
        hintStyle: const TextStyle(color: lightText),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      cardTheme: CardTheme(
        color: white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadowColor: primaryYellow.withOpacity(0.3),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: darkText,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: darkText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: darkText,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: lightText,
          fontSize: 14,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryYellow,
        secondary: oceanBlue,
        surface: white,
        background: white,
        onPrimary: darkText,
        onSecondary: white,
        onSurface: darkText,
        onBackground: darkText,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.yellow,
      primaryColor: primaryYellow,
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C2C2C),
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: darkText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryYellow, width: 2),
        ),
        hintStyle: const TextStyle(color: lightText),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF2C2C2C),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadowColor: primaryYellow.withOpacity(0.3),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: white,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: lightText,
          fontSize: 14,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryYellow,
        secondary: oceanBlue,
        surface: Color(0xFF2C2C2C),
        background: Color(0xFF1A1A1A),
        onPrimary: darkText,
        onSecondary: white,
        onSurface: white,
        onBackground: white,
      ),
    );
  }
} 