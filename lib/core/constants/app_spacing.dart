/// Aklatna (أكلتنا) — App-wide spacing & radius scale.
/// Never hardcode a padding/margin/radius number in a widget — use these.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  /// Standard horizontal page padding used across all screens.
  static const double pageHorizontal = lg;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  /// Fully rounded (pills, avatars, badges).
  static const double full = 999;
}

class AppSizes {
  AppSizes._();

  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  static const double avatarSm = 32;
  static const double avatarMd = 48;
  static const double avatarLg = 64;

  static const double buttonHeight = 52;
  static const double inputHeight = 52;

  /// Standard business/restaurant card image height on Home.
  static const double businessCardImageHeight = 120;
}
