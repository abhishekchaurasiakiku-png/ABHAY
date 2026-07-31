import 'dart:async';
import '../network/api_client.dart';
import '../constants/api_constants.dart';

/// Notification service for push notifications (FCM) and local alerts.
///
/// Handles:
/// - Firebase Cloud Messaging initialization and token management
/// - Local notification channels for SOS alerts
/// - Silent notifications to guardians
/// - FCM token registration with backend
class NotificationService {
  bool _initialized = false;
  String? _fcmToken;
  ApiClient? _apiClient;

  final _tokenController = StreamController<String>.broadcast();
  final _notificationController = StreamController<NotificationEvent>.broadcast();

  /// Stream of FCM token updates.
  Stream<String> get tokenUpdates => _tokenController.stream;

  /// Stream of received notifications.
  Stream<NotificationEvent> get notifications => _notificationController.stream;

  String? get fcmToken => _fcmToken;

  /// Set the API client for registering FCM token with backend.
  /// Call this after the user is authenticated.
  void setApiClient(ApiClient apiClient) {
    _apiClient = apiClient;
  }

  /// Initialize Firebase Messaging and local notifications.
  Future<void> initialize() async {
    if (_initialized) return;

    // Production implementation:
    //
    // // Initialize Firebase
    // await Firebase.initializeApp();
    //
    // // Request notification permissions
    // final messaging = FirebaseMessaging.instance;
    // final settings = await messaging.requestPermission(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    //   criticalAlert: true, // Important for SOS alerts
    // );
    //
    // // Get FCM token
    // _fcmToken = await messaging.getToken();
    // if (_fcmToken != null) {
    //   _tokenController.add(_fcmToken!);
    //   await registerTokenWithBackend(_fcmToken!);
    // }
    //
    // // Listen for token refreshes
    // messaging.onTokenRefresh.listen((token) {
    //   _fcmToken = token;
    //   _tokenController.add(token);
    //   registerTokenWithBackend(token);
    // });
    //
    // // Handle foreground messages
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    //
    // // Handle background/terminated messages
    // FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    //
    // // Initialize local notifications
    // final localNotifications = FlutterLocalNotificationsPlugin();
    // await localNotifications.initialize(
    //   const InitializationSettings(
    //     android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    //     iOS: DarwinInitializationSettings(
    //       requestAlertPermission: true,
    //       requestBadgePermission: true,
    //       requestSoundPermission: true,
    //       requestCriticalPermission: true,
    //     ),
    //   ),
    // );
    //
    // // Create notification channels
    // await _createNotificationChannels(localNotifications);

    _initialized = true;
    print('[Notifications] Initialized');
  }

  /// Register the FCM token with the backend so it can send push notifications.
  /// Called after authentication and on token refresh.
  Future<void> registerTokenWithBackend(String token) async {
    if (_apiClient == null) {
      print('[Notifications] API client not set — skipping token registration');
      return;
    }

    try {
      await _apiClient!.put(
        ApiConstants.userFcmToken,
        data: {'fcmToken': token},
      );
      print('[Notifications] FCM token registered with backend');
    } catch (e) {
      print('[Notifications] Failed to register FCM token: $e');
    }
  }

  /// Show a local SOS alert notification.
  Future<void> showSosAlert({
    required String title,
    required String body,
  }) async {
    // Production:
    // final localNotifications = FlutterLocalNotificationsPlugin();
    // await localNotifications.show(
    //   0, // Notification ID
    //   title,
    //   body,
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'sos_channel',
    //       'SOS Alerts',
    //       channelDescription: 'Critical SOS emergency alerts',
    //       importance: Importance.max,
    //       priority: Priority.max,
    //       fullScreenIntent: true,
    //       ongoing: true,
    //       category: AndroidNotificationCategory.alarm,
    //     ),
    //     iOS: DarwinNotificationDetails(
    //       presentAlert: true,
    //       presentBadge: true,
    //       presentSound: true,
    //       interruptionLevel: InterruptionLevel.critical,
    //     ),
    //   ),
    // );

    print('[Notifications] SOS Alert: $title — $body');

    _notificationController.add(NotificationEvent(
      type: NotificationType.sosAlert,
      title: title,
      body: body,
      timestamp: DateTime.now(),
    ));
  }

  /// Show a safety zone alert notification.
  Future<void> showSafetyAlert({
    required String title,
    required String body,
  }) async {
    print('[Notifications] Safety Alert: $title — $body');

    _notificationController.add(NotificationEvent(
      type: NotificationType.safetyZone,
      title: title,
      body: body,
      timestamp: DateTime.now(),
    ));
  }

  /// Show a general info notification.
  Future<void> showInfoNotification({
    required String title,
    required String body,
  }) async {
    print('[Notifications] Info: $title — $body');

    _notificationController.add(NotificationEvent(
      type: NotificationType.info,
      title: title,
      body: body,
      timestamp: DateTime.now(),
    ));
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    // Production:
    // final localNotifications = FlutterLocalNotificationsPlugin();
    // await localNotifications.cancelAll();
    print('[Notifications] All cancelled');
  }

  void dispose() {
    _tokenController.close();
    _notificationController.close();
  }
}

/// Types of notifications.
enum NotificationType {
  sosAlert,
  safetyZone,
  guardianUpdate,
  info,
}

/// Notification event data.
class NotificationEvent {
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const NotificationEvent({
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.data,
  });
}
