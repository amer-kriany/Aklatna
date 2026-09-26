
import 'package:aklatna/features/job_listings/domain/entities/jobEntity.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    required this.onCall,
  });

  final JobEntity job;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
        border: Border.all(
          color: AppColors.border.withOpacity(0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================================================================
          // HEADER
          // ================================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // JOB ICON
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(
                      AppRadius.md,
                    ),
                  ),
                  child: const Icon(
                    Icons.work_outline_rounded,
                    color: AppColors.primary,
                    size: 23,
                  ),
                ),

                const SizedBox(
                  width: AppSpacing.sm,
                ),

                // TITLE + BUSINESS
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons.storefront_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Expanded(
                            child: Text(
                              job.businessName,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: AppTextStyles.regularSmall
                                  .copyWith(
                                color:
                                    AppColors.textSecondary,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: AppSpacing.sm,
                ),

                // AVAILABLE BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.full,
                    ),
                  ),
                  child: Text(
                    'متاحة',
                    style:
                        AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================================================================
          // LOCATION
          // ================================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(
                  AppRadius.md,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(
                    width: AppSpacing.xs,
                  ),
                  Expanded(
                    child: Text(
                      job.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regularSmall
                          .copyWith(
                        color:
                            AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          // ================================================================
          // DESCRIPTION
          // ================================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'عن الوظيفة',
                  style: AppTextStyles.bodyMedium
                      .copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  job.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.regularSmall
                      .copyWith(
                    color:
                        AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // ================================================================
          // REQUIREMENTS
          // ================================================================

          if (job.requirements.isNotEmpty) ...[
            const SizedBox(
              height: AppSpacing.md,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight
                      .withOpacity(0.55),
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.checklist_rounded,
                      color: AppColors.primary,
                      size: 19,
                    ),
                    const SizedBox(
                      width: AppSpacing.xs,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المتطلبات',
                            style: AppTextStyles
                                .bodySmall
                                .copyWith(
                              color:
                                  AppColors.primary,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            job.requirements,
                            maxLines: 3,
                            overflow:
                                TextOverflow.ellipsis,
                            style: AppTextStyles
                                .regularSmall
                                .copyWith(
                              color:
                                  AppColors.textPrimary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ================================================================
          // CALL CTA
          // ================================================================

          Padding(
            padding: const EdgeInsets.all(
              AppSpacing.md,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onCall,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,
                  foregroundColor:
                      AppColors.textOnPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.md,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      size: 19,
                    ),
                    const SizedBox(
                      width: AppSpacing.xs,
                    ),
                    Text(
                      'اتصل للتقديم',
                      style: AppTextStyles
                          .buttonMedium
                          .copyWith(
                        color:
                            AppColors.textOnPrimary,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Container(
                      width: 1,
                      height: 18,
                      color: Colors.white
                          .withOpacity(0.35),
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Flexible(
                      child: Text(
                        job.contactPhone,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: AppTextStyles
                            .regularSmall
                            .copyWith(
                          color: Colors.white
                              .withOpacity(0.9),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
