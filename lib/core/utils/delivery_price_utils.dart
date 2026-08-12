class DeliveryPriceUtils {
  const DeliveryPriceUtils._();

  static const double _ratePerKm = 50;

  /// Calculates delivery price based on distance.
  static double? calculateDeliveryPrice(double? distanceKm) {
    if (distanceKm == null) {
      return null;
    }

    return distanceKm * _ratePerKm;
  }

  /// Formats delivery price for UI.
  static String formatDeliveryPrice(double? price) {
    if (price == null) {
      return 'غير متوفر';
    }

    if (price == 0) {
      return 'مجاني';
    }

    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );

    return '$formatted ل.س';
  }
}