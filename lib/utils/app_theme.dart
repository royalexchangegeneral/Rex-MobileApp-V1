import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF1E2D64);
  static const Color accentOrange = Color(0xFFF47920);
  static const Color darkBackground = Color(0xFF0A0E1A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF1E1E1E);
  
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: white,
    fontFamily: GoogleFonts.poppins().fontFamily,
    
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: accentOrange,
      surface: white,
      background: white,
    ),
    
    textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: white,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: white,
        height: 1.2,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        color: white,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 12,
        color: white,
        height: 1.5,
      ),
    )),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: white,
        side: const BorderSide(color: white, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: darkBackground,
    fontFamily: GoogleFonts.poppins().fontFamily,
    
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: accentOrange,
      surface: darkGrey,
      background: darkBackground,
    ),
    
    textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: white,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: white,
        height: 1.2,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        color: white,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 12,
        color: white,
        height: 1.5,
      ),
    )),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: white,
        side: const BorderSide(color: white, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
