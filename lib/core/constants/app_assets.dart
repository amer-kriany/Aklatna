/// Aklatna (أكلتنا) — App-wide asset path constants.
///
/// FOLDER STRUCTURE (create these under your project root):
///
/// assets/
/// ├── images/
/// │   ├── logo.png                    (full color logo, used on splash/login)
/// │   ├── logo_white.png               (white version, for dark/colored backgrounds)
/// │   ├── placeholder_business.png     (fallback when a business has no cover_url)
/// │   ├── placeholder_food.png         (fallback when a menu item has no photo_url)
/// │   └── onboarding_1.png .. onboarding_3.png   (optional, if you add onboarding)
/// │
/// ├── icons/                          (small UI icons, svg preferred — flutter_svg)
/// │   ├── ic_home.svg
/// │   ├── ic_search.svg
/// │   ├── ic_cart.svg
/// │   ├── ic_orders.svg
/// │   ├── ic_profile.svg
/// │   ├── ic_delivery.svg
/// │   ├── ic_pickup.svg
/// │   ├── ic_location.svg
/// │   ├── ic_phone.svg
/// │   ├── ic_clock.svg
/// │   └── ic_star.svg
/// │
/// └── illustrations/                  (larger empty-state / feedback graphics)
///     ├── empty_cart.svg
///     ├── empty_orders.svg
///     ├── empty_search.svg
///     ├── no_connection.svg
///     └── order_success.svg
///
/// PUBSPEC.YAML — add under flutter:
///   flutter:
///     assets:
///       - assets/images/
///       - assets/icons/
///       - assets/illustrations/
///
/// If you use PNG instead of SVG for icons/illustrations, just change the
/// extensions below (.svg -> .png) — everything else stays the same.
class AppAssets {
  AppAssets._();

  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _illustrations = 'assets/illustrations';

  // ---------------------------------------------------------------------
  // Images
  // ---------------------------------------------------------------------
  static const String logo = '$_images/logo.png';
  static const String logoWhite = '$_images/logo_white.png';
  static const String placeholderBusiness = '$_images/placeholder_business.png';
  static const String placeholderFood = '$_images/placeholder_food.png';

  // ---------------------------------------------------------------------
  // Icons
  // ---------------------------------------------------------------------
  static const String icHome = '$_icons/ic_home.svg';
  static const String icSearch = '$_icons/ic_search.svg';
  static const String icCart = '$_icons/ic_cart.svg';
  static const String icOrders = '$_icons/ic_orders.svg';
  static const String icProfile = '$_icons/ic_profile.svg';
  static const String icDelivery = '$_icons/ic_delivery.svg';
  static const String icPickup = '$_icons/ic_pickup.svg';
  static const String icLocation = '$_icons/ic_location.svg';
  static const String icPhone = '$_icons/ic_phone.svg';
  static const String icClock = '$_icons/ic_clock.svg';
  static const String icStar = '$_icons/ic_star.svg';

  // ---------------------------------------------------------------------
  // Illustrations (empty states / feedback)
  // ---------------------------------------------------------------------
  static const String emptyCart = '$_illustrations/empty_cart.svg';
  static const String emptyOrders = '$_illustrations/empty_orders.svg';
  static const String emptySearch = '$_illustrations/empty_search.svg';
  static const String noConnection = '$_illustrations/no_connection.svg';
  static const String orderSuccess = '$_illustrations/order_success.svg';
}