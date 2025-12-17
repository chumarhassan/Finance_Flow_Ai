import 'package:flutter/material.dart';

// APP COLOR PALETTE
// This file contains ALL colors used in the app
class AppColors {
  AppColors._();


  static const Color primaryYellow = Color(0xFFf9b22c);

  
  static const Color primaryPink = Color(0xFFfc5484);


  static const Color primaryNavy = Color(0xFF040b44);


  static const Color primaryRose = Color(0xFFc0878e);

 
  static const Color primaryGray = Color(0xFFb2b4b8);

  static const Color primaryPurple = Color(0xFF453964);

  static const LinearGradient yellowPinkGradient = LinearGradient(
    colors: [primaryYellow, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyPurpleGradient = LinearGradient(
    colors: [primaryNavy, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rosePinkGradient = LinearGradient(
    colors: [primaryRose, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

 
  static const Color success = Color(0xFF4caf50);

  static const Color error = Color(0xFFf44336);

  static const Color warning = Color(0xFFff9800);

  static const Color info = Color(0xFF2196f3);

  
  static const Color white = Color(0xFFffffff);

  static const Color black = Color(0xFF000000);

  static const Color lightBackground = Color(0xFFf5f5f5);

  static const Color darkBackground = Color(0xFF0a0e27);

  static const Color textPrimaryLight = Color(0xFF212121);

  static const Color textSecondaryLight = Color(0xFF757575);

  static const Color textPrimaryDark = Color(0xFFffffff);

  static const Color textSecondaryDark = Color(0xFFb0b0b0);


  static const List<Color> chartColors = [
    primaryYellow,
    primaryPink,
    primaryRose,
    primaryPurple,
    primaryNavy,
    primaryGray,
  ];

  static const Map<String, Color> categoryColors = {
    'Food & Dining': primaryRose,
    'Transportation': primaryPurple,
    'Shopping': primaryPink,
    'Bills & Utilities': primaryNavy,
    'Entertainment': primaryYellow,
    'Healthcare': primaryGray,
    'Education': primaryPurple,
    'Other': primaryGray,
  };

  
  static Color getTextColorForBackground(Color backgroundColor) {
  
    final double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimaryLight : textPrimaryDark;
  }

  
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}