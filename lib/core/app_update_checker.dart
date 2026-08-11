import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateChecker {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;

      final response = await Supabase.instance.client
          .from('app_version')
          .select()
          .eq('id', 1)
          .single();

      final latestVersionCode = response['latest_version_code'] as int;
      final latestVersionName = response['latest_version_name'] as String;
      final downloadUrl = response['download_url'] as String;
      final forceUpdate = response['force_update'] as bool;

      if (latestVersionCode > currentVersionCode) {
        if (!context.mounted) return;

        showDialog(
          context: context,
          barrierDismissible: !forceUpdate,
          builder: (dialogContext) => PopScope(
            canPop: !forceUpdate,
            child: AlertDialog(
              title: const Text('يتوفر تحديث جديد'),
              content: Text(
                'يتوفر إصدار جديد ($latestVersionName) من التطبيق. '
                'يرجى التحديث للحصول على أحدث الميزات والإصلاحات.',
              ),
              actions: [
                if (!forceUpdate)
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('لاحقاً'),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    final uri = Uri.parse(downloadUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: const Text('تحديث الآن'),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      // Silently fail — don't block app startup if the check fails
      // (e.g. no internet, table missing, etc.)
    }
  }
}