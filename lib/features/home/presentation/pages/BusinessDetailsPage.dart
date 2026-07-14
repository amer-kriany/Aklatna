import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/home/presentation/widgets/businesses/BusinessCategoryChips.dart';
import 'package:aklatna/features/home/presentation/widgets/businesses/MenuItemGridCard.dart';
import 'package:aklatna/features/home/presentation/widgets/businesses/businessDetailsInfo.dart';
import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';

class BusinessDetailsPage extends StatefulWidget {
  const BusinessDetailsPage({super.key, required this.businessId});

  final String businessId;

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<BusinessBloc>().add(GetBusinessById(id: widget.businessId));
    context.read<MenuBloc>().add(
      GetMenuForBusiness(businessId: widget.businessId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<BusinessBloc, BusinessState>(
          builder: (context, businessState) {
            if (businessState is BusinessLoading ||
                businessState is BusinessInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (businessState is BusinessError) {
              return Center(child: Text(businessState.message));
            }
            if (businessState is! BusinessDetailLoaded) {
              return const SizedBox.shrink();
            }

            final business = businessState.business;

            return Column(
              children: [
                // Header image
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child:
                            business.coverUrl != null &&
                                business.coverUrl!.isNotEmpty
                            ? Image.network(
                                business.coverUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(color: const Color(0xFFEDEDEF)),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => Navigator.pop(context),
                                child: const SizedBox(
                                  width: 42,
                                  height: 42,
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                BusinessDetailsInfo(
                  nameAr: business.nameAr,
                  rating: business.rating,
                  ratingCount: business.ratingCount,
                  description: business.description ?? '',
                ),

                const SizedBox(height: AppSpacing.lg),

                Expanded(
                  child: BlocBuilder<MenuBloc, MenuState>(
                    builder: (context, menuState) {
                      if (menuState is MenuLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (menuState is MenuError) {
                        return Center(child: Text(menuState.message));
                      }
                      if (menuState is MenuByBusinessLoaded) {
                        if (menuState.categories.isEmpty) {
                          return const Center(
                            child: Text('لا يوجد قائمة طعام حالياً'),
                          );
                        }
                        final categoryNames = menuState.categories
                            .map((c) => c.nameAr)
                            .toList();
                        final selectedCategory =
                            menuState.categories[_selectedIndex];
                        final itemsInCategory = menuState.items
                            .where((i) => i.categoryId == selectedCategory.id)
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BusinessCategoryChips(
                              categoryNames: categoryNames,
                              selectedIndex: _selectedIndex,
                              onSelected: (index) =>
                                  setState(() => _selectedIndex = index),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                              ),
                              child: Text(
                                '${selectedCategory.nameAr} (${itemsInCategory.length})',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Expanded(
                              child: itemsInCategory.isEmpty
                                  ? const Center(
                                      child: Text('لا توجد أطباق في هذا القسم'),
                                    )
                                  : GridView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.lg,
                                        vertical: AppSpacing.sm,
                                      ),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: AppSpacing.sm,
                                            crossAxisSpacing: AppSpacing.sm,
                                            childAspectRatio: 0.75,
                                          ),
                                      itemCount: itemsInCategory.length,
                                      itemBuilder: (context, index) {
                                        final item = itemsInCategory[index];
                                        return MenuItemGridCard(
                                          photoUrl: item.photoUrl,
                                          nameAr: item.nameAr,
                                          price: item.price,
                                          onTap: () =>
                                              context.push('/food/${item.id}'),
                                          onAdd: () {
                                            context.read<CartBloc>().add(
                                              AddItemEvent(
                                                item: CartItem(
                                                  itemId: item.id,
                                                  nameAr: item.nameAr,
                                                  description:
                                                      item.description ?? '',
                                                  price: item.price,
                                                  quantity: 1,
                                                  businessId: item.businessId,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
