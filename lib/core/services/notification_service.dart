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
    }

    // ==========================================================
    // FCM PERMISSION
    // ==========================================================

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ==========================================================
    // FCM TOKEN
    // ==========================================================

    await _messaging.getToken();

    // ==========================================================
    // FOREGROUND NOTIFICATIONS
    // ==========================================================

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        // FCM handles notification messages.
        // We do not manually show another notification here.
      },
    );

    // ==========================================================
    // NOTIFICATION OPENED FROM BACKGROUND
    // ==========================================================

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {},
    );

    // ==========================================================
    // APP OPENED FROM TERMINATED STATE
    // ==========================================================

    final RemoteMessage? initialMessage =
        await _messaging.getInitialMessage();

    if (initialMessage != null) {}
  }

  // ============================================================
  // SAVE FCM TOKEN
  // ============================================================

  static Future<void> saveFcmToken() async {
    try {
      final user =
          Supabase.instance.client.auth.currentUser;

      if (user == null) {
        return;
      }

      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        return;
      }

      await Supabase.instance.client
          .from('profiles')
          .update({
        'fcm_token': token,
      }).eq('id', user.id);
    } catch (e) {
      // Intentionally ignored.
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
            return;
          }

          await Supabase.instance.client
              .from('profiles')
              .update({
            'fcm_token': newToken,
          }).eq('id', user.id);
        } catch (e) {
          // Intentionally ignored.
        }
      },
    );
  }
}
