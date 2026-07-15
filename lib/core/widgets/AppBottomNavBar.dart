import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Aklatna (أكلتنا) — App-wide bottom navigation bar.
///
/// Pure presentation widget: knows nothing about go_router or Bloc.
/// The page/shell layer owns `currentIndex` and passes `onTap` to switch tabs.
///
/// Order: Home, Search, Cart, Orders, Jobs.
/// Profile dropped from bottom nav — needs a new home (e.g. header icon).
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'الرئيسية',
    ),
    _NavItem(
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
      label: 'بحث',
    ),
    _NavItem(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart_rounded,
      label: 'السلة',
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'طلباتي',
    ),
    _NavItem(
      // Placeholder — no Figma reference for this tab.
      icon: Icons.work_outline_rounded,
      activeIcon: Icons.work_rounded,
      label: 'وظائف',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = index == currentIndex;
              return Expanded(
                child: _NavBarButton(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarButton extends StatelessWidget {
  const _NavBarButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              size: AppSizes.iconLg,
              color: color,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              item.label,
              style: AppTextStyles.caption.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}