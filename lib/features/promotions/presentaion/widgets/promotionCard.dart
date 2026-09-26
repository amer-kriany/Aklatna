import 'dart:async';

import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PromotionCard extends StatefulWidget {
  const PromotionCard({
    super.key,
    required this.businessName,
    required this.coverUrl,
    required this.itemName,
    this.label,
    this.menuItemId,
    required this.discountPercentage,
    this.oldPrice,
    this.newPrice,
    required this.onTap,
    this.width,
    this.currencySymbol = 'ل.س',
  });

  final String businessName;
  final String? coverUrl;
  final String itemName;
  final String? label;
  final String? menuItemId;

  final int discountPercentage;
  final double? oldPrice;
  final double? newPrice;

  final VoidCallback onTap;

  final double? width;
  final String currencySymbol;

  static const double cardHeight = 252;
  static const double imageHeight = 148;

  @override
  State<PromotionCard> createState() => _PromotionCardState();
}

class _PromotionCardState extends State<PromotionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _imageScale;
  late final Animation<double> _shinePosition;

  bool _pressed = false;

  bool get _hasDiscount => widget.discountPercentage > 0;

  String get _displayName {
    if (widget.menuItemId == null &&
        widget.label != null &&
        widget.label!.trim().isNotEmpty) {
      return widget.label!;
    }

    return widget.itemName;
  }

  double get _savingsAmount {
    if (!_hasDiscount ||
        widget.oldPrice == null ||
        widget.newPrice == null ||
        widget.oldPrice! <= widget.newPrice!) {
      return 0;
    }

    return widget.oldPrice! - widget.newPrice!;
  }

  double _resolveWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (widget.width != null) {
      return widget.width!;
    }

    return (screenWidth * 0.47).clamp(178.0, 208.0);
  }
@override
void initState() {
  super.initState();

  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  _imageScale = Tween<double>(
    begin: 1.0,
    end: 1.035,
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutSine,
    ),
  );

  _shinePosition = Tween<double>(
    begin: -1.5,
    end: 1.5,
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ),
  );

  _animationController.repeat(reverse: true);
}
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!mounted) return;

    setState(() {
      _pressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    if (!mounted) return;

    setState(() {
      _pressed = false;
    });

    widget.onTap();
  }

  void _handleTapCancel() {
    if (!mounted) return;

    setState(() {
      _pressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = _resolveWidth(context);

    return AnimatedScale(
      scale: _pressed ? 0.975 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: SizedBox(
        width: cardWidth,
        height: PromotionCard.cardHeight,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            splashColor: AppColors.primary.withOpacity(0.06),
            highlightColor: AppColors.primary.withOpacity(0.025),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: AppColors.border.withOpacity(0.38),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.07),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(cardWidth),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        12,
                        9,
                        12,
                        10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBusiness(),

                          const SizedBox(height: 4),

                          Text(
                            _displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),

                          const Spacer(),

                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: _buildPrice(),
                              ),

                              const SizedBox(width: 8),

                              _buildArrowButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusiness() {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.storefront_rounded,
            size: 12,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            widget.businessName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.regularSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(double cardWidth) {
    return SizedBox(
      width: double.infinity,
      height: PromotionCard.imageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
            child: AnimatedBuilder(
              animation: _imageScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _imageScale.value,
                  child: child,
                );
              },
              child: _buildCoverImage(),
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [
                    0.45,
                    1.0,
                  ],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.10),
                  ],
                ),
              ),
            ),
          ),

          if (_hasDiscount)
            Positioned(
              top: 10,
              right: 10,
              child: _buildDiscountBadge(),
            ),

          if (widget.label != null &&
              widget.label!.trim().isNotEmpty &&
              widget.menuItemId != null)
            Positioned(
              bottom: 10,
              left: 10,
              child: _buildDealLabel(cardWidth),
            ),
        ],
      ),
    );
  }

  Widget _buildDiscountBadge() {
    return AnimatedBuilder(
      animation: _shinePosition,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(
                    AppRadius.full,
                  ),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'خصم %${widget.discountPercentage}',
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              Positioned.fill(
                child: FractionalTranslation(
                  translation: Offset(
                    _shinePosition.value,
                    0,
                  ),
                  child: Transform.rotate(
                    angle: 0.25,
                    child: Container(
                      width: 18,
                      color: Colors.white.withOpacity(0.32),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDealLabel(double cardWidth) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: cardWidth * 0.62,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(
          AppRadius.full,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
        ),
      ),
      child: Text(
        widget.label!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    if (widget.coverUrl == null ||
        widget.coverUrl!.trim().isEmpty) {
      return const _ImagePlaceholder();
    }

    return Image.network(
      widget.coverUrl!,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) {
        return const _ImagePlaceholder();
      },
      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return const _ImagePlaceholder();
      },
    );
  }

  Widget _buildPrice() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.oldPrice != null && _hasDiscount)
          Row(
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_formatPrice(widget.oldPrice!)} ${widget.currencySymbol}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                  fontSize: 9.5,
                  decoration: TextDecoration.lineThrough,
                  decorationThickness: 1.2,
                ),
              ),

              if (_savingsAmount > 0) ...[
                const SizedBox(width: 5),
                Text(
                  'وفر ${_formatPrice(_savingsAmount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),

        if (widget.newPrice != null) ...[
          const SizedBox(height: 1),

          Text(
            '${_formatPrice(widget.newPrice!)} ${widget.currencySymbol}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.priceMedium.copyWith(
              color: AppColors.primary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildArrowButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(
          _pressed ? 0.85 : 1.0,
        ),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: _pressed ? 4 : 9,
            offset: Offset(0, _pressed ? 1 : 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.arrow_back_rounded,
        color: AppColors.textOnPrimary,
        size: 19,
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toInt()
        .toString()
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_rounded,
        color: AppColors.primary,
        size: AppSizes.iconXl,
      ),
    );
  }
}
