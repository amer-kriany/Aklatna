import 'package:flutter/material.dart';

import 'package:aklatna/core/theme/app_colors.dart';

class HomeStateView extends StatelessWidget {
  const HomeStateView.loading({super.key})
    : message = 'جار تحميل المطاعم...',
      onRetry = null,
      isLoading = true;

  const HomeStateView.error({
    required this.message,
    required this.onRetry,
    super.key,
  }) : isLoading = false;

  final String message;
  final VoidCallback? onRetry;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const CircularProgressIndicator(color: AppColors.primary)
            else
              const Icon(
                Icons.wifi_off_rounded,
                size: 42,
                color: AppColors.primary,
              ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 20 / 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (!isLoading) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: 160,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('إعادة المحاولة'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
