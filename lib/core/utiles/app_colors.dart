import 'package:flutter/material.dart';

class AppColors {
  // Primary Pharmacy Colors
  static const Color primary = Color(0xFF00A884); // Teal Green (Professional Pharmacy Look)
  static const Color secondary = Color(0xFF00796B);
  static const Color accent = Color(0xFF4DB6AC);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935); // More professional red
  static const Color warning = Color(0xFFFFB300);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF78909C);
  static const Color border = Color(0xFFECEFF1);

  // Gradient for a modern look
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00A884), Color(0xFF00796B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
