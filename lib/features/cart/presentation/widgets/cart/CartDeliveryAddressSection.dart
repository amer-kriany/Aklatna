import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aklatna/features/home/presentation/widgets/home/AddressSelectionBottomSheet.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_style.dart';
import '../../../../../core/theme/app_colors.dart';

class CartDeliveryAddressSection extends StatelessWidget {
  const CartDeliveryAddressSection({
    super.key,
    required this.address,
    required this.userId,
  });

  final String address;
  final String userId;

  void _showAddressBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (_) {
        return AddressSelectionBottomSheet(userId: userId);
      },
    );

    // Refresh profile state when sheet closes so the cart updates instantly
    if (context.mounted) {
      context.read<ProfileBloc>().add(GetProfilesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('عنوان التوصيل ', style: AppTextStyles.regularLarge),
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
          child: Text(address, style: AppTextStyles.regularMedium),
        ),
      ],
    );
  }
}