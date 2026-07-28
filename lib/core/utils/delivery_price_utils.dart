class DeliveryPriceUtils {
  const DeliveryPriceUtils._();

  static const double _ratePerKm = 50;

  /// Calculates delivery price in SYP based on distance in km.
  /// Returns null if distance is null (location unavailable).
  ///
  /// ASSUMPTION (flagging this): rounded up to the nearest 500 ل.س for
  /// a cleaner displayed number (e.g. 3.4km * 50 = 170 -> rounds to 500).
  /// Tell me if you want raw unrounded values, or a different rounding
  /// step, or a minimum delivery fee floor.
  static double? calculateDeliveryPrice(double? distanceKm) {
    if (distanceKm == null) return null;

    final rawPrice = distanceKm * _ratePerKm;

    const roundingStep = 500;
    final rounded = (rawPrice / roundingStep).ceil() * roundingStep;

    return rounded.toDouble();
  }

  /// Formats delivery price nicely for UI, matching existing price
  /// formatting style used elsewhere in the app (e.g. "5,000 ل.س").
  static String formatDeliveryPrice(double? price) {
    if (price == null) return 'غير متوفر';

    if (price == 0) return 'مجاني';

    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );

    return '$formatted ل.س';
  }
}