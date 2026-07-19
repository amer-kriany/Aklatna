import 'package:aklatna/features/job_listings/presentation/bloc/job_bloc.dart';
import 'package:aklatna/features/job_listings/presentation/widgets/JobCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';

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
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('وظائف', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: BlocBuilder<JobBloc, JobState>(
                    builder: (context, state) {
                      if (state is JobLoading || state is JobInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is JobError) {
                        return Center(child: Text(state.message));
                      }
                      if (state is! JobLoaded) {
                        return const SizedBox.shrink();
                      }
                      if (state.jobs.isEmpty) {
                        return Center(child: Text('لا توجد وظائف متاحة حالياً', style: AppTextStyles.bodyMedium));
                      }

                      return ListView.separated(
                        itemCount: state.jobs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final job = state.jobs[index];
                          return JobCard(job: job, onCall: () => _callNumber(job.contactPhone));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}