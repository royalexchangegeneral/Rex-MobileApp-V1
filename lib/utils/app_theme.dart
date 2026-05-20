import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF1E2D64);
  static const Color primaryNavy = Color(0xFF1E2D64); // Alias for primaryBlue
  static const Color accentOrange = Color(0xFFF47920);
  static const Color darkBackground = Color(0xFF0A0E1A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF1E1E1E);
  static const Color lightDisabledButton = Color(0xFFE0E0E0);
  static const Color lightDisabledButtonText = Color(0xFF424242);
  static const Color darkDisabledButton = Color(0xFFCBD5E1);
  static const Color darkDisabledButtonText = Color(0xFF0F172A);
  static const Color darkBottomNavBackground = Color(0xFF111827);
  static const Color darkBottomNavUnselected = Color(0xFFCBD5E1);

  static Color disabledButtonColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkDisabledButton
          : lightDisabledButton;

  static Color disabledButtonTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkDisabledButtonText
          : lightDisabledButtonText;

  static Color bottomNavBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBottomNavBackground
          : white;

  static Color bottomNavSelectedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? accentOrange
          : primaryNavy;

  static Color bottomNavUnselectedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBottomNavUnselected
          : Colors.grey;

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: white,
    fontFamily: GoogleFonts.poppins().fontFamily,

    // AppBar theme for light mode
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      elevation: 0,
    ),

    // Card theme for light mode
    cardTheme: const CardThemeData(
      color: white,
      elevation: 2,
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
    ),

    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: accentOrange,
      surface: white,
      onSurface: Colors.black,
    ),

    textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        height: 1.2,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        color: Colors.black,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 12,
        color: Colors.black,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 11,
        color: Colors.black,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    )),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        disabledBackgroundColor: lightDisabledButton,
        disabledForegroundColor: lightDisabledButtonText,
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
        foregroundColor: primaryBlue,
        disabledForegroundColor: lightDisabledButtonText,
        side: const BorderSide(color: primaryBlue, width: 1.5),
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

    bottomAppBarTheme: const BottomAppBarThemeData(
      color: white,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: primaryNavy,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      selectedIconTheme: IconThemeData(color: primaryNavy),
      unselectedIconTheme: IconThemeData(color: Colors.grey),
      selectedLabelStyle: TextStyle(fontSize: 11),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: darkBackground,
    fontFamily: GoogleFonts.poppins().fontFamily,

    // AppBar theme for dark mode
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: white,
      iconTheme: IconThemeData(color: accentOrange),
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card theme for dark mode
    cardTheme: const CardThemeData(
      color: darkGrey,
      elevation: 2,
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: accentOrange,
      surface: darkGrey,
      onSurface: white,
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
      bodySmall: TextStyle(
        fontSize: 11,
        color: white,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: white,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: white,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: white,
      ),
    )),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        disabledBackgroundColor: darkDisabledButton,
        disabledForegroundColor: darkDisabledButtonText,
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
        foregroundColor: primaryBlue,
        disabledForegroundColor: darkDisabledButton,
        side: const BorderSide(color: primaryBlue, width: 1.5),
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

    bottomAppBarTheme: const BottomAppBarThemeData(
      color: darkBottomNavBackground,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBottomNavBackground,
      selectedItemColor: accentOrange,
      unselectedItemColor: darkBottomNavUnselected,
      type: BottomNavigationBarType.fixed,
      selectedIconTheme: IconThemeData(color: accentOrange),
      unselectedIconTheme: IconThemeData(color: darkBottomNavUnselected),
      selectedLabelStyle: TextStyle(fontSize: 11),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
  );
}
