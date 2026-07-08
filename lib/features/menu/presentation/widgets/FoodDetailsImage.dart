import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class FoodDetailsImage extends StatelessWidget {
  const FoodDetailsImage({
    super.key,
    required this.imageUrl,
    this.onBack,
    this.onFavorite,
    this.isFavorite = false,
  });

  final String imageUrl;
  final VoidCallback? onBack;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            height: 260,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFFC869),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Center(
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  height: 210,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: onBack,
                  ),
                  _CircleIconButton(
                    icon: isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    iconColor:
                        isFavorite ? Colors.orange : Colors.black,
                    onPressed: onFavorite,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.iconColor = Colors.black,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}