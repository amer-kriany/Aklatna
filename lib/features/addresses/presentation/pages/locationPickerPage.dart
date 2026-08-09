import 'dart:async';

import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/addresses/data/services/nominatim_service.dart';
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
  final MapController _mapController = MapController();
  final NominatimService _nominatimService = NominatimService();

  bool _isConfirming = false;
  bool _isPreviewLoading = false;
  String? _addressPreview;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? _defaultLocation;
    _loadPreview(_selectedLocation);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Debounced reverse-geocode preview while the user drags the map --
  // only fires ~600ms after movement stops, not on every frame.
  void _onCenterChanged(LatLng center) {
    _selectedLocation = center;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _loadPreview(center);
    });
  }

  Future<void> _loadPreview(LatLng location) async {
    if (!mounted) return;
    setState(() => _isPreviewLoading = true);

    try {
      final address = await _nominatimService.reverseGeocode(location);
      if (!mounted) return;
      setState(() {
        _addressPreview = [
          if (address?.street != null && address!.street!.trim().isNotEmpty)
            address.street,
          if (address?.city != null && address!.city!.trim().isNotEmpty)
            address.city,
        ].whereType<String>().join('، ');
        _isPreviewLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _addressPreview = null;
        _isPreviewLoading = false;
      });
    }
  }

  Future<void> _confirmLocation() async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);

    try {
      final address = await _nominatimService.reverseGeocode(_selectedLocation);
      if (!mounted) return;
      Navigator.pop(
        context,
        LocationPickerResult(location: _selectedLocation, address: address),
      );
    } catch (e) {
      if (!mounted) return;
      // Coordinates are still valid even if reverse geocoding fails.
      Navigator.pop(
        context,
        LocationPickerResult(location: _selectedLocation, address: null),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 16,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) _onCenterChanged(camera.center);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.aklatna.app',
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          // Fixed center pin -- the map moves underneath it instead of
          // tapping to place a marker. Standard "drag map to position"
          // pattern, more precise than a single tap.
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(
                  Icons.location_pin,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Material(
                    color: AppColors.background,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _isPreviewLoading
                                ? Text(
                                    'جاري تحديد العنوان...',
                                    style: AppTextStyles.regularSmall
                                        .copyWith(color: AppColors.textSecondary),
                                  )
                                : Text(
                                    _addressPreview?.isNotEmpty == true
                                        ? _addressPreview!
                                        : 'حرّك الخريطة لتحديد موقع منزلك',
                                    style: AppTextStyles.bodyMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ElevatedButton.icon(
                      onPressed: _isConfirming ? null : _confirmLocation,
                      icon: _isConfirming
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textOnPrimary,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(_isConfirming ? 'جاري الحفظ...' : 'تأكيد الموقع'),
                    ),
                  ],
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