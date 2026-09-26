import 'package:aklatna/features/job_listings/presentation/bloc/job_bloc.dart';
import 'package:aklatna/features/job_listings/presentation/widgets/JobCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_skeletons.dart';
import '../../../../core/widgets/skeleton_switch.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  @override
  void initState() {
    super.initState();

    if (context.read<JobBloc>().state is JobInitial) {
      context.read<JobBloc>().add(GetJobsEvent());
    }
  }

  Future<void> _callNumber(String phone) async {
    final cleanedPhone =
        phone.replaceAll(RegExp(r'[^\d+]'), '');

    final Uri uri = Uri(
      scheme: 'tel',
      path: cleanedPhone,
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر إجراء الاتصال بالرقم $cleanedPhone',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حدث خطأ أثناء محاولة الاتصال',
          ),
        ),
      );
    }
  }

  Future<void> _refresh() async {
    context.read<JobBloc>().add(GetJobsEvent());

    await Future.delayed(
      const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<JobBloc, JobState>(
            builder: (context, state) {
              return SkeletonSwitch(
                isLoading:
                    state is JobLoading ||
                    state is JobInitial,
                skeleton: const ListSkeleton(
                  itemCount: 5,
                ),
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  color: AppColors.primary,
                  child: _buildContent(
                    context,
                    state,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    JobState state,
  ) {
    if (state is JobError) {
      return _buildErrorState(
        context,
        state.message,
      );
    }

    if (state is! JobLoaded) {
      return const SizedBox.shrink();
    }

    final jobs = state.jobs;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        // ============================================================
        // HEADER
        // ============================================================

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الوظائف',
                        style: AppTextStyles.h2.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(
                        height: AppSpacing.xxs,
                      ),
                      Text(
                        'اكتشف فرص العمل المتاحة بالقرب منك',
                        style:
                            AppTextStyles.regularMedium
                                .copyWith(
                          color:
                              AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // ========================================================
                // JOB COUNT
                // ========================================================

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.full,
                    ),
                  ),
                  child: Text(
                    '${jobs.length} وظيفة',
                    style:
                        AppTextStyles.regularSmall
                            .copyWith(
                      color: AppColors.primary,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ============================================================
        // SECTION TITLE
        // ============================================================

        if (jobs.isNotEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                'أحدث الوظائف',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

        // ============================================================
        // EMPTY STATE
        // ============================================================

        if (jobs.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(),
          ),

        // ============================================================
        // JOB LIST
        // ============================================================

        if (jobs.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final job = jobs[index];

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.md,
                    ),
                    child: JobCard(
                      job: job,
                      onCall: () =>
                          _callNumber(
                        job.contactPhone,
                      ),
                    ),
                  );
                },
                childCount: jobs.length,
              ),
            ),
          ),
      ],
    );
  }

  // ==============================================================
  // EMPTY STATE
  // ==============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work_outline_rounded,
                size: 34,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              'لا توجد وظائف متاحة حالياً',
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            Text(
              'سنخبرك عندما تتوفر فرص عمل جديدة',
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.regularMedium.copyWith(
                color:
                    AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // ERROR STATE
  // ==============================================================

  Widget _buildErrorState(
    BuildContext context,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(
                  0.12,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 32,
                color: Colors.orange,
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              'تعذر تحميل الوظائف',
              style:
                  AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.regularMedium.copyWith(
                color:
                    AppColors.textSecondary,
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<JobBloc>()
                    .add(GetJobsEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    AppColors.textOnPrimary,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 12,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
              ),
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),
              label: const Text(
                'إعادة المحاولة',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
