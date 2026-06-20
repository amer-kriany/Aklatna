import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:aklatna/core/constants/app_assets.dart';
import 'package:aklatna/core/theme/app_colors.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextField(
        textAlign: TextAlign.right,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'ابحث عن مطعم أو وجبة',
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          enabledBorder: _border(AppColors.cardBorder),
          focusedBorder: _border(AppColors.primary),
          border: _border(AppColors.cardBorder),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(13),
            child: SvgPicture.asset(
              AppAssets.search,
              colorFilter: const ColorFilter.mode(
                AppColors.textMuted,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }
}
