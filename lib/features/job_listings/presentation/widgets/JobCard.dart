import 'package:aklatna/features/job_listings/domain/entities/jobEntity.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, required this.onCall});

  final JobEntity job;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(job.title, style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              const Icon(Icons.storefront_outlined, size: AppSizes.iconSm, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  job.businessName,
                  style: AppTextStyles.regularMedium.copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.location_on_outlined, size: AppSizes.iconSm, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xxs),
              Text(job.location, style: AppTextStyles.regularMedium.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            job.description,
            style: AppTextStyles.regularMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (job.requirements.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('المتطلبات:', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              job.requirements,
              style: AppTextStyles.regularSmall.copyWith(color: AppColors.textSecondary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onCall,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              icon: const Icon(Icons.call, size: AppSizes.iconSm),
              label: Text('اتصل الآن — ${job.contactPhone}', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}