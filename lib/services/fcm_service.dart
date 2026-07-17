import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/api_client.dart';

/// FCM background message handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  // Background messages are handled silently by the OS notification tray.
  // No Flutter UI code here — app may not be running.
}

class FcmService {
  static final _messaging    = FirebaseMessaging.instance;
  static final _localPlugin  = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'apna_saving_channel',
    'Apna Saving Notifications',
    description: 'Payment receipts, cycle updates, and auction results',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    // Request permission (iOS / Android 13+)
    await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
      provisional: false,
    );

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    // Create Android notification channel
    await _localPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Register/refresh token
    await _registerToken();

    // Token refresh
    _messaging.onTokenRefresh.listen(_uploadToken);
  }

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );

    await _localPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await _uploadToken(token);
    } catch (_) {
      // Silently fail — device may not have Google Play Services
    }
  }

  static Future<void> _uploadToken(String token) async {
    try {
      await ApiClient.instance.put('/auth/fcm-token', data: {'fcm_token': token});
    } catch (_) {}
  }

  /// Returns the current FCM token (for debugging)
  static Future<String?> getToken() => _messaging.getToken();

  /// Subscribe to a topic (e.g. 'group_${groupId}' for group-wide broadcasts)
  static Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);
}
