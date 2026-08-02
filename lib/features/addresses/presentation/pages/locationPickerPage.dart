import 'package:aklatna/features/addresses/data/services/nominatim_service.dart';
import 'package:aklatna/core/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const LatLng _defaultLocation = LatLng(33.4585, 36.2394);

  late LatLng _selectedLocation;

  final NominatimService _nominatimService = NominatimService();

  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();

    _selectedLocation = widget.initialLocation ?? _defaultLocation;
  }

  Future<void> _confirmLocation() async {
    if (_isLoadingAddress) return;

    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final address = await _nominatimService.reverseGeocode(_selectedLocation);

      if (!mounted) return;

      Navigator.pop(
        context,
        LocationPickerResult(location: _selectedLocation, address: address),
      );
    } catch (e) {
      if (!mounted) return;

      // Important:
      // Even if reverse geocoding fails,
      // we still have valid coordinates.
      Navigator.pop(
        context,
        LocationPickerResult(location: _selectedLocation, address: null),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديد موقع التوصيل'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 16,
              onTap: (_, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.aklatna.app',
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_pin,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'اضغط على الخريطة لتحديد موقع منزلك',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: _isLoadingAddress ? null : _confirmLocation,
                icon: _isLoadingAddress
                    ? const Skeleton(
                        width: 20,
                        height: 20,
                        isCircle: true,
                        baseColor: Colors.white24,
                        highlightColor: Colors.white70,
                      )
                    : const Icon(Icons.check),
                label: Text(
                  _isLoadingAddress ? 'جاري تحديد العنوان...' : 'تأكيد الموقع',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationPickerResult {
  final LatLng location;
  final ReverseAddress? address;

  const LocationPickerResult({required this.location, required this.address});
}
