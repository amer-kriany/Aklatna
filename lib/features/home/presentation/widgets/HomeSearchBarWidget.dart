import 'package:flutter/material.dart';
import 'package:aklatna/core/theme/app_colors.dart';

class HomeSearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const HomeSearchBarWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              // color: AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              const SizedBox(width: 14),
              const Icon(
                Icons.search_rounded,
                color: AppColors.textHint,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ابحث عن مطعم أو وجبة...',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: AppColors.textHint,)
                  // AppTextStyles.bodyMedium.copyWith(
                    
                  // ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8, right: 8),
                width: 1,
                height: 24,
                // color: AppColors.border,
              ),
              const Icon(
                Icons.tune_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }
}