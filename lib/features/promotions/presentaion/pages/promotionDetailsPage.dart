import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/cart/domain/entities/cartItem.dart';
import 'package:aklatna/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../menu/presentation/widgets/AddToCartSection.dart';
import '../../../menu/presentation/widgets/FoodDetailsImage.dart';

class PromotionDetailsPage extends StatefulWidget {
  const PromotionDetailsPage({
    super.key,
    required this.promotion,
  });

  final PromotionEntity promotion;

  @override
  State<PromotionDetailsPage> createState() =>
      _PromotionDetailsPageState();
}

class _PromotionDetailsPageState
    extends State<PromotionDetailsPage> {
  int _quantity = 1;

  final TextEditingController _noteController =
      TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  double get _price =>
      widget.promotion.newPrice ?? 0;

  bool get _hasDiscount =>
      widget.promotion.discountPercentage > 0 &&
      widget.promotion.oldPrice != null &&
      widget.promotion.oldPrice! > _price;

  double get _savings =>
      _hasDiscount
          ? widget.promotion.oldPrice! - _price
          : 0;

  // =========================================================================
  // GO HOME
  // =========================================================================

  void _goHome() {
    if (!mounted) return;

    context.go('/home');
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final promo = widget.promotion;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (
        didPop,
        result,
      ) {
        if (didPop) return;

        _goHome();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // =====================================================
                      // HERO
                      // =====================================================

                      _buildHero(
                        context,
                        promo,
                      ),

                      // =====================================================
                      // CONTENT
                      // =====================================================

                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // =================================================
                            // BUSINESS
                            // =================================================

                            _buildBusinessRow(
                              context,
                              promo,
                            ),

                            const SizedBox(
                              height: AppSpacing.lg,
                            ),

                            // =================================================
                            // PROMOTION LABEL
                            // =================================================

                            Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: AppColors
                                        .primaryLight,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      AppRadius.full,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons
                                            .local_offer_rounded,
                                        size: 14,
                                        color: AppColors
                                            .primary,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        promo.label
                                                    ?.trim()
                                                    .isNotEmpty ==
                                                true
                                            ? promo.label!
                                            : 'عرض خاص',
                                        style:
                                            AppTextStyles
                                                .caption
                                                .copyWith(
                                          color: AppColors
                                              .primary,
                                          fontWeight:
                                              FontWeight
                                                  .w800,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: AppSpacing.sm,
                            ),

                            // =================================================
                            // ITEM NAME
                            // =================================================

                            Text(
                              promo.itemName,
                              textDirection:
                                  TextDirection.rtl,
                              style:
                                  AppTextStyles.h2.copyWith(
                                color: AppColors
                                    .textPrimary,
                                fontWeight:
                                    FontWeight.w900,
                                height: 1.15,
                              ),
                            ),

                            const SizedBox(
                              height: AppSpacing.md,
                            ),

                            // =================================================
                            // PRICE
                            // =================================================

                            _buildPriceSection(),

                            // =================================================
                            // DESCRIPTION
                            // =================================================

                            if (promo.description !=
                                    null &&
                                promo.description!
                                    .trim()
                                    .isNotEmpty) ...[
                              const SizedBox(
                                height: AppSpacing.lg,
                              ),
                              _buildDescription(
                                promo.description!,
                              ),
                            ],

                            // =================================================
                            // SAVINGS
                            // =================================================

                            if (_hasDiscount) ...[
                              const SizedBox(
                                height: AppSpacing.lg,
                              ),
                              _buildSavingsCard(),
                            ],

                            // =================================================
                            // NOTES
                            // =================================================

                            const SizedBox(
                              height: AppSpacing.xl,
                            ),

                            _buildNotesSection(),

                            const SizedBox(
                              height: AppSpacing.lg,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =============================================================
              // CART ACTION
              // =============================================================

              _buildCartSection(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // HERO
  // =========================================================================

  Widget _buildHero(
    BuildContext context,
    PromotionEntity promo,
  ) {
    return Stack(
      children: [
        FoodDetailsImage(
          imageUrl: promo.photoUrl,
          onBack: _goHome,
        ),

        if (_hasDiscount)
          Positioned(
            top: 18,
            right: 18,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.full,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.18),
                    blurRadius: 12,
                    offset:
                        const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons
                        .local_fire_department_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    'خصم ${promo.discountPercentage}%',
                    style: AppTextStyles
                        .bodySmall
                        .copyWith(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // =========================================================================
  // BUSINESS
  // =========================================================================

  Widget _buildBusinessRow(
    BuildContext context,
    PromotionEntity promo,
  ) {
    return Material(
      color: AppColors.surface,
      borderRadius:
          BorderRadius.circular(
        AppRadius.lg,
      ),
      child: InkWell(
        onTap: () {
          context.push(
            '/business/${promo.businessId}',
          );
        },
        borderRadius:
            BorderRadius.circular(
          AppRadius.lg,
        ),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              AppRadius.lg,
            ),
            border: Border.all(
              color: AppColors.border
                  .withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  color:
                      AppColors.primary,
                  size: 19,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'من',
                      style: AppTextStyles
                          .caption
                          .copyWith(
                        color:
                            AppColors.textHint,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    Text(
                      promo.businessName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: AppTextStyles
                          .bodyMedium
                          .copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 32,
                height: 32,
                decoration:
                    const BoxDecoration(
                  color:
                      AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .arrow_back_ios_new_rounded,
                  size: 13,
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // PRICE
  // =========================================================================

  Widget _buildPriceSection() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: [
        Text(
          '${_formatPrice(_price)} ل.س',
          style: AppTextStyles
              .priceLarge
              .copyWith(
            color:
                AppColors.primary,
            fontWeight:
                FontWeight.w900,
            fontSize: 25,
            height: 1,
          ),
        ),

        const SizedBox(width: 10),

        if (_hasDiscount)
          Padding(
            padding:
                const EdgeInsets.only(
              bottom: 2,
            ),
            child: Text(
              '${_formatPrice(widget.promotion.oldPrice!)} ل.س',
              style: AppTextStyles
                  .bodyMedium
                  .copyWith(
                color:
                    AppColors.textHint,
                decoration:
                    TextDecoration
                        .lineThrough,
                decorationThickness:
                    1.4,
                fontSize: 12,
              ),
            ),
          ),

        const Spacer(),

        if (_hasDiscount)
          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            decoration:
                BoxDecoration(
              color:
                  AppColors.primaryLight,
              borderRadius:
                  BorderRadius.circular(
                AppRadius.sm,
              ),
            ),
            child: Text(
              '-${widget.promotion.discountPercentage}%',
              style: AppTextStyles
                  .caption
                  .copyWith(
                color:
                    AppColors.primary,
                fontWeight:
                    FontWeight.w900,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }

  // =========================================================================
  // DESCRIPTION
  // =========================================================================

  Widget _buildDescription(
    String description,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'عن العرض',
          style:
              AppTextStyles.h4.copyWith(
            fontWeight:
                FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          textDirection:
              TextDirection.rtl,
          style: AppTextStyles
              .bodyMedium
              .copyWith(
            color:
                AppColors.textSecondary,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // SAVINGS
  // =========================================================================

  Widget _buildSavingsCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            AppColors.primaryLight,
        borderRadius:
            BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: AppColors.primary
              .withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                const BoxDecoration(
              color:
                  AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.savings_rounded,
              color:
                  AppColors.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'أنت توفر',
                  style: AppTextStyles
                      .caption
                      .copyWith(
                    color: AppColors
                        .textSecondary,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  '${_formatPrice(_savings)} ل.س',
                  style: AppTextStyles
                      .bodyMedium
                      .copyWith(
                    color: AppColors
                        .primary,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          Text(
            'صفقة حلوة 👌',
            style: AppTextStyles
                .caption
                .copyWith(
              color:
                  AppColors.primary,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // NOTES
  // =========================================================================

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ملاحظات',
              style: AppTextStyles
                  .h4
                  .copyWith(
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'اختياري',
              style: AppTextStyles
                  .caption
                  .copyWith(
                color:
                    AppColors.textHint,
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),

        TextField(
          controller:
              _noteController,
          maxLines: 2,
          textDirection:
              TextDirection.rtl,
          decoration:
              InputDecoration(
            hintText:
                'مثال: بدون بصل، صوص إضافي...',
            hintStyle: AppTextStyles
                .bodySmall
                .copyWith(
              color:
                  AppColors.textHint,
            ),
            filled: true,
            fillColor:
                AppColors.surface,
            contentPadding:
                const EdgeInsets.all(
              13,
            ),
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.lg,
              ),
              borderSide: BorderSide(
                color: AppColors.border
                    .withOpacity(0.6),
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.lg,
              ),
              borderSide: BorderSide(
                color: AppColors.border
                    .withOpacity(0.6),
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.lg,
              ),
              borderSide:
                  const BorderSide(
                color:
                    AppColors.primary,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // CART
  // =========================================================================

  Widget _buildCartSection() {
    return Material(
      color:
          AppColors.background,
      elevation: 10,
      shadowColor:
          Colors.black.withOpacity(
        0.08,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            AppSpacing.md,
            10,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: AddToCartSection(
            price: (_price * _quantity)
                .toStringAsFixed(0),
            quantity: _quantity,
            onIncrement: () {
              setState(() {
                _quantity++;
              });
            },
            onDecrement: () {
              if (_quantity > 1) {
                setState(() {
                  _quantity--;
                });
              }
            },
            onAddToCart:
                _addToCart,
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // ADD TO CART
  // =========================================================================

  void _addToCart() {
    final promo =
        widget.promotion;

    context.read<CartBloc>().add(
      AddItemEvent(
        item: CartItem(
          itemId:
              promo.menuItemId ??
                  'promo_${promo.id}',
          nameAr:
              promo.itemName,
          description: '',
          photoUrl:
              promo.photoUrl,
          price: _price,
          quantity:
              _quantity,
          businessId:
              promo.businessId,
          note: _noteController
              .text
              .trim(),
          selectedAddons:
              const [],
        ),
        businessName:
            promo.businessName,
        businessLogo: null,
      ),
    );

    _goHome();
  }

  // =========================================================================
  // FORMAT PRICE
  // =========================================================================

  String _formatPrice(
    double price,
  ) {
    return price
        .toInt()
        .toString()
        .replaceAllMapped(
          RegExp(
            r'\B(?=(\d{3})+(?!\d))',
          ),
          (match) => ',',
        );
  }
}
