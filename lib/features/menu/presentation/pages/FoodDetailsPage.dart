import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:aklatna/features/menu/presentation/widgets/AddToCartSection.dart';
import 'package:aklatna/features/menu/presentation/widgets/FoodDetailsImage.dart';
import 'package:aklatna/features/menu/presentation/widgets/FoodDetailsInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';

class Foodetailspage extends StatefulWidget {
  final String itemId;
  const Foodetailspage({super.key, required this.itemId});

  @override
  State<Foodetailspage> createState() => _FoodetailspageState();
}

class _FoodetailspageState extends State<Foodetailspage> {
  @override
  void initState() {
    context.read<MenuBloc>().add(GetMenu(id: widget.itemId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<MenuBloc, MenuState>(
          builder: (context, state) {
            if (state is MenuLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is MenuError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "food not found",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            }
            if (state is MenuLoaded) {
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

                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),

                  AddToCartSection(
                    price: state.item.price.toString(),
                    quantity: 1,
                    onIncrement: () {},
                    onDecrement: () {},
                    onAddToCart: () {},
                  ),
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
