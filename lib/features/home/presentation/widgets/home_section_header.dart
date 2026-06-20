import 'package:flutter/material.dart';

import 'package:aklatna/core/theme/app_colors.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    required this.title,
    required this.actionText,
    super.key,
  });

  final String title;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(actionText),
        ),
        const Spacer(),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            height: 28 / 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
