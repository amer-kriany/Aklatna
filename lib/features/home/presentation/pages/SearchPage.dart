import 'dart:async';

import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/home/presentation/widgets/search/popularDishes.dart';
import 'package:aklatna/features/home/presentation/widgets/search/recentKeyword.dart';
import 'package:aklatna/features/home/presentation/widgets/search/searchBarState.dart'
    as app;
import 'package:aklatna/features/home/presentation/widgets/search/searchHeader.dart';
import 'package:aklatna/features/home/presentation/widgets/search/searchResultCard.dart';
import 'package:aklatna/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:aklatna/features/profile/presentaion/bloc/profile_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// TODO(Amer): fix these imports to your real bloc file paths/class names —
// I'm assuming BusinessBloc/BusinessState and ProfileBloc/ProfileState
// live where memory says, but I haven't seen the real import paths.
// import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
// import 'package:aklatna/features/profile/presentation/bloc/profile_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:aklatna/presentation/search/widgets/search_result_card.dart';
// import 'package:aklatna/core/theme/app_colors.dart';
// import 'package:aklatna/core/constants/app_text_style.dart';

/// No constructor params — matches your HomePage convention. All data via
/// context.read / BlocBuilder.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // final _recentStorage = RecentSearchStorage(); // TODO(Amer): pull from GetIt (sl()) instead once wired
  final _controller = TextEditingController();
  List<String> _recentKeywords = [];
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // context.read<MenuBloc>().add(GetMenu());
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    // final recent = await _recentStorage.getRecent();
    // if (mounted) setState(() => _recentKeywords = recent);
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (value.trim().isEmpty) return;
      context.read<BusinessBloc>().add(SearchBusinesses(query: value.trim()));
    });
  }

  void _onRecentKeywordTap(String keyword) {
    _controller.text = keyword;
    setState(() => _query = keyword);
    // TODO(Amer): dispatch search event with `keyword`, same as above.
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              // TODO(Amer): wire real imageUrl from ProfileBloc.
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  final photo = state is ProfileLoaded
                      ? state.profile.profilePhoto
                      : null;
                  return SearchHeader(imageUrl: photo);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              app.SearchBar(
                controller: _controller,
                onQueryChanged: _onQueryChanged,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: _query.trim().isEmpty
                    ? _buildIdleContent()
                    : _buildResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shown when there's no active query — recent keywords + popular dishes.
  Widget _buildIdleContent() {
    return ListView(
      children: [
        if (_recentKeywords.isNotEmpty) ...[
          RecentKeywords(keywords: _recentKeywords, onTap: _onRecentKeywordTap),
          const SizedBox(height: AppSpacing.lg),
        ],
        // Popular dishes — menu_items joined to businesses, ordered by
        // businesses.rating desc. Query/Bloc not built yet, so itemCount
        // is 0 until wired — no dummy data, section just collapses.
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // TODO(Amer): itemCount: state.dishes.length once the Bloc exists.
            itemCount: 0,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) => const PopularDishCard(
              photoUrl: '',
              dishNameAr: '',
              businessNameAr: '',
            ),
          ),
        ),
      ],
    );
  }

  /// Shown once there's an active query — delegates to BusinessBloc state.
  Widget _buildResults() {
    // TODO(Amer): replace this stub with your real BlocBuilder:
    //
    return BlocBuilder<BusinessBloc, BusinessState>(
      builder: (context, state) {
        if (state is BusinessLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BusinessUnfound) {
          return Center(
            child: Text('ما لقينا نتائج', style: AppTextStyles.bodyMedium),
          );
        }
        if (state is BusinessError) {
          return Center(
            child: Text(state.message, style: AppTextStyles.bodyMedium),
          );
        }
        if (state is BusinessFetched) {
          return ListView.separated(
            itemCount: state.businesses.length,
            separatorBuilder: (_, __) =>
                const Divider(color: AppColors.divider),
            itemBuilder: (context, index) {
              final business = state.businesses[index];
              return GestureDetector(
                onTap: () {
                  // TODO(Amer): navigate to restaurant detail with business.id
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: SearchResultCard(business: business),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
