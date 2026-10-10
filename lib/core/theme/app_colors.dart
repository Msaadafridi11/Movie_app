import 'package:flutter/material.dart';

/// Centralized modern color palette for CineStream (Netflix & Disney+ inspired)
class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFE50914); // Netflix Signature Crimson
  static const Color primaryLight = Color(0xFFFF3B4E);
  static const Color primaryDark = Color(0xFFB0060E);

  // Secondary Accents
  static const Color gold = Color(0xFFFFB800); // Star Rating & Awards
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentPurple = Color(0xFF7928CA);

  // Dark Theme Palette (Default)
  static const Color darkBackground = Color(0xFF0D0E15);
  static const Color darkSurface = Color(0xFF151724);
  static const Color darkCard = Color(0xFF1C1F30);
  static const Color darkCardElevated = Color(0xFF252940);
  static const Color darkDivider = Color(0xFF282C44);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA5ABC4);
  static const Color darkTextMuted = Color(0xFF6B728E);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF0F2F9);
  static const Color lightDivider = Color(0xFFE4E7F2);
  static const Color lightTextPrimary = Color(0xFF141724);
  static const Color lightTextSecondary = Color(0xFF5E6582);
  static const Color lightTextMuted = Color(0xFF8F96B3);

  // States & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Shimmer Gradients
  static const Color shimmerBaseDark = Color(0xFF1B1D2D);
  static const Color shimmerHighlightDark = Color(0xFF2B2E47);
  static const Color shimmerBaseLight = Color(0xFFE5E7EB);
  static const Color shimmerHighlightLight = Color(0xFFF3F4F6);

  // Gradients
  static const LinearGradient posterScrimGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Colors.black38,
      Colors.black87,
    ],
  );

  static const LinearGradient heroBannerScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x33000000),
      Color(0xCC0D0E15),
      Color(0xFF0D0E15),
    ],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF3B4E),
      Color(0xFFE50914),
      Color(0xFF990008),
    ],
  );
}
