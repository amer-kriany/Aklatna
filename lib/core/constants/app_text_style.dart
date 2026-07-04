import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aklatna (أكلتنا) — App-wide text style scale.
/// Font: Plus Jakarta Sans.
/// Never call TextStyle(...) directly in a widget — add/extend a style here.
///
/// NOTE: requires the `google_fonts` package in pubspec.yaml:
///   google_fonts: ^6.2.1
/// If you've bundled Plus Jakarta Sans locally instead, swap
/// GoogleFonts.plusJakartaSans(...) calls below for TextStyle(fontFamily: 'PlusJakartaSans', ...).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // ---------------------------------------------------------------------
  // Headings
  // ---------------------------------------------------------------------
  static TextStyle h1 = _base(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static TextStyle h2 = _base(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static TextStyle h3 = _base(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static TextStyle h4 = _base(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ---------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------
  static TextStyle bodyLarge = _base(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  static TextStyle bodyMedium = _base(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  static TextStyle bodySmall = _base(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ---------------------------------------------------------------------
  // Regular / paragraph text
  // ---------------------------------------------------------------------
  static TextStyle regularLarge = _base(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static TextStyle regularMedium = _base(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static TextStyle regularSmall = _base(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ---------------------------------------------------------------------
  // Captions / labels
  // ---------------------------------------------------------------------
  static TextStyle caption = _base(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  static TextStyle overline = _base(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  // ---------------------------------------------------------------------
  // Buttons
  // ---------------------------------------------------------------------
  static TextStyle buttonLarge = _base(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.greeting,
  );
  static TextStyle buttonMedium = _base(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
  static TextStyle buttonSmall = _base(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  // ---------------------------------------------------------------------
  // Price (numeric emphasis, e.g. SYP amounts)
  // ---------------------------------------------------------------------
  static TextStyle priceLarge = _base(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
  static TextStyle priceMedium = _base(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  // ---------------------------------------------------------------------
  // Hint / disabled
  // ---------------------------------------------------------------------
  static TextStyle hint = _base(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );
}
