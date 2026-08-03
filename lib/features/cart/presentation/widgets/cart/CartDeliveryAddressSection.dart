import 'package:aklatna/features/addresses/domain/entity/addressEntity.dart';
import 'package:aklatna/features/addresses/presentation/bloc/address_bloc.dart';
import 'package:aklatna/features/home/presentation/widgets/home/AddressSelectionBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_style.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/skeleton.dart';

class CartDeliveryAddressSection extends StatelessWidget {
  const CartDeliveryAddressSection({super.key, required this.userId});

  final String userId;

  String _formatAddress(AddressEntity? address) {
    if (address == null) return '';
    final parts = <String>[
      address.street,
      if (address.apartment.trim().isNotEmpty) address.apartment,
      address.city,
    ];

    return parts.join('، ');
  }

  void _showAddressBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) {
        return AddressSelectionBottomSheet(userId: userId);
      },
    );

    // Refresh addresses after the user selects a different address.
    if (context.mounted) {
      context.read<AddressBloc>().add(LoadAddressesEvent(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressBloc, AddressState>(
      builder: (context, state) {
        AddressEntity? defaultAddress;

        if (state is AddressLoaded) {
          for (final address in state.addresses) {
            if (address.isDefault) {
              defaultAddress = address;
              break;
            }
          }
        }

        final hasAddress = defaultAddress != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('عنوان التوصيل', style: AppTextStyles.regularLarge),
                GestureDetector(
                  onTap: () => _showAddressBottomSheet(context),
                  child: Text(
                    'تعديل',
                    style: AppTextStyles.regularMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: state is AddressLoading
                  ? const Skeleton(
                      width: double.infinity,
                      height: 18,
                      radius: AppRadius.sm,
                    )
                  : Text(
                      hasAddress
                          ? _formatAddress(defaultAddress)
                          : 'لا يوجد عنوان محفوظ',
                      style: AppTextStyles.regularMedium.copyWith(
                        color: hasAddress
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
