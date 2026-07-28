import 'package:aklatna/features/addresses/domain/entity/addressEntity.dart';
import 'package:aklatna/features/addresses/presentation/bloc/address_bloc.dart';
import 'package:aklatna/features/addresses/presentation/pages/locationPickerPage.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthPrimaryButton.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthTextField.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class AddEditAddressPage extends StatefulWidget {
  const AddEditAddressPage({
    super.key,
    this.existing,
    required this.isFirstAddress,
  });

  final AddressEntity? existing;
  final bool isFirstAddress;

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _apartmentController;

  String? _selectedLabel;
  bool _isDefault = false;

  double? _latitude;
  double? _longitude;

  bool _saving = false;

  static const _labelOptions = [
    'Home',
    'Work',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    final existing = widget.existing;

    _streetController = TextEditingController(
      text: existing?.street ?? '',
    );

    _cityController = TextEditingController(
      text: existing?.city ?? '',
    );

    _apartmentController = TextEditingController(
      text: existing?.apartment ?? '',
    );

    _selectedLabel = existing?.label ?? 'Home';

    if (existing != null) {
      _isDefault = existing.isDefault;

      // Restore existing coordinates when editing.
      _latitude = existing.latitude;
      _longitude = existing.longitude;
    } else {
      _isDefault = widget.isFirstAddress;
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // LOCATION PICKER
  // ------------------------------------------------------------

  Future<void> _selectLocation() async {
    LatLng? initialLocation;

    if (_latitude != null && _longitude != null) {
      initialLocation = LatLng(
        _latitude!,
        _longitude!,
      );
    }

    final result = await Navigator.push<LocationPickerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialLocation: initialLocation,
        ),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _latitude = result.location.latitude;
      _longitude = result.location.longitude;

      final address = result.address;

      // Automatically fill street.
      if (address?.street != null &&
          address!.street!.trim().isNotEmpty) {
        _streetController.text = address.street!;
      }

      // Automatically fill city.
      if (address?.city != null &&
          address!.city!.trim().isNotEmpty) {
        _cityController.text = address.city!;
      }
    });
  }

  // ------------------------------------------------------------
  // SAVE
  // ------------------------------------------------------------

  void _onSave() {
    final profileState = context.read<ProfileBloc>().state;

    if (profileState is! ProfileLoaded) {
      return;
    }

    final street = _streetController.text.trim();
    final city = _cityController.text.trim();

    if (street.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال الشارع والمدينة'),
        ),
      );
      return;
    }

    final addressBloc = context.read<AddressBloc>();

    // EDIT EXISTING ADDRESS
    if (widget.existing != null) {
      addressBloc.add(
        UpdateAddressEvent(
          userId: profileState.profile.id,
          addressId: widget.existing!.id,
          label: _selectedLabel,
          street: street,
          city: city,
          apartment: _apartmentController.text.trim(),
          isDefault: _isDefault,
          latitude: _latitude,
          longitude: _longitude,
        ),
      );

      return;
    }

    // ADD NEW ADDRESS
    addressBloc.add(
      AddAddressEvent(
        userId: profileState.profile.id,
        label: _selectedLabel,
        street: street,
        city: city,
        apartment: _apartmentController.text.trim(),
        isDefault: _isDefault,
        latitude: _latitude,
        longitude: _longitude,
      ),
    );
  }

  bool get _hasLocation =>
      _latitude != null && _longitude != null;

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<AddressBloc, AddressState>(
        listener: (context, state) {
          // SAVING
          if (state is AddressLoading) {
            if (mounted) {
              setState(() {
                _saving = true;
              });
            }
          }

          // SUCCESS
          if (state is AddressLoaded) {
            if (mounted) {
              setState(() {
                _saving = false;
              });

              // IMPORTANT:
              // true tells the previous page that
              // the address was successfully changed.
              Navigator.pop(context, true);
            }
          }

          // ERROR
          if (state is AddressError) {
            if (mounted) {
              setState(() {
                _saving = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.existing == null
                  ? 'إضافة عنوان'
                  : 'تعديل عنوان',
              style: AppTextStyles.h4,
            ),
          ),

          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ------------------------------------------------
                  // STREET
                  // ------------------------------------------------

                  AuthTextField(
                    label: 'الشارع',
                    hint: 'مثال: شارع الزبير بن العوام',
                    controller: _streetController,
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  // ------------------------------------------------
                  // CITY
                  // ------------------------------------------------

                  AuthTextField(
                    label: 'المدينة',
                    hint: 'مثال: داريا',
                    controller: _cityController,
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  // ------------------------------------------------
                  // APARTMENT
                  // ------------------------------------------------

                  AuthTextField(
                    label: 'الشقة (اختياري)',
                    hint: 'رقم الشقة أو الطابق',
                    controller: _apartmentController,
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  // ------------------------------------------------
                  // LABEL
                  // ------------------------------------------------

                  Text(
                    'تصنيف العنوان',
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(
                    height: AppSpacing.sm,
                  ),

                  Row(
                    children: _labelOptions.map((label) {
                      final isSelected =
                          _selectedLabel == label;

                      return Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.sm,
                        ),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedLabel = label;
                            });
                          },
                          selectedColor: AppColors.primary,
                          labelStyle:
                              AppTextStyles.bodyMedium.copyWith(
                            color: isSelected
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                          ),
                          backgroundColor:
                              AppColors.surface,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              AppRadius.full,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(
                    height: AppSpacing.xl,
                  ),

                  // ------------------------------------------------
                  // LOCATION
                  // ------------------------------------------------

                  Text(
                    'موقع التوصيل',
                    style: AppTextStyles.h4,
                  ),

                  const SizedBox(
                    height: AppSpacing.sm,
                  ),

                  InkWell(
                    onTap: _saving
                        ? null
                        : _selectLocation,
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.lg,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(
                          AppRadius.lg,
                        ),
                        border: Border.all(
                          color: _hasLocation
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [

                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(
                            width: AppSpacing.md,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  _hasLocation
                                      ? 'تم تحديد الموقع'
                                      : 'حدد موقع التوصيل',
                                  style: AppTextStyles
                                      .bodyMedium
                                      .copyWith(
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  _hasLocation
                                      ? 'اضغط لتغيير الموقع'
                                      : 'حدد مكان منزلك بدقة على الخريطة',
                                  style: AppTextStyles
                                      .bodySmall
                                      .copyWith(
                                    color: AppColors
                                        .textSecondary,
                                  ),
                                ),

                                if (_hasLocation) ...[
                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    '${_latitude!.toStringAsFixed(6)}, '
                                    '${_longitude!.toStringAsFixed(6)}',
                                    style: AppTextStyles
                                        .bodySmall
                                        .copyWith(
                                      color:
                                          AppColors.primary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.chevron_left,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  // ------------------------------------------------
                  // DEFAULT ADDRESS
                  // ------------------------------------------------

                  if (!widget.isFirstAddress)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isDefault,
                      onChanged: _saving
                          ? null
                          : (value) {
                              setState(() {
                                _isDefault =
                                    value ?? false;
                              });
                            },
                      title: Text(
                        'اجعله العنوان الافتراضي',
                        style:
                            AppTextStyles.bodyMedium,
                      ),
                      activeColor:
                          AppColors.primary,
                    ),

                  const SizedBox(
                    height: AppSpacing.xl,
                  ),

                  // ------------------------------------------------
                  // SAVE BUTTON
                  // ------------------------------------------------

                  AuthPrimaryButton(
                    label: _saving
                        ? 'جاري الحفظ...'
                        : 'حفظ',
                    onPressed:
                        _saving ? null : _onSave,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}