import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aklatna/core/utils/business_time_utils.dart';
import 'package:aklatna/features/home/presentation/cubit/business_cubit.dart';
import 'package:aklatna/features/home/presentation/widgets/home_empty_section.dart';
import 'package:aklatna/features/home/presentation/widgets/restaurant_summary_card.dart';

class HomeRestaurantList extends StatelessWidget {
  const HomeRestaurantList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessCubit, BusinessState>(
      builder: (context, state) {
        if (state is BusinessFetched) {
          if (state.businesses.isEmpty) {
            return const HomeEmptySection(height: 254);
          }
          return Column(
            children: state.businesses
                .map(
                  (business) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RestaurantSummaryCard(
                      restaurant: _toSummary(business),
                    ),
                  ),
                )
                .toList(),
          );
        }
        return const HomeEmptySection(height: 254);
      },
    );
  }

  RestaurantSummary _toSummary(business) {
    return RestaurantSummary(
      name: business.nameAr,
      description: business.adress,
      rating: business.rating.toString(),
      deliveryTime: '20-30 د',
      isOpen: BusinessTimeUtils.isOpenNow(
        business.openingTime,
        business.closingTime,
      ),
      imageUrl: business.coverUrl,
    );
  }
}