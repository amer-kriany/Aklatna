import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Shows the customer's delivery location (red pin) and the
/// restaurant's location (colored circle) on one embedded map, using
/// OpenStreetMap tiles -- no Google API key/billing, no dependency on
/// Google service availability (relevant given access to Google
/// services can be unreliable in Syria).
class DeliveryLocationsMap extends StatelessWidget {
  const DeliveryLocationsMap({
    super.key,
    required this.customerLocation,
    this.businessLocation,
  });

  final LatLng customerLocation;
  final LatLng? businessLocation;

  @override
  Widget build(BuildContext context) {
    final points = [
      customerLocation,
      if (businessLocation != null) businessLocation!,
    ];

    final bounds = LatLngBounds.fromPoints(points);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        height: 220,
        child: FlutterMap(
          options: MapOptions(
            initialCameraFit: CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(48),
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.aklatna.app',
            ),
            MarkerLayer(
              markers: [
                if (businessLocation != null)
                  Marker(
                    point: businessLocation!,
                    width: 36,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                Marker(
                  point: customerLocation,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.error,
                    size: 40,
                  ),
                ),
              ],
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  '© OpenStreetMap contributors',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}