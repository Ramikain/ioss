import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  static const Color secondary = Color(0xFF757575);
  
  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  
  // Button colors
  static const Color buttonPrimary = Color(0xFF2196F3);
  static const Color buttonSecondary = Color(0xFF757575);
  static const Color buttonDisabled = Color(0xFFBDBDBD);
}

class AppTheme {
  // Legacy compatibility - these are used in some existing code
  static const Color primaryColor = AppColors.primary;
  static const Color successColor = AppColors.success;
  static const Color errorColor = AppColors.error;
  static const Color warningColor = AppColors.warning;
}