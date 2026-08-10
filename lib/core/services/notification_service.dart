import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  // ============================================================
  // INITIALIZE NOTIFICATIONS
  // ============================================================

  static Future<void> initialize() async {
    // Ask the user for notification permission.
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print(
      'Notification permission: ${settings.authorizationStatus}',
    );

    // Get the device FCM token.
    final token = await _messaging.getToken();

    print('🔥 FCM TOKEN: $token');

    // Notification received while app is open.
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        print('🔔 Notification received');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');
      },
    );

    // User tapped a notification while app was in background.
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        print('📱 Notification opened');
        print('Data: ${message.data}');
      },
    );
  }

  // ============================================================
  // SAVE FCM TOKEN
  // ============================================================

  static Future<void> saveFcmToken() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        print('⚠️ No logged-in user, cannot save FCM token');
        return;
      }

      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        print('⚠️ FCM token is null');
        return;
      }

      await Supabase.instance.client
          .from('profiles')
          .update({
            'fcm_token': token,
          })
          .eq('id', user.id);

      print('✅ FCM token saved to Supabase');
    } catch (e) {
      print('❌ Failed to save FCM token: $e');
    }
  }

  // ============================================================
  // TOKEN REFRESH
  // ============================================================

  static void listenForTokenRefresh() {
    _messaging.onTokenRefresh.listen(
      (newToken) async {
        try {
          final user =
              Supabase.instance.client.auth.currentUser;

          if (user == null) {
            print(
              '⚠️ No logged-in user, cannot save refreshed token',
            );
            return;
          }

          await Supabase.instance.client
              .from('profiles')
              .update({
                'fcm_token': newToken,
              })
              .eq('id', user.id);

          print('✅ Refreshed FCM token saved');
        } catch (e) {
          print(
            '❌ Failed to save refreshed FCM token: $e',
          );
        }
      },
    );
  }
}