import 'package:latlong2/latlong.dart';

class DeliveryCalculator {
  static double calculateDistanceKm({
    required double customerLatitude,
    required double customerLongitude,
    required double restaurantLatitude,
    required double restaurantLongitude,
  }) {
    final distance = const Distance();

    final meters = distance.as(
      LengthUnit.Meter,
      LatLng(customerLatitude, customerLongitude),
      LatLng(restaurantLatitude, restaurantLongitude),
    );

    return meters / 1000;
  }
}