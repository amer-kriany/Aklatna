import 'package:flutter/material.dart';

import 'package:aklatna/features/home/presentation/widgets/home_empty_section.dart';

class HomeTrendingList extends StatelessWidget {
  const HomeTrendingList({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeEmptySection(
      height: 174,
      // TODO: Replace this placeholder with trending items from the home Cubit.
    );
  }
}
