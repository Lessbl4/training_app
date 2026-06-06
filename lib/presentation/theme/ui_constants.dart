import 'package:flutter/material.dart';

class AppColors {
  // OLED Black Theme
  static const Color background = Color(0xFF09090B);
  static const Color surface = Color(0xFF18181B);
  static const Color surfaceLight = Color(0xFF27272A);
  
  // Акценты (SpaceX / Cyberpunk vibe)
  static const Color primary = Color(0xFF3B82F6); // Apple Blue
  static const Color primaryVariant = Color(0xFF60A5FA);
  static const Color secondary = Color(0xFF8B5CF6); // Deep Purple
  static const Color accent = Color(0xFF06B6D4); // Cyan

  // Текст
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA1A1AA);
  
  // Успех / Ошибка
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);

  // Премиальные градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fireGradient = LinearGradient(
    colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Стеклянный эффект (Glassmorphism)
  static final Color glassBackground = Colors.white.withOpacity(0.05);
  static final Color glassBorder = Colors.white.withOpacity(0.1);
}

class AppPadding {
  static const double horizontal = 24.0;
  static const double vertical = 24.0;
  static const double small = 12.0;
  static const double large = 32.0;
}

class AppBorderRadius {
  static const double small = 12.0;
  static const double medium = 20.0;
  static const double large = 32.0;
  static BorderRadius get circularMedium => BorderRadius.circular(medium);
}