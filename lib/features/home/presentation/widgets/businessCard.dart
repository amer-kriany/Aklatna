import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';

/// Reusable business card — used in Trending and Open Now sections.
///
/// Deliberately takes plain typed params instead of a Business entity
/// directly, so this widget doesn't care about the real model shape.
/// Whoever wires the Bloc just maps BusinessEntity -> these params.
///
/// NOTE: no distance/ETA/rating badges — dropped, see chat explanation
/// (not in your schema / Phase 1 scope / ratings deferred to Phase 2).
class BusinessCard extends StatelessWidget {
  const BusinessCard({
    super.key,
    required this.name,
    required this.typeLabel, // e.g. "مطعم" or "محل عصائر"
    required this.imageUrl,
    required this.isOpen,
    this.description,
    this.onTap,
    this.width = 390,
  });

  final String name;
  final String typeLabel;
  final String imageUrl;
  final bool isOpen;
  final String? description;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        width: width,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.25),
              offset: Offset(0, 0),
              spreadRadius: 4,
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // business photo later
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                "assets/images/profile.jpg",
                width: 379,
                height: 159,
              ),
            ),
            SizedBox(height: 7),
            // business name later
            Text(
              "Sushi Master - Tokyo Bites",
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.black),
            ),
            SizedBox(height: 3,),
            // business location
            Text("Japanese Cuisine,Shushi Segfood",style:AppTextStyles.caption ,),
            SizedBox(height: 15,),
            Row(children: [
              // stars thing don't know how the fuck we will do it
              
            ],)
          ],
        ),
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  const _OpenBadge({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
      ),
      child: Text(
        isOpen ? 'مفتوح' : 'مغلق',
        style: AppTextStyles.overline.copyWith(
          color: isOpen ? AppColors.openBadge : AppColors.closedBadge,
        ),
      ),
    );
  }
}
