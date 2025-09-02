/// Theme configuration for the RivalX app.
/// 
/// This file defines the color scheme, typography, and component
/// themes used throughout the application. The design follows
/// a black, slate grey, and yellow color palette for a competitive
/// and motivational aesthetic.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central theme configuration class containing all styling
/// constants and theme data for the RivalX application.
class AppTheme {
  // RivalX Color Scheme - Slate Grey/Black and Yellow
  static const Color primaryBlack = Color(0xFF000000);
  static const Color slateGrey = Color(0xFF2F4F4F); // Dark Slate Grey
  static const Color lightSlateGrey = Color(0xFF708090); // Light Slate Grey  
  static const Color accentYellow = Color(0xFFFFD700);
  static const Color backgroundDark = Color(0xFF1C1C1E); // Dark background
  static const Color surfaceDark = Color(0xFF2C2C2E); // Dark surface
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color backgroundWhite = Color(0xFFFFFFFF); // For backward compatibility
  static const Color errorRed = Color(0xFFDC143C);
  static const Color successGreen = Color(0xFF32CD32);
  
  // Additional colors for ranks
  static const Color rankE = Color(0xFF8B4513); // Bronze
  static const Color rankD = Color(0xFFC0C0C0); // Silver
  static const Color rankC = Color(0xFFFFD700); // Gold
  static const Color rankB = Color(0xFF00CED1); // Turquoise
  static const Color rankA = Color(0xFF800080); // Purple
  static const Color rankS = Color(0xFFFF4500); // Orange Red
  static const Color rankSS = Color(0xFF1E90FF); // Dodger Blue
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: accentYellow,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: accentYellow,
        secondary: lightSlateGrey,
        surface: surfaceDark,
        background: backgroundDark,
        error: errorRed,
        onPrimary: primaryBlack,
        onSecondary: textWhite,
        onSurface: textWhite,
        onBackground: textWhite,
        onError: textWhite,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: slateGrey,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: accentYellow,
        ),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.roboto(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textWhite,
        ),
        displayMedium: GoogleFonts.roboto(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textWhite,
        ),
        displaySmall: GoogleFonts.roboto(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textWhite,
        ),
        headlineLarge: GoogleFonts.roboto(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textWhite,
        ),
        headlineMedium: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textWhite,
        ),
        headlineSmall: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textWhite,
        ),
        titleLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textWhite,
        ),
        titleMedium: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textWhite,
        ),
        titleSmall: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textWhite,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textWhite,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textWhite,
        ),
        bodySmall: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: lightSlateGrey,
        ),
        labelLarge: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textWhite,
        ),
        labelMedium: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textWhite,
        ),
        labelSmall: GoogleFonts.roboto(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: lightSlateGrey,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentYellow,
          foregroundColor: primaryBlack,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentYellow,
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlack,
          side: const BorderSide(color: primaryBlack),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightSlateGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightSlateGrey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: lightSlateGrey,
        ),
        hintStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: lightSlateGrey.withValues(alpha: 0.6),
        ),
      ),
      
      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: surfaceDark,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: slateGrey.withValues(alpha: 0.3),
        selectedColor: accentYellow,
        disabledColor: slateGrey.withValues(alpha: 0.1),
        labelStyle: GoogleFonts.roboto(
          fontSize: 12,
          color: textWhite,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: slateGrey,
        selectedItemColor: accentYellow,
        unselectedItemColor: lightSlateGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentYellow,
        foregroundColor: primaryBlack,
      ),
    );
  }

  /// Returns the color associated with a given rank.
  /// 
  /// @param rank The rank letter (E, D, C, B, A, S, SS)
  /// @return The color associated with the rank
  static Color getRankColor(String rank) {
    switch (rank) {
      case 'E':
        return rankE;
      case 'D':
        return rankD;
      case 'C':
        return rankC;
      case 'B':
        return rankB;
      case 'A':
        return rankA;
      case 'S':
        return rankS;
      case 'SS':
        return rankSS;
      default:
        return rankE;
    }
  }

  static const Color darkBackground = backgroundDark;
  static const Color surfaceColor = surfaceDark;
  static const Color textPrimary = textWhite;
  static const Color textSecondary = lightSlateGrey;
  static const Color borderColor = lightSlateGrey;
}