import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.photoUrl,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.onEditPhoto,
  });

  final String? photoUrl;
  final String userName;
  final String email;
  final String phoneNumber;
  final VoidCallback onEditPhoto;

  static const double _avatarSize = 96;

  bool get _hasValidPhotoUrl {
    final url = photoUrl ?? '';
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: _avatarSize,
            height: _avatarSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(_avatarSize / 2),
                  child: SizedBox(
                    width: _avatarSize,
                    height: _avatarSize,
                    child: _hasValidPhotoUrl
                        ? Image.network(photoUrl!, fit: BoxFit.cover)
                        : Container(
                            color: AppColors.surface,
                            alignment: Alignment.center,
                            child: const Icon(Icons.person, size: AppSizes.iconXl, color: AppColors.textSecondary),
                          ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: InkWell(
                    onTap: onEditPhoto,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.edit, color: AppColors.textOnPrimary, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(userName, style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '$email | $phoneNumber',
            style: AppTextStyles.regularMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}