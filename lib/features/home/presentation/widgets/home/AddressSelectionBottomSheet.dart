import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/addresses/presentation/bloc/address_bloc.dart';
import 'package:aklatna/features/addresses/presentation/widgets/AddEditAddressPage.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/widgets/page_skeletons.dart';

class AddressSelectionBottomSheet extends StatefulWidget {
  const AddressSelectionBottomSheet({super.key, required this.userId});

  final String userId;

  @override
  State<AddressSelectionBottomSheet> createState() =>
      _AddressSelectionBottomSheetState();
}

class _AddressSelectionBottomSheetState
    extends State<AddressSelectionBottomSheet> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(LoadAddressesEvent(userId: widget.userId));
  }

  IconData _iconForLabel(String? label) {
    switch (label) {
      case 'Home':
        return Icons.home_outlined;
      case 'Work':
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('اختر عنوان التوصيل', style: AppTextStyles.h4),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: BlocBuilder<AddressBloc, AddressState>(
                builder: (context, state) {
                  if (state is AddressLoading) {
                    return const SizedBox(
                      height: 220,
                      child: ListSkeleton(itemCount: 3),
                    );
                  }

                  if (state is AddressError) {
                    return Center(child: Text(state.message));
                  }

                  if (state is AddressLoaded) {
                    if (state.addresses.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        child: Center(
                          child: Text(
                            'لا توجد عناوين محفوظة حالياً',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.addresses.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (context, index) {
                        final addr = state.addresses[index];
                        final bool isSelected = addr.isDefault;

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: ListTile(
                            onTap: () async {
                              if (!isSelected) {
                                final addressBloc = context.read<AddressBloc>();

                                // 1. Dispatch set default event
                                addressBloc.add(
                                  SetDefaultAddressEvent(
                                    userId: widget.userId,
                                    addressId: addr.id,
                                  ),
                                );

                                // 2. Wait until AddressBloc finishes reloading addresses from the backend
                                await addressBloc.stream.firstWhere(
                                  (state) =>
                                      state is AddressLoaded ||
                                      state is AddressError,
                                );

                                // 3. Trigger profile refresh so the home page updates on the first try
                                if (context.mounted) {
                                  context.read<ProfileBloc>().add(
                                    GetProfilesEvent(),
                                  );
                                }
                              }

                              // 4. Pop the bottom sheet safely
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? AppColors.primaryLight
                                  : AppColors.background,
                              child: Icon(
                                _iconForLabel(addr.label),
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            title: Text(
                              addr.label ?? 'عنوان',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${addr.street}${addr.apartment.isNotEmpty ? '، ${addr.apartment}' : ''}، ${addr.city}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.regularSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  final state = context.read<AddressBloc>().state;
                  bool isFirst = false;
                  if (state is AddressLoaded) {
                    isFirst = state.addresses.isEmpty;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditAddressPage(isFirstAddress: isFirst),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: Text(
                  'إضافة عنوان جديد',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
