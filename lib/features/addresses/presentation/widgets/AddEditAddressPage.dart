import 'package:aklatna/features/addresses/domain/entity/addressEntity.dart';
import 'package:aklatna/features/addresses/presentation/bloc/address_bloc.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthPrimaryButton.dart';
import 'package:aklatna/features/auth/presentation/widgets/signIn/AuthTextField.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class AddEditAddressPage extends StatefulWidget {
  const AddEditAddressPage({super.key, this.existing});

  final AddressEntity? existing;

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _apartmentController;
  String? _selectedLabel;
  bool _isDefault = false;

  static const _labelOptions = ['Home', 'Work', 'Other'];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _streetController = TextEditingController(text: existing?.street ?? '');
    _cityController = TextEditingController(text: existing?.city ?? '');
    _apartmentController = TextEditingController(text: existing?.apartment ?? '');
    _selectedLabel = existing?.label ?? 'Home';
    _isDefault = existing?.isDefault ?? false;
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }

  void _onSave() {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is! ProfileLoaded) return;

    final street = _streetController.text.trim();
    final city = _cityController.text.trim();
    if (street.isEmpty || city.isEmpty) return; // TODO(Amer): real validation messages

    if (widget.existing != null) {
      // Editing: delete old, add new (no update-in-place usecase built yet)
      context.read<AddressBloc>().add(
        DeleteAddressEvent(userId: profileState.profile.id, addressId: widget.existing!.id),
      );
    }

    context.read<AddressBloc>().add(
      AddAddressEvent(
        userId: profileState.profile.id,
        label: _selectedLabel,
        street: street,
        city: city,
        apartment: _apartmentController.text.trim(),
        isDefault: _isDefault,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.existing == null ? 'إضافة عنوان' : 'تعديل عنوان', style: AppTextStyles.h4),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthTextField(label: 'الشارع', hint: 'مثال: شارع الزبير بن العوام', controller: _streetController),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(label: 'المدينة', hint: 'مثال: داريا', controller: _cityController),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(label: 'الشقة (اختياري)', hint: 'رقم الشقة أو الطابق', controller: _apartmentController),
                const SizedBox(height: AppSpacing.lg),
                Text('تصنيف العنوان', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: _labelOptions.map((label) {
                    final isSelected = _selectedLabel == label;
                    return Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedLabel = label),
                        selectedColor: AppColors.primary,
                        labelStyle: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                        ),
                        backgroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isDefault,
                  onChanged: (v) => setState(() => _isDefault = v ?? false),
                  title: Text('اجعله العنوان الافتراضي', style: AppTextStyles.bodyMedium),
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.xl),
                BlocBuilder<AddressBloc, AddressState>(
                  builder: (context, state) {
                    return AuthPrimaryButton(
                      label: 'حفظ',
                      onPressed: state is AddressLoading ? null : _onSave,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}