import 'package:aklatna/features/addresses/presentation/bloc/address_bloc.dart';
import 'package:aklatna/features/addresses/presentation/widgets/AddEditAddressPage.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      _userId = profileState.profile.id;
      context.read<AddressBloc>().add(LoadAddressesEvent(userId: _userId!));
    }
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
      child: Scaffold(
        appBar: AppBar(title: Text('عناويني', style: AppTextStyles.h4)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<AddressBloc, AddressState>(
                    builder: (context, state) {
                      if (state is AddressLoading || state is AddressInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is AddressError) {
                        return Center(child: Text(state.message));
                      }
                      if (state is! AddressLoaded) {
                        return const SizedBox.shrink();
                      }
                      if (state.addresses.isEmpty) {
                        return Center(child: Text('لا توجد عناوين محفوظة', style: AppTextStyles.bodyMedium));
                      }

                      return ListView.separated(
                        itemCount: state.addresses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final addr = state.addresses[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(
                                color: addr.isDefault ? AppColors.primary : AppColors.border,
                              ),
                            ),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.primaryLight,
                                  child: Icon(_iconForLabel(addr.label), color: AppColors.primary),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(addr.label ?? 'عنوان', style: AppTextStyles.bodyMedium),
                                      const SizedBox(height: AppSpacing.xxs),
                                      Text(
                                        '${addr.street}${addr.apartment.isNotEmpty ? '، ${addr.apartment}' : ''}، ${addr.city}',
                                        style: AppTextStyles.regularSmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                // Edit button
IconButton(
  icon: const Icon(
    Icons.edit_outlined,
    color: AppColors.primary,
    size: AppSizes.iconSm,
  ),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddEditAddressPage(
        existing: addr,
        isFirstAddress: false,
      ),
    ),
  ),
),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: AppSizes.iconSm),
                                  onPressed: () {
                                    if (_userId != null) {
                                      context.read<AddressBloc>().add(
                                        DeleteAddressEvent(userId: _userId!, addressId: addr.id),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
               SizedBox(
  width: double.infinity,
  height: AppSizes.buttonHeight,
  child: FilledButton(
    onPressed: () {
      final state = context.read<AddressBloc>().state;

      bool isFirstAddress = false;

      if (state is AddressLoaded) {
        isFirstAddress = state.addresses.isEmpty;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddEditAddressPage(
            isFirstAddress: isFirstAddress,
          ),
        ),
      );
    },
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    child: Text(
      'إضافة عنوان جديد',
      style: AppTextStyles.buttonLarge,
    ),
  ),
),
              ],
            ),
          ),
        ),
      ),
    );
  }
}