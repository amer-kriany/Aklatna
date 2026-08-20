import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/presentation/bloc/order_bloc.dart';
import 'package:aklatna/features/orders/presentation/pages/driverOrderDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvailableOrderCard extends StatelessWidget {
  const AvailableOrderCard({
    super.key,
    required this.order,
    this.onAccepted,
    this.isDisabled = false,
  });

  final OrderEntity order;
  final VoidCallback? onAccepted;
  final bool isDisabled;

  String? _businessAddress(BuildContext context) {
    final businessState = context.read<BusinessBloc>().state;
    if (businessState is! BusinessFetched) return null;

    for (final business in businessState.businesses) {
      if (business.id == order.businessId) {
        return _shortAddress(business.adress);
      }
    }
    return null;
  }

  // Drops the country/province tail ("سوريا", "محافظة ...") so the
  // card shows just the local part instead of the full address.
  String? _shortAddress(String? fullAddress) {
    if (fullAddress == null || fullAddress.trim().isEmpty) return null;

    final parts = fullAddress
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .where((e) => !e.contains('سوريا') && !e.contains('محافظة'))
        .toList();

    return parts.isEmpty ? null : parts.join('، ');
  }

  @override
  Widget build(BuildContext context) {
    final businessAddress = _businessAddress(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DriverOrderDetailsPage(order: order),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.businessName ?? '',
                  style: AppTextStyles.h4,
                ),

                const SizedBox(height: AppSpacing.sm),

                // =============================================================
                // ADDRESSES — pickup (business) then dropoff (customer),
                // each clearly labeled so the driver can't confuse the two.
                // =============================================================

                if (businessAddress != null)
                  _AddressRow(
                    icon: Icons.storefront_rounded,
                    label: 'من',
                    address: businessAddress,
                  ),

                if (businessAddress != null)
                  const SizedBox(height: AppSpacing.xs),

                _AddressRow(
                  icon: Icons.location_on_rounded,
                  label: 'إلى',
                  address: order.deliveryAddress ?? '',
                ),

                const SizedBox(height: AppSpacing.sm),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.sm),

                // =============================================================
                // PRICE BREAKDOWN — subtotal, then delivery fee, then total.
                // =============================================================

                _PriceRow(
                  label: 'سعر الطلب',
                  value: order.totalPrice,
                ),
                const SizedBox(height: AppSpacing.xxs),
                _PriceRow(
                  label: 'أجرة التوصيل',
                  value: order.deliveryFee,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.xs),
                _PriceRow(
                  label: 'الإجمالي (تُحصَّل من الزبون)',
                  value: order.totalPrice + order.deliveryFee,
                  isTotal: true,
                ),

                const SizedBox(height: AppSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isDisabled
                        ? null
                        : () {
                            context.read<OrderBloc>().add(
                              AcceptOrderEvent(
                                orderId: order.id!,
                                driverId: Supabase
                                    .instance.client.auth.currentUser!.id,
                              ),
                            );
                            onAccepted?.call();
                          },
                    child: Text(
                      isDisabled ? 'لديك توصيلة قيد التنفيذ' : 'قبول الطلب',
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

// =============================================================================
// ADDRESS ROW
// =============================================================================

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.icon,
    required this.label,
    required this.address,
  });

  final IconData icon;
  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: AppSizes.iconSm,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          '$label: ',
          style: AppTextStyles.regularSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            address,
            style: AppTextStyles.regularSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// PRICE ROW
// =============================================================================

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final num? value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final textStyle = isTotal
        ? AppTextStyles.priceMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          )
        : AppTextStyles.regularSmall.copyWith(
            color: AppColors.textSecondary,
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text('${value ?? 0} ل.س', style: textStyle),
      ],
    );
  }
}