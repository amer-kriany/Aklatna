import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ConfirmButton extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmButton({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height:
          56, // You can also put this in AppSpacing/AppConstants if you have a standard button height
      child: ElevatedButton(
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // Replaced 0xFFF97316
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          'تأكيد الطلب',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
