import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import 'api_service.dart';

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _highImportanceChannel = AndroidNotificationChannel(
  'sr_digital_seva_high_importance',
  'High Importance Notifications',
  description: 'Used for important alerts, notices and featured notifications.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  showBadge: true,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      print('FCM Background message received: ${message.messageId} - ${message.notification?.title}');
    }

    // If message is data-only without notification block, show system notification
    if (message.notification == null) {
      final title = message.data['title'] ?? 'SR Digital Seva Alert';
      final body = message.data['body'] ?? message.data['message'] ?? '';
      if (title.isNotEmpty || body.isNotEmpty) {
        final FlutterLocalNotificationsPlugin bgNotifications =
            FlutterLocalNotificationsPlugin();
        const AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings('@mipmap/launcher_icon');
        await bgNotifications.initialize(
          settings: const InitializationSettings(android: androidSettings),
        );
        await bgNotifications.show(
          id: message.hashCode,
          title: title,
          body: body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'sr_digital_seva_high_importance',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/launcher_icon',
              playSound: true,
              enableVibration: true,
            ),
          ),
        );
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('FCM Background handler error: $e');
    }
  }
}

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final Set<String> _recentMessageIds = <String>{};
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Initialize Firebase Core
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 2. Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Initialize flutter_local_notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings);

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (kDebugMode) {
            print('Notification tapped: ${response.payload}');
          }
        },
      );

      // 4. Create the Android notification channel with Importance.max
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_highImportanceChannel);
        await androidPlugin.requestNotificationsPermission();
      }

      // 5. Request user notification permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('FCM Permission status: ${settings.authorizationStatus}');
      }

      // 6. Set foreground presentation options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 7. Subscribe to broadcast topics (Use only 'all' to prevent duplicate deliveries)
      await _messaging.subscribeToTopic('all');
      await _messaging.unsubscribeFromTopic('notifications').catchError((_) {});

      // 8. Fetch and register device FCM token
      await syncTokenWithBackend();

      // 9. Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) {
        syncTokenWithBackend(tokenOverride: newToken);
      });

      // 10. FOREGROUND MESSAGE LISTENER: Display Heads-Up Banner when app is OPEN!
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('FCM Foreground message received: ${message.messageId} - ${message.notification?.title}');
        }

        // Deduplicate messages by messageId
        final msgId = message.messageId ?? '${message.notification?.title}_${message.sentTime?.millisecondsSinceEpoch}';
        if (_recentMessageIds.contains(msgId)) {
          return;
        }
        _recentMessageIds.add(msgId);
        if (_recentMessageIds.length > 50) {
          _recentMessageIds.remove(_recentMessageIds.first);
        }

        final notification = message.notification;
        final title = notification?.title ?? message.data['title'] ?? 'SR Digital Seva Alert';
        final body = notification?.body ?? message.data['body'] ?? message.data['message'] ?? '';

        if (title.isNotEmpty || body.isNotEmpty) {
          _localNotifications.show(
            id: message.hashCode,
            title: title,
            body: body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _highImportanceChannel.id,
                _highImportanceChannel.name,
                channelDescription: _highImportanceChannel.description,
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/launcher_icon',
                playSound: true,
                enableVibration: true,
              ),
            ),
            payload: message.data.toString(),
          );
        }
      });

      // 11. When user taps notification when app was opened from background
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
