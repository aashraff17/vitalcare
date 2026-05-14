import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bg = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE0E6ED);
  static const Color divider = Color(0xFFE0E6ED);
  
  static const Color textHigh = Color(0xFF2C3E50);
  static const Color textMid = Color(0xFF7F8C8D);
  static const Color textLow = Color(0xFF95A5A6);
  
  static const Color red = Color(0xFFE53935);
  static const Color redLight = Color(0xFFFFEBEE);
  
  static const Color normal = Color(0xFF2ECC71);
  static const Color normalBg = Color(0xFFE8F8F5);
  
  static const Color warn = Color(0xFFF39C12);
  static const Color warnBg = Color(0xFFFEF9E7);
  
  static const Color danger = Color(0xFFE74C3C);
  static const Color dangerBg = Color(0xFFFDEDEC);
  
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0C000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    )
  ];
}

class AppTheme {
  static const Color primaryRed = AppColors.red;
  static const Color background = AppColors.bg;
  static const Color white = AppColors.surface;
  static const Color textPrimary = AppColors.textHigh;
  static const Color textSecondary = AppColors.textMid;
  static const Color border = AppColors.border;

  static const Color statusGreen = AppColors.normal;
  static const Color statusOrange = AppColors.warn;
  static const Color statusRed = AppColors.danger;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primaryRed,
      colorScheme: const ColorScheme.light(
        primary: primaryRed,
        surface: white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.inter(color: textPrimary),
        bodyMedium: GoogleFonts.inter(color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
