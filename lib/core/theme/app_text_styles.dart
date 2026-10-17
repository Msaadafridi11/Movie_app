import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/core/theme/app_colors.dart';

/// Centralized Poppins typography system complying with Material 3 type scales
class AppTextStyles {
  // Display Styles
  static TextStyle displayLarge({Color? color}) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: color ?? AppColors.darkTextPrimary,
      );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: color ?? AppColors.darkTextPrimary,
      );

  // Headline Styles
  static TextStyle headlineLarge({Color? color}) => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: color ?? AppColors.darkTextPrimary,
      );

  static TextStyle headlineMedium({Color? color}) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: color ?? AppColors.darkTextPrimary,
      );

  static TextStyle headlineSmall({Color? color}) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: color ?? AppColors.darkTextPrimary,
      );

  // Title Styles
  static TextStyle titleLarge({Color? color}) => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: color ?? AppColors.darkTextPrimary,
      );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: color ?? AppColors.darkTextPrimary,
      );

  static TextStyle titleSmall({Color? color}) => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: color ?? AppColors.darkTextSecondary,
      );

  // Body Styles
  static TextStyle bodyLarge({Color? color, double height = 1.5}) =>
      GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: height,
        color: color ?? AppColors.darkTextSecondary,
      );

  static TextStyle bodyMedium({Color? color, double height = 1.4}) =>
      GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: height,
        color: color ?? AppColors.darkTextSecondary,
      );

  static TextStyle bodySmall({Color? color, double height = 1.3}) =>
      GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: height,
        color: color ?? AppColors.darkTextMuted,
      );

  // Label & Caption Styles
  static TextStyle labelLarge({Color? color}) => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color ?? Colors.white,
      );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color ?? AppColors.darkTextSecondary,
      );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: color ?? AppColors.darkTextMuted,
      );

  // Section Headers
  static TextStyle sectionHeader({Color? color}) => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: color ?? AppColors.primary,
      );
}
