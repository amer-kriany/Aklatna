import 'dart:async';

import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/addresses/data/services/nominatim_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({
    super.key,
    this.initialLocation,
  });

  final LatLng? initialLocation;

  @override
  State<LocationPickerPage> createState() =>
      _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  // Default location used when the user doesn't already
  // have coordinates.
  static const LatLng _defaultLocation = LatLng(
    33.4585,
    36.2394,
  );

  late LatLng _selectedLocation;

  final MapController _mapController = MapController();

  final NominatimService _nominatimService =
      NominatimService();

  Timer? _debounce;

  bool _isPreviewLoading = false;
  bool _isConfirming = false;

  String? _addressPreview;

  @override
  void initState() {
    super.initState();

    _selectedLocation =
        widget.initialLocation ?? _defaultLocation;

    _loadPreview(_selectedLocation);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ============================================================
  // MAP MOVEMENT
  // ============================================================

  void _onCenterChanged(LatLng center) {
    _selectedLocation = center;

    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 600),
      () {
        _loadPreview(center);
      },
    );
  }

  // ============================================================
  // REVERSE GEOCODING
  // ============================================================

  Future<void> _loadPreview(
    LatLng location,
  ) async {
    if (!mounted) return;

    setState(() {
      _isPreviewLoading = true;
    });

    try {
      final address =
          await _nominatimService.reverseGeocode(
        location,
      );

      if (!mounted) return;

      final parts = <String>[];

      if (address?.street != null &&
          address!.street!.trim().isNotEmpty) {
        parts.add(
          address.street!.trim(),
        );
      }

      if (address?.city != null &&
          address!.city!.trim().isNotEmpty) {
        parts.add(
          address.city!.trim(),
        );
      }

      setState(() {
        _addressPreview =
            parts.isEmpty
                ? null
                : parts.join('، ');

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

  // ============================================================
  // CONFIRM LOCATION
  // ============================================================

  Future<void> _confirmLocation() async {
    if (_isConfirming) return;

    setState(() {
      _isConfirming = true;
    });

    try {
      // Do one final reverse-geocoding request so that
      // the returned address definitely belongs to the
      // final selected coordinates.
      final address =
          await _nominatimService.reverseGeocode(
        _selectedLocation,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        LocationPickerResult(
          location: _selectedLocation,
          address: address,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      // Coordinates are still useful even if Nominatim
      // fails to return an address.
      Navigator.pop(
        context,
        LocationPickerResult(
          location: _selectedLocation,
          address: null,
        ),
      );
    }
  }

  // ============================================================
  // CENTER MAP
  // ============================================================

  void _centerMap() {
    _mapController.move(
      _selectedLocation,
      16,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // ======================================================
          // MAP
          // ======================================================

          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 16,

                interactionOptions:
                    const InteractionOptions(
                  flags:
                      InteractiveFlag.drag |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom,
                ),

                onPositionChanged:
                    (camera, hasGesture) {
                  if (hasGesture) {
                    _onCenterChanged(
                      camera.center,
                    );
                  }
                },
              ),
              children: [

                // ==================================================
                // CLEAN CARTO BASEMAP
                // ==================================================
                //
                // light_nolabels = clean light map without
                // the normal label/POI layer.
                //
                // This replaces the default OSM tiles that
                // were showing churches, mosques, etc.
                //

                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                  subdomains: const [
                    'a',
                    'b',
                    'c',
                    'd',
                  ],
                  userAgentPackageName:
                      'com.aklatna.app',
                ),

                // ==================================================
                // MAP ATTRIBUTION
                // ==================================================

                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      '© OpenStreetMap contributors',
                      onTap: () {
                        // Attribution only.
                      },
                    ),
                    TextSourceAttribution(
                      '© CARTO',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ======================================================
          // TOP DARK GRADIENT
          // ======================================================

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ======================================================
          // FIXED RED PIN
          // ======================================================
          //
          // The pin stays in the center.
          // The map moves underneath it.
          //

          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 42,
                ),
                child: _CustomerLocationPin(),
              ),
            ),
          ),

          // ======================================================
          // TOP BAR
          // ======================================================

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(
                AppSpacing.md,
              ),
              child: Row(
                children: [

                  // BACK BUTTON
                  _MapButton(
                    icon:
                        Icons.arrow_back_rounded,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(
                    width: AppSpacing.sm,
                  ),

                  // TITLE
                  Expanded(
                    child: Container(
                      height: 48,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius:
                            BorderRadius.circular(
                          AppRadius.full,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(
                              0.12,
                            ),
                            blurRadius: 12,
                            offset:
                                const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [

                          const Icon(
                            Icons.location_on_rounded,
                            color:
                                AppColors.error,
                            size: 22,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Text(
                            'حدد موقع التوصيل',
                            style: AppTextStyles
                                .bodyMedium
                                .copyWith(
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // MAP INSTRUCTION
          // ======================================================

          Positioned(
            top: 112,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Colors.black.withOpacity(
                      0.60,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.full,
                    ),
                  ),
                  child: const Text(
                    'حرّك الخريطة لوضع الدبوس على منزلك',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ======================================================
          // CENTER MAP BUTTON
          // ======================================================

          Positioned(
            right: AppSpacing.md,
            bottom: 250,
            child: _MapButton(
              icon:
                  Icons.my_location_rounded,
              onPressed: _centerMap,
            ),
          ),

          // ======================================================
          // BOTTOM PANEL
          // ======================================================

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding:
                    const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  10,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color:
                      AppColors.background,
                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(
                        0.16,
                      ),
                      blurRadius: 20,
                      offset:
                          const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [

                    // ==================================================
                    // HANDLE
                    // ==================================================

                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration:
                            BoxDecoration(
                          color:
                              AppColors.border,
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ==================================================
                    // ADDRESS CARD
                    // ==================================================

                    Container(
                      padding:
                          const EdgeInsets.all(
                        AppSpacing.md,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(
                          AppRadius.lg,
                        ),
                        border: Border.all(
                          color:
                              AppColors.border,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          // LOCATION ICON
                          Container(
                            width: 44,
                            height: 44,
                            decoration:
                                BoxDecoration(
                              color: AppColors
                                  .error
                                  .withOpacity(
                                0.10,
                              ),
                              shape:
                                  BoxShape.circle,
                            ),
                            child:
                                const Icon(
                              Icons
                                  .location_on_rounded,
                              color:
                                  AppColors.error,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          // ADDRESS TEXT
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [

                                Text(
                                  'موقع التوصيل',
                                  style:
                                      AppTextStyles
                                          .bodySmall
                                          .copyWith(
                                    color: AppColors
                                        .textSecondary,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                if (_isPreviewLoading)
                                  Row(
                                    children: [

                                      const SizedBox(
                                        width: 15,
                                        height: 15,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 8,
                                      ),

                                      Text(
                                        'جاري تحديد العنوان...',
                                        style:
                                            AppTextStyles
                                                .bodyMedium
                                                .copyWith(
                                          color: AppColors
                                              .textSecondary,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    _addressPreview
                                            ?.isNotEmpty ==
                                        true
                                        ? _addressPreview!
                                        : 'حرّك الخريطة لتحديد موقعك',
                                    style:
                                        AppTextStyles
                                            .bodyMedium
                                            .copyWith(
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ==================================================
                    // CONFIRM BUTTON
                    // ==================================================

                    SizedBox(
                      height: 54,
                      child:
                          ElevatedButton(
                        onPressed:
                            _isConfirming
                                ? null
                                : _confirmLocation,
                        style:
                            ElevatedButton
                                .styleFrom(
                          elevation: 0,
                          backgroundColor:
                              AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary
                                  .withOpacity(
                                0.55,
                              ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              AppRadius.lg,
                            ),
                          ),
                        ),
                        child: _isConfirming
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2.5,
                                  color: AppColors
                                      .textOnPrimary,
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                children: [

                                  const Icon(
                                    Icons
                                        .check_rounded,
                                  ),

                                  const SizedBox(
                                    width: 8,
                                  ),

                                  Text(
                                    'تأكيد الموقع',
                                    style:
                                        AppTextStyles
                                            .bodyMedium
                                            .copyWith(
                                      color: AppColors
                                          .textOnPrimary,
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
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

// ================================================================
// CUSTOMER PIN
// ================================================================

class _CustomerLocationPin
    extends StatelessWidget {
  const _CustomerLocationPin();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [

        // PIN SHADOW
        Positioned(
          bottom: 2,
          child: Container(
            width: 18,
            height: 7,
            decoration:
                BoxDecoration(
              color:
                  Colors.black.withOpacity(
                0.25,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
          ),
        ),

        // RED PIN
        const Icon(
          Icons.location_pin,
          size: 52,
          color: AppColors.error,
        ),

        // WHITE CENTER
        Container(
          width: 11,
          height: 11,
          decoration:
              BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.error,
              width: 2,
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// MAP BUTTON
// ================================================================

class _MapButton
    extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      elevation: 4,
      shadowColor:
          Colors.black.withOpacity(
        0.25,
      ),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder:
            const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color:
                AppColors.textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// RESULT
// ================================================================

class LocationPickerResult {
  final LatLng location;
  final ReverseAddress? address;

  const LocationPickerResult({
    required this.location,
    required this.address,
  });
}