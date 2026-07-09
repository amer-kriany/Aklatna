import 'package:aklatna/features/menu/presentation/widgets/AddToCartSection.dart';
import 'package:aklatna/features/menu/presentation/widgets/FoodDetailsImage.dart';
import 'package:aklatna/features/menu/presentation/widgets/FoodDetailsInfo.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';


class FoodDetailsPage extends StatelessWidget {
    final String itemId;

  const FoodDetailsPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FoodDetailsImage(
                      imageUrl:
                          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
                      onBack: () => Navigator.pop(context),
                      onFavorite: () {},
                      isFavorite: false,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    const FoodDetailsInfo(
                      title: 'Cheese Burger',
                      category: 'Burger',
                      rating: 4.8,
                      deliveryFee: '\$2.50',
                      deliveryTime: '20-30 min',
                      description:
                          'A juicy beef burger topped with melted cheddar cheese, fresh lettuce, tomatoes, onions, and our signature sauce served in a toasted bun.',
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            AddToCartSection(
              price: '\$12.99',
              quantity: 1,
              onIncrement: () {},
              onDecrement: () {},
              onAddToCart: () {},
            ),
          ],
        ),
      ),
    );
  }
}