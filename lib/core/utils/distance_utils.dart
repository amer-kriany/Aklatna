import 'package:latlong2/latlong.dart';

class DistanceUtils {
  static final Distance _distance = const Distance();

  /// Returns the distance between two coordinates in kilometers.
  ///
  /// Returns null if either location is missing.
  static double? calculateDistanceKm({
    required double? customerLatitude,
    required double? customerLongitude,
    required double? restaurantLatitude,
    required double? restaurantLongitude,
  }) {
    if (customerLatitude == null ||
        customerLongitude == null ||
        restaurantLatitude == null ||
        restaurantLongitude == null) {
      return null;
    }

    final customerLocation = LatLng(
      customerLatitude,
      customerLongitude,
    );

    final restaurantLocation = LatLng(
      restaurantLatitude,
      restaurantLongitude,
    );

    final distanceInMeters = _distance.as(
      LengthUnit.Meter,
      customerLocation,
      restaurantLocation,
    );

    return distanceInMeters / 1000;
  }

  /// Formats a distance nicely for displaying in the UI.
  static String formatDistance(double? distanceKm) {
    if (distanceKm == null) {
      return 'الموقع غير متوفر';
    }

    if (distanceKm < 1) {
      final meters = (distanceKm * 1000).round();
      return '$meters متر';
    }

    return '${distanceKm.toStringAsFixed(1)} كم';
  }
}