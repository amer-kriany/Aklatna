import 'package:flutter/material.dart';

import 'package:aklatna/features/home/presentation/widgets/home_empty_section.dart';

class HomeRestaurantList extends StatelessWidget {
  const HomeRestaurantList({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeEmptySection(
      height: 254,
      // TODO: Replace this placeholder with businesses from the home Cubit.
    );
  }
}
