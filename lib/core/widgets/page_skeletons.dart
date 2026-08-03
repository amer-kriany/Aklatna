import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/widgets/skeleton.dart';
import 'package:flutter/material.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({
    super.key,
    this.statsCount = 3,
    this.gridItemCount = 6,
  });

  final int statsCount;
  final int gridItemCount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(width: 180, height: 22),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: List.generate(statsCount, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == statsCount - 1 ? 0 : AppSpacing.sm,
                  ),
                  child: const Skeleton(height: 74, radius: AppRadius.md),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Skeleton(width: 140, height: 18),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gridItemCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (_, __) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Skeleton(
                      width: double.infinity,
                      radius: AppRadius.lg,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Skeleton(width: 120, height: 12, radius: AppRadius.sm),
                  SizedBox(height: AppSpacing.xs),
                  Skeleton(width: 80, height: 12, radius: AppRadius.sm),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class TableSkeleton extends StatelessWidget {
  const TableSkeleton({super.key, this.rows = 6, this.columns = 4});

  final int rows;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: rows + 1,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final isHeader = index == 0;
        return Row(
          children: List.generate(columns, (columnIndex) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: columnIndex == columns - 1 ? 0 : AppSpacing.xs,
                ),
                child: Skeleton(
                  height: isHeader ? 12 : 16,
                  radius: AppRadius.sm,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.lg,
      ),
      child: const Column(
        children: [
          SizedBox(height: AppSpacing.lg),
          Skeleton(width: 96, height: 96, isCircle: true),
          SizedBox(height: AppSpacing.md),
          Skeleton(width: 160, height: 16),
          SizedBox(height: AppSpacing.sm),
          Skeleton(width: 220, height: 12),
          SizedBox(height: AppSpacing.xl),
          _ProfileSectionSkeleton(),
        ],
      ),
    );
  }
}

class _ProfileSectionSkeleton extends StatelessWidget {
  const _ProfileSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Skeleton(width: 36, height: 36, isCircle: true),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: Skeleton(height: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({
    super.key,
    this.itemCount = 6,
    this.showLeadingCircle = true,
  });

  final int itemCount;
  final bool showLeadingCircle;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, __) {
        return Row(
          children: [
            if (showLeadingCircle) ...[
              const Skeleton(width: 44, height: 44, isCircle: true),
              const SizedBox(width: AppSpacing.sm),
            ],
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: double.infinity, height: 14),
                  SizedBox(height: AppSpacing.xs),
                  Skeleton(width: 160, height: 12, radius: AppRadius.sm),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
