import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Aklatna (أكلتنا) — Search bar.
///
/// Bloc-blind: owns the TextEditingController only, emits every keystroke
/// through [onQueryChanged]. The page layer decides what to do with that
/// string (e.g. dispatch it to SearchBloc, debounced).
///
/// Mic icon is currently DECORATIVE ONLY — voice search deferred (was
/// scoped, then postponed by Amer). Tapping it does nothing yet. When
/// picked back up: needs `speech_to_text` package + RECORD_AUDIO
/// (Android manifest) + NSMicrophoneUsageDescription/
/// NSSpeechRecognitionUsageDescription (iOS Info.plist).
class SearchBar extends StatefulWidget {
  const SearchBar({super.key, required this.onQueryChanged, required TextEditingController controller});

  final ValueChanged<String> onQueryChanged;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final _controller = TextEditingController();

  void _onMicTap() {
    // TODO(Amer): wire up speech_to_text here when voice search is
    // picked back up. For now this is intentionally a no-op — better
    // than a button that looks real but silently does nothing without
    // any indication.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('البحث الصوتي قريباً')),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: AppSizes.iconMd,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: TextField(
              controller: _controller,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'ابحث عن مطعم...',
                hintStyle: AppTextStyles.hint,
                border: InputBorder.none,
                isCollapsed: true,
              ),
              onChanged: widget.onQueryChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: _onMicTap,
            child: const Icon(
              Icons.mic_none_rounded,
              color: AppColors.textSecondary,
              size: AppSizes.iconMd,
            ),
          ),
        ],
      ),
    );
  }
}