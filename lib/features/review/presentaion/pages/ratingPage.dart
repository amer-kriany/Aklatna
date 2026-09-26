
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/review/data/datasource/reviewRemoteDatasource.dart';
import 'package:aklatna/features/review/data/repository/reviewRepoImp.dart';
import 'package:aklatna/features/review/domain/entity/reviewEntity.dart';
import 'package:aklatna/features/review/domain/usecase/submitReviewUsecase.dart';
import 'package:aklatna/features/review/presentaion/bloc/review_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({
    super.key,
    required this.order,
  });

  final OrderEntity order;

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  late final ReviewBloc _reviewBloc;

  int _selectedRating = 0;

  final TextEditingController _commentController =
      TextEditingController();

  static const List<IconData> _faceIcons = [
    Icons.sentiment_very_dissatisfied_rounded,
    Icons.sentiment_dissatisfied_rounded,
    Icons.sentiment_neutral_rounded,
    Icons.sentiment_satisfied_rounded,
    Icons.sentiment_very_satisfied_rounded,
  ];

  static const List<String> _faceLabels = [
    'سيء جدًا',
    'سيء',
    'عادي',
    'حلو',
    'ممتاز',
  ];

  @override
  void initState() {
    super.initState();

    final reviewDatasource = ReviewRemoteDatasource();

    final reviewRepo = ReviewRepositoryImpl(
      reviewRemoteDatasource: reviewDatasource,
    );

    _reviewBloc = ReviewBloc(
      submitReviewUsecase: SubmitReviewUsecase(
        reviewRepositoryImpl: reviewRepo,
      ),
    );
  }

  @override
  void dispose() {
    _reviewBloc.close();
    _commentController.dispose();
    super.dispose();
  }

  Color _ratingColor(int rating) {
    if (rating <= 2) {
      return AppColors.error;
    }

    if (rating == 3) {
      return AppColors.textPrimary;
    }

    return AppColors.primary;
  }

  String _ratingMessage() {
    switch (_selectedRating) {
      case 1:
        return 'نأسف إن تجربتك لم تكن جيدة';
      case 2:
        return 'نتمنى أن تكون تجربتك القادمة أفضل';
      case 3:
        return 'شكرًا لمشاركتنا رأيك';
      case 4:
        return 'سعداء أن تجربتك كانت جيدة';
      case 5:
        return 'رائع! سعيدين جدًا بتجربتك 😍';
      default:
        return 'اختر تقييمك لتخبرنا عن تجربتك';
    }
  }

  void _submit() {
    final orderId = widget.order.id;

    if (orderId == null || _selectedRating == 0) {
      return;
    }

    final comment = _commentController.text.trim();

    _reviewBloc.add(
      SubmitReviewEvent(
        review: ReviewEntity(
          orderId: orderId,
          businessId: widget.order.businessId,
          customerId: widget.order.customerId,
          rating: _selectedRating,
          comment: comment.isEmpty ? null : comment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _reviewBloc,
      child: BlocListener<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is ReviewSubmitted) {
            Navigator.of(context).pop();
          }

          if (state is ReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.sm,
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'لاحقًا',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color:
                            AppColors.primary.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.rate_review_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      'كيف كانت تجربتك؟',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      'شاركنا رأيك في طلبك من',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      widget.order.businessName ?? 'المطعم',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    Container(
                      padding: const EdgeInsets.all(
                        AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _ratingMessage(),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _selectedRating == 0
                                  ? AppColors.textSecondary
                                  : _ratingColor(
                                      _selectedRating,
                                    ),
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(
                            height: AppSpacing.lg,
                          ),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              5,
                              (index) {
                                final rating = index + 1;
                                final selected =
                                    _selectedRating == rating;

                                return _RatingFace(
                                  icon: _faceIcons[index],
                                  label: _faceLabels[index],
                                  selected: selected,
                                  color:
                                      _ratingColor(rating),
                                  onTap: () {
                                    setState(() {
                                      _selectedRating =
                                          rating;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'ملاحظاتك',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      'اختياري — أخبرنا بأي شيء يمكن أن يحسن تجربتك',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      textAlign: TextAlign.right,
                      textInputAction:
                          TextInputAction.newline,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText:
                            'اكتب ملاحظتك هنا...',
                        hintStyle:
                            AppTextStyles.regularSmall.copyWith(
                          color:
                              AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding:
                            const EdgeInsets.all(
                          AppSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            AppRadius.lg,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.border,
                          ),
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            AppRadius.lg,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.border,
                          ),
                        ),
                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            AppRadius.lg,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    BlocBuilder<ReviewBloc, ReviewState>(
                      builder: (context, state) {
                        final submitting =
                            state is ReviewSubmitting;

                        return SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.primary,
                              disabledBackgroundColor:
                                  AppColors.border,
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                              ),
                            ),
                            onPressed:
                                _selectedRating == 0 ||
                                        submitting
                                    ? null
                                    : _submit,
                            child: submitting
                                ? const Skeleton(
                                    width: 22,
                                    height: 22,
                                    isCircle: true,
                                    baseColor:
                                        Colors.white24,
                                    highlightColor:
                                        Colors.white70,
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      const Icon(
                                        Icons
                                            .send_rounded,
                                        color:
                                            Colors.white,
                                        size: 19,
                                      ),
                                      const SizedBox(
                                        width:
                                            AppSpacing.xs,
                                      ),
                                      Text(
                                        'إرسال التقييم',
                                        style:
                                            AppTextStyles
                                                .bodyMedium
                                                .copyWith(
                                          color:
                                              Colors.white,
                                          fontWeight:
                                              FontWeight
                                                  .w800,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      'تقييمك يساعدنا على تحسين تجربة أكلاتنا',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingFace extends StatelessWidget {
  const _RatingFace({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 52,
        padding: const EdgeInsets.symmetric(
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.10)
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(AppRadius.md),
          border: selected
              ? Border.all(
                  color: color.withOpacity(0.25),
                )
              : Border.all(
                  color: Colors.transparent,
                ),
        ),
        child: Column(
          children: [
            AnimatedScale(
              scale: selected ? 1.15 : 1.0,
              duration:
                  const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: selected ? 39 : 34,
                color: selected
                    ? color
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.caption.copyWith(
                color: selected
                    ? color
                    : AppColors.textSecondary,
                fontWeight: selected
                    ? FontWeight.w800
                    : FontWeight.w500,
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
