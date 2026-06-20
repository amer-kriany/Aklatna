import 'package:flutter/material.dart';

import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/core/widgets/app_bottom_nav.dart';
import 'package:aklatna/features/home/presentation/widgets/home_category_list.dart';
import 'package:aklatna/features/home/presentation/widgets/home_header.dart';
import 'package:aklatna/features/home/presentation/widgets/home_restaurant_list.dart';
import 'package:aklatna/features/home/presentation/widgets/home_search_field.dart';
import 'package:aklatna/features/home/presentation/widgets/home_section_header.dart';
import 'package:aklatna/features/home/presentation/widgets/home_trending_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: AppBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
        body: const SafeArea(child: _HomeContent()),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    // TODO: Wrap this content with Cubit state when home logic is ready.
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                HomeHeader(),
                SizedBox(height: 18),
                HomeSearchField(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: HomeCategoryList()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
            child: Column(
              children: [
                const HomeSectionHeader(
                  title: 'الأكثر طلبا',
                  actionText: 'عرض الكل',
                ),
                const SizedBox(height: 12),
                const HomeTrendingList(),
                const SizedBox(height: 28),
                const HomeSectionHeader(
                  title: 'المطاعم القريبة',
                  actionText: 'المزيد',
                ),
                const SizedBox(height: 12),
                const HomeRestaurantList(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
