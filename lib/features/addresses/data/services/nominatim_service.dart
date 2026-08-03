import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class NominatimService {
  static const String _baseUrl =
      'https://nominatim.openstreetmap.org/reverse';

  Future<ReverseAddress?> reverseGeocode(LatLng location) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'lat': location.latitude.toString(),
        'lon': location.longitude.toString(),
        'format': 'jsonv2',
        'addressdetails': '1',
        'zoom': '18',
        'accept-language': 'ar,en',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'User-Agent': 'Aklatna/1.0 (aklatna-app)',
        'Accept': 'application/json',
        'Accept-Language': 'ar,en',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Reverse geocoding failed: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      return null;
    }

    final address = data['address'];

    if (address is! Map<String, dynamic>) {
      return null;
    }

    debugPrint('================ NOMINATIM ================');
    debugPrint('FULL RESPONSE: $data');
    debugPrint('ADDRESS: $address');
    debugPrint('ROAD: ${address['road']}');
    debugPrint('PEDESTRIAN: ${address['pedestrian']}');
    debugPrint('RESIDENTIAL: ${address['residential']}');
    debugPrint('HOUSE NUMBER: ${address['house_number']}');
    debugPrint('CITY: ${address['city']}');
    debugPrint('TOWN: ${address['town']}');
    debugPrint('VILLAGE: ${address['village']}');
    debugPrint('MUNICIPALITY: ${address['municipality']}');
    debugPrint('DISTRICT: ${address['district']}');
    debugPrint('SUBURB: ${address['suburb']}');
    debugPrint('QUARTER: ${address['quarter']}');
    debugPrint('NEIGHBOURHOOD: ${address['neighbourhood']}');
    debugPrint('============================================');

    String? value(String key) {
      final result = address[key];

      if (result == null) return null;

      final text = result.toString().trim();

      if (text.isEmpty) return null;

      return text;
    }

    // -------------------------
    // STREET
    // -------------------------
    //
    // Nominatim doesn't always return "road".
    // Depending on the selected location it might return:
    // road, residential, pedestrian, etc.
    //
    final street =
        value('road') ??
        value('pedestrian') ??
        value('residential') ??
        value('street') ??
        value('path') ??
        value('footway') ??
        value('neighbourhood') ??
        value('quarter') ??
        value('suburb') ??
        value('district');

    // -------------------------
    // CITY
    // -------------------------
    //
    // The important part:
    // Don't depend only on "city".
    //
    // Nominatim may return:
    // city
    // town
    // village
    // municipality
    // city_district
    // district
    // suburb
    //
    final city =
        value('city') ??
        value('town') ??
        value('village') ??
        value('municipality') ??
        value('city_district') ??
        value('district') ??
        value('suburb');

    // -------------------------
    // HOUSE NUMBER
    // -------------------------

    final houseNumber = value('house_number');

    debugPrint('FINAL STREET: $street');
    debugPrint('FINAL CITY: $city');
    debugPrint('FINAL HOUSE NUMBER: $houseNumber');

    return ReverseAddress(
      street: street,
      city: city,
      houseNumber: houseNumber,
    );
  }
}

class ReverseAddress {
  final String? street;
  final String? city;
  final String? houseNumber;

  const ReverseAddress({
    this.street,
    this.city,
    this.houseNumber,
  });
}