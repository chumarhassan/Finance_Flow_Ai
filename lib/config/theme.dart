import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

// THEME CONFIGURATION


class AppTheme {
  AppTheme._();

 
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    brightness: Brightness.light,

    primaryColor: AppColors.primaryNavy,

    scaffoldBackgroundColor: AppColors.lightBackground,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryNavy,     
      secondary: AppColors.primaryYellow,   
      tertiary: AppColors.primaryPink,      
      surface: AppColors.white,            
      error: AppColors.error,              
      onPrimary: AppColors.white,           
      onSecondary: AppColors.primaryNavy,   
      onSurface: AppColors.textPrimaryLight, 
      onError: AppColors.white,            
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.primaryNavy,
      elevation: 0, 
      centerTitle: true, 
      iconTheme: const IconThemeData(color: AppColors.primaryNavy),
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.primaryNavy,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 2, 
      shadowColor: AppColors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), 
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.primaryNavy,
        elevation: 0, 
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryNavy,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryNavy,
        side: const BorderSide(color: AppColors.primaryNavy, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryNavy, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.poppins(
        color: AppColors.primaryGray,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.poppins(
        color: AppColors.textSecondaryLight,
        fontSize: 14,
      ),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),

      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),

      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),

      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryLight,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryLight,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondaryLight,
      ),

      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryLight,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryLight,
      ),
    ),

    iconTheme: const IconThemeData(
      color: AppColors.primaryNavy,
      size: 24,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryYellow,
      foregroundColor: AppColors.primaryNavy,
      elevation: 4,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryNavy,
      unselectedItemColor: AppColors.primaryGray,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.primaryGray,
      thickness: 1,
      space: 1,
    ),
  );


  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryYellow,
    scaffoldBackgroundColor: AppColors.darkBackground,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryYellow,
      secondary: AppColors.primaryPink,
      tertiary: AppColors.primaryRose,
      surface: AppColors.primaryPurple,
      error: AppColors.error,
      onPrimary: AppColors.primaryNavy,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimaryDark,
      onError: AppColors.white,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryNavy,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.white),
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.primaryPurple,
      elevation: 0,
      shadowColor: AppColors.primaryYellow.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.primaryNavy,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryYellow,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryYellow,
        side: const BorderSide(color: AppColors.primaryYellow, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.primaryPurple,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.poppins(
        color: AppColors.primaryGray,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.poppins(
        color: AppColors.textSecondaryDark,
        fontSize: 14,
      ),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryDark,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondaryDark,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryDark,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryDark,
      ),
    ),

    iconTheme: const IconThemeData(
      color: AppColors.white,
      size: 24,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryYellow,
      foregroundColor: AppColors.primaryNavy,
      elevation: 4,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.primaryNavy,
      selectedItemColor: AppColors.primaryYellow,
      unselectedItemColor: AppColors.primaryGray,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    dividerTheme: DividerThemeData(
      color: AppColors.primaryGray.withOpacity(0.2),
      thickness: 1,
      space: 1,
    ),
  );
}