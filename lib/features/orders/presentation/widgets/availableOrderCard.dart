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

                if (businessAddress != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    businessAddress,
                    style: AppTextStyles.regularSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: AppSpacing.sm),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: AppSizes.iconSm,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Text(
                        order.deliveryAddress ?? '',
                        style: AppTextStyles.regularSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.totalPrice} ل.س',
                      style: AppTextStyles.priceMedium,
                    ),
                    Text(
                      'التوصيل: ${order.deliveryFee} ل.س',
                      style: AppTextStyles.regularSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
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