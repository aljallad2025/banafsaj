import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Matches the website's design system exactly: Navy + Gold luxury theme
class AppColors {
  static const navy = Color(0xFF0C1A35);
  static const navy2 = Color(0xFF122040);
  static const navy3 = Color(0xFF1A2D52);
  static const gold = Color(0xFFC8A444);
  static const gold2 = Color(0xFFE6C060);
  static const gold3 = Color(0xFFF5D98A);
  static const off = Color(0xFFF7F4EF);
  static const border = Color(0xFFE9E3D8);
  static const text = Color(0xFF1C1C2E);
  static const muted = Color(0xFF8A8A9A);
  static const red = Color(0xFFE53935);
  static const green = Color(0xFF2E7D32);
}

class AppTheme {
  static ThemeData get light {
    final baseTextTheme = GoogleFonts.tajawalTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: GoogleFonts.tajawal().fontFamily,
      textTheme: baseTextTheme.apply(bodyColor: AppColors.text, displayColor: AppColors.navy),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gold,
        primary: AppColors.gold,
        secondary: AppColors.navy,
        surface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy),
        iconTheme: const IconThemeData(color: AppColors.navy),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          textStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          textStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.off,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
        hintStyle: GoogleFonts.tajawal(color: AppColors.muted, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    );
  }
}
