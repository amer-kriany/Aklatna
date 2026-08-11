import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin
      _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // ANDROID NOTIFICATION CHANNELS
  // ============================================================

  static const AndroidNotificationChannel _customerChannel =
      AndroidNotificationChannel(
    'orders',
    'Order Notifications',
    description: 'Notifications about your orders',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('default'),
  );

  static const AndroidNotificationChannel _driverChannel =
      AndroidNotificationChannel(
    'driver_orders',
    'Driver Order Notifications',
    description: 'Notifications for delivery drivers',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound(
      'aklatna_driver',
    ),
  );

  // ============================================================
  // INITIALIZE NOTIFICATIONS
  // ============================================================

  static Future<void> initialize() async {
    // ----------------------------------------------------------
    // LOCAL NOTIFICATIONS INITIALIZATION
    // ----------------------------------------------------------

    const AndroidInitializationSettings
        androidInitializationSettings =
        AndroidInitializationSettings(
      '@drawable/aklatna_notification',
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
    );

    // ----------------------------------------------------------
    // CREATE ANDROID CHANNELS
    // ----------------------------------------------------------

    final AndroidFlutterLocalNotificationsPlugin?
        androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Customer channel
      await androidPlugin.createNotificationChannel(
        _customerChannel,
      );

      // Driver channel
      await androidPlugin.createNotificationChannel(
        _driverChannel,
      );

      print('✅ Android notification channels created');
      print('🔊 Driver sound: aklatna_driver');
      print('🔔 Notification icon: aklatna_notification');
    }

    // ==========================================================
    // FCM PERMISSION
    // ==========================================================

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print(
      'Notification permission: '
      '${settings.authorizationStatus}',
    );

    // ==========================================================
    // FCM TOKEN
    // ==========================================================

    final token = await _messaging.getToken();

    print('🔥 FCM TOKEN: $token');

    // ==========================================================
    // FOREGROUND NOTIFICATIONS
    // ==========================================================

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        print('🔔 Notification received');

        print(
          'Title: ${message.notification?.title}',
        );

        print(
          'Body: ${message.notification?.body}',
        );

        print(
          'Data: ${message.data}',
        );

        // FCM handles notification messages.
        // We do not manually show another notification here.
      },
    );

    // ==========================================================
    // NOTIFICATION OPENED FROM BACKGROUND
    // ==========================================================

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        print('📱 Notification opened');

        print(
          'Data: ${message.data}',
        );
      },
    );

    // ==========================================================
    // APP OPENED FROM TERMINATED STATE
    // ==========================================================

    final RemoteMessage? initialMessage =
        await _messaging.getInitialMessage();

    if (initialMessage != null) {
      print('📱 App opened from notification');

      print(
        'Data: ${initialMessage.data}',
      );
    }
  }

  // ============================================================
  // SAVE FCM TOKEN
  // ============================================================

  static Future<void> saveFcmToken() async {
    try {
      final user =
          Supabase.instance.client.auth.currentUser;

      if (user == null) {
        print(
          '⚠️ No logged-in user, '
          'cannot save FCM token',
        );
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
      }).eq('id', user.id);

      print('✅ FCM token saved to Supabase');
    } catch (e) {
      print(
        '❌ Failed to save FCM token: $e',
      );
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
              '⚠️ No logged-in user, '
              'cannot save refreshed token',
            );
            return;
          }

          await Supabase.instance.client
              .from('profiles')
              .update({
            'fcm_token': newToken,
          }).eq('id', user.id);

          print(
            '✅ Refreshed FCM token saved',
          );
        } catch (e) {
          print(
            '❌ Failed to save refreshed FCM token: $e',
          );
        }
      },
    );
  }
}