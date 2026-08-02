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

// ===========================================================================
// RATING PAGE
// ===========================================================================
//
// Full screen, pushed on the ROOT navigator the moment an order becomes
// `completed` — regardless of which tab/page the customer is currently on.
// Self-contained: builds its own ReviewBloc inline (same pattern as
// /food/:id and /business/:id in the router — no GetIt for feature Blocs).
// ===========================================================================

class RatingPage extends StatefulWidget {
  const RatingPage({super.key, required this.order});

  final OrderEntity order;

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  late final ReviewBloc _reviewBloc;

  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  // Angry -> Happy, index 0..4 maps to rating 1..5
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

  // Selected face color scales from error (angry) to primary (happy).
  // Only using confirmed AppColors tokens, no invented ones.
  Color _faceColor(int index, bool selected) {
    if (!selected) return AppColors.textSecondary;

    if (index <= 1) return AppColors.error;
    if (index == 2) return AppColors.textPrimary;
    return AppColors.primary;
  }

  void _submit() {
    final orderId = widget.order.id;

    if (orderId == null || _selectedRating == 0) return;

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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
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
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'لاحقًا',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),

                    Text(
                      'كيف كانت تجربتك؟',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      widget.order.businessName ?? 'المطعم',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Faces row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        final ratingValue = index + 1;
                        final selected = _selectedRating == ratingValue;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRating = ratingValue;
                            });
                          },
                          child: AnimatedScale(
                            scale: selected ? 1.15 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Column(
                              children: [
                                Icon(
                                  _faceIcons[index],
                                  size: 40,
                                  color: _faceColor(index, selected),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _faceLabels[index],
                                  style: AppTextStyles.regularSmall.copyWith(
                                    color: selected
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'ملاحظات إضافية (اختياري)',
                        hintStyle: AppTextStyles.regularSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),

                    const Spacer(),

                    BlocBuilder<ReviewBloc, ReviewState>(
                      builder: (context, state) {
                        final submitting = state is ReviewSubmitting;

                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          onPressed: (_selectedRating == 0 || submitting)
                              ? null
                              : _submit,
                          child: submitting
                              ? const Skeleton(
                                  width: 20,
                                  height: 20,
                                  isCircle: true,
                                  baseColor: Colors.white24,
                                  highlightColor: Colors.white70,
                                )
                              : Text(
                                  'إرسال التقييم',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      },
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
