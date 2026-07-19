import 'package:aklatna/features/addOnes/domain/enitity/addOnesEntity.dart';
import 'package:aklatna/features/addOnes/presentation/bloc/add_ones_bloc.dart';
import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:aklatna/features/menu/presentation/widgets/AddToCartSection.dart';
import 'package:aklatna/features/menu/presentation/widgets/FoodDetailsImage.dart';
import 'package:aklatna/features/menu/presentation/widgets/FoodDetailsInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class Foodetailspage extends StatefulWidget {
  final String itemId;
  const Foodetailspage({super.key, required this.itemId});

  @override
  State<Foodetailspage> createState() => _FoodetailspageState();
}

class _FoodetailspageState extends State<Foodetailspage> {
  int _quantity = 1;
  Set<String> _selectedAddonIds = {};

  @override
  void initState() {
    context.read<MenuBloc>().add(GetMenu(id: widget.itemId));
    context.read<AddonBloc>().add(GetAddonsEvent(itemId: widget.itemId));
    super.initState();
  }

  double _addonsTotal(List<AddonEntity> addons) => addons
      .where((a) => _selectedAddonIds.contains(a.id))
      .fold(0.0, (sum, a) => sum + a.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<MenuBloc, MenuState>(
          builder: (context, state) {
            if (state is MenuLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MenuError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text("food not found", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            }
            if (state is MenuLoaded) {
              return BlocBuilder<AddonBloc, AddOnesState>(
                builder: (context, addonState) {
                  final addons = addonState is AddonLoaded ? addonState.addons : <AddonEntity>[];
                  final addonsTotal = _addonsTotal(addons);

                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              FoodDetailsImage(
                                imageUrl: state.item.photoUrl,
                                onBack: () => Navigator.pop(context),
                                onFavorite: () {},
                                isFavorite: false,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              FoodDetailsInfo(
                                title: state.item.nameAr,
                                category: state.category.nameAr,
                                description: state.item.description ?? '',
                              ),
                              if (addonState is AddonLoading)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                              if (addons.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: AppSpacing.lg),
                                      Text('إضافات', style: AppTextStyles.h4),
                                      const SizedBox(height: AppSpacing.xs),
                                      ...addons.map((addon) => CheckboxListTile(
                                            contentPadding: EdgeInsets.zero,
                                            value: _selectedAddonIds.contains(addon.id),
                                            activeColor: AppColors.primary,
                                            title: Text(addon.name, style: AppTextStyles.bodyMedium),
                                            secondary: Text('+${addon.price.toStringAsFixed(0)}', style: AppTextStyles.priceMedium),
                                            onChanged: (checked) {
                                              setState(() {
                                                if (checked == true) {
                                                  _selectedAddonIds.add(addon.id);
                                                } else {
                                                  _selectedAddonIds.remove(addon.id);
                                                }
                                              });
                                            },
                                          )),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                          ),
                        ),
                      ),
                      AddToCartSection(
                        price: ((state.item.price + addonsTotal) * _quantity).toString(),
                        quantity: _quantity,
                        onIncrement: () => setState(() => _quantity++),
                        onDecrement: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                        onAddToCart: () {
                          context.read<CartBloc>().add(
                            AddItemEvent(
                              item: CartItem(
                                itemId: state.item.id,
                                nameAr: state.item.nameAr,
                                description: state.item.description ?? '',
                                photoUrl: state.item.photoUrl,
                                price: state.item.price + addonsTotal,
                                quantity: _quantity,
                                businessId: state.item.businessId,
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}