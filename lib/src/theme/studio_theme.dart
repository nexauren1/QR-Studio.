import 'package:flutter/material.dart';

class StudioColors {
  static const background = Color(0xFF08091B);
  static const surface = Color(0xFF11142B);
  static const surface2 = Color(0xFF191D3B);
  static const border = Color(0xFF292D55);
  static const purple = Color(0xFF922BFF);
  static const violet = Color(0xFF5F31F4);
  static const blue = Color(0xFF276BFF);
  static const cyan = Color(0xFF00C8F5);
  static const green = Color(0xFF21D6A0);
  static const orange = Color(0xFFFFA629);
  static const muted = Color(0xFFA8ACCA);
  static const text = Color(0xFFF5F4FF);
}

class StudioTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: StudioColors.background,
      colorScheme: const ColorScheme.dark(
        primary: StudioColors.purple,
        secondary: StudioColors.cyan,
        surface: StudioColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: StudioColors.background,
        foregroundColor: StudioColors.text,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: StudioColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StudioColors.surface2,
        hintStyle: const TextStyle(color: StudioColors.muted),
        labelStyle: const TextStyle(color: StudioColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: StudioColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: StudioColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: StudioColors.purple, width: 1.5),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: StudioColors.surface,
        indicatorColor: Color(0x333E2BFF),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      dividerColor: StudioColors.border,
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F6FC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: StudioColors.purple,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F6FC),
        foregroundColor: Color(0xFF17182B),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEDEFFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
