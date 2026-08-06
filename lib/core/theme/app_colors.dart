import 'package:flutter/material.dart';

/// Aklatna (أكلتنا) — App-wide color palette.
/// Single source of truth for all colors used across the app.
/// Never hardcode a Color(...) in a widget — add it here instead.
class AppColors {
  AppColors._(); // prevent instantiation

  // ---------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------
  static const Color primary = Color(0xFFED3D2F);
  static const Color primaryDark = Color(0xFFC42E22);
  static const Color primaryLight = Color(0xFFFCE9E7);

  // ---------------------------------------------------------------------
  // Neutrals
  // ---------------------------------------------------------------------
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F7F8);
  static const Color surfaceVariant = Color(0xFFF0F0F2);
  static const Color border = Color(0xFFE7E7EA);
  static const Color divider = Color(0xFFEDEDEF);
  static const Color location = Color(0xFF6C7278);
  static const Color greeting = Color(0xFFE96100);

  // ---------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------
  static const Color textPrimary = Color(0xFF1A1A1E);
  static const Color textSecondary = Color(0xFF797979);
  static const Color textHint = Color(0xFFA1A1A8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------
  // Status / Semantic
  // ---------------------------------------------------------------------
  static const Color success = Color(0xFF2E9E5B);
  static const Color successBg = Color(0xFFE6F5EC);

  static const Color warning = Color(0xFFE9A23B);
  static const Color warningBg = Color(0xFFFBF0DE);

  static const Color error = Color(0xFFD32F2F);
  static const Color errorBg = Color(0xFFFCE9E9);

  static const Color info = Color(0xFF3B82E9);
  static const Color infoBg = Color(0xFFE8F0FC);

  // ---------------------------------------------------------------------
  // Order status specific (matches OrderStatus enum)
  // ---------------------------------------------------------------------
  static const Color statusPending = warning;
  static const Color statusPreparing = info;
  static const Color statusReady = success;
  static const Color statusCompleted = Color(0xFF6B6B72);
  static const Color statusCancelled = error;
  static const Color statusOutForDelivery = primary;

  // ---------------------------------------------------------------------
  // Business state
  // ---------------------------------------------------------------------
  static const Color openBadge = success;
  static const Color closedBadge = Color(0xFF9B9BA1);

  // ---------------------------------------------------------------------
  // Misc / Overlays
  // ---------------------------------------------------------------------
  static const Color shadow = Color(0x1A000000); // 10% black
  static const Color overlay = Color(0x66000000); // 40% black
  static const Color disabled = Color(0xFFD1D1D6);
  static const Color shimmerBase = Color(0xFFEAEAEC);
  static const Color shimmerHighlight = Color(0xFFF5F5F6);
}
