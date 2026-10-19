import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      print('FCM Background message received: ${message.messageId} - ${message.notification?.title}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('FCM Background handler error: $e');
    }
  }
}

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Initialize Firebase Core with generated firebase_options.dart
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 2. Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Request user notification permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('FCM Permission status: ${settings.authorizationStatus}');
      }

      // 4. Set foreground presentation options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 5. Subscribe to broadcast topics
      await _messaging.subscribeToTopic('all');
      await _messaging.subscribeToTopic('notifications');

      // 6. Fetch and register device FCM token
      await syncTokenWithBackend();

      // 7. Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) {
        syncTokenWithBackend(tokenOverride: newToken);
      });

      // 8. Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('FCM Foreground message received: ${message.notification?.title} - ${message.notification?.body}');
        }
      });

      // 9. When user taps notification when app was opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('FCM Notification opened by user: ${message.data}');
        }
      });

      _initialized = true;
      if (kDebugMode) {
        print('✅ FCM Service successfully initialized for project earnfarm.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FCM Service initialization error: $e');
      }
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  static Future<void> syncTokenWithBackend({String? tokenOverride}) async {
    try {
      final token = tokenOverride ?? await getToken();
      if (token != null && token.isNotEmpty) {
        await ApiService.updateFcmToken(token);
        if (kDebugMode) {
          print('FCM Token synced to backend: $token');
        }
      }
    } catch (_) {}
  }
}
