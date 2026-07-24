// lib/services/notification_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';
import '../models/scripture_message.dart';
import '../models/song.dart';
import '../screens/scripture_detail_screen.dart';
import '../screens/scripture_inbox_screen.dart';
import '../screens/song_detail_screen.dart';
import '../services/message_store.dart';
import '../services/song_service.dart';

// Everyone subscribes to this topic; the sender targets it to reach all
// installs. Matches the topic used by the compose-and-send tool.
const String broadcastTopic = 'all_users_tkbk';

// Fill in from Firebase Console -> Project Settings -> Cloud Messaging ->
// Web Push certificates. Only needed for web; harmless null elsewhere.
const String? webVapidKey = null;

// The Android channel FCM's default_notification_channel_id meta-data points
// at, and the one local (foreground) notifications post to.
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'high_importance_channel',
  'Scripture & Announcements',
  description: 'Scripture of the Day and important messages',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

// Must be top-level: FCM runs it in a background isolate that never executed
// main(). The OS shows the notification and the archive syncs from Firestore,
// so there's nothing to persist here — kept only so a handler is registered.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
}

ScriptureMessage _messageFrom(RemoteMessage message) {
  // Prefer the Firestore doc id (scriptureId) so read-state lines up with the
  // archive; fall back to the FCM message id.
  final scriptureId = message.data['scriptureId']?.toString();
  final id = (scriptureId != null && scriptureId.isNotEmpty)
      ? scriptureId
      : (message.messageId ?? DateTime.now().microsecondsSinceEpoch.toString());
  return ScriptureMessage.fromRemote(
    id: id,
    notificationTitle: message.notification?.title,
    notificationBody: message.notification?.body,
    notificationImageUrl: message.notification?.android?.imageUrl ??
        message.notification?.apple?.imageUrl,
    data: message.data,
    receivedAt: DateTime.now().millisecondsSinceEpoch,
  );
}

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  // Shared with MaterialApp so taps can navigate from outside the widget tree.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(alert: true, badge: true, sound: true);
    if (kDebugMode) print('FCM permission: ${settings.authorizationStatus}');

    await _initLocalNotifications();

    // iOS: allow the system banner while foregrounded too (Android handled by
    // us re-posting via flutter_local_notifications below).
    await messaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    try {
      await messaging.subscribeToTopic(broadcastTopic);
    } catch (e) {
      if (kDebugMode) print('subscribeToTopic failed: $e');
    }

    try {
      final token = await messaging.getToken(vapidKey: kIsWeb ? webVapidKey : null);
      if (kDebugMode) print('FCM token: $token');
    } catch (e) {
      if (kDebugMode) print('getToken failed: $e');
    }

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageTap);

    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      // Delay so the navigator is mounted before we push.
      WidgetsBinding.instance.addPostFrameCallback((_) => _onMessageTap(initial));
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('ic_notification');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        final id = response.payload;
        if (id == null) return;
        final stored = messageStore.byId(id);
        if (stored != null) _navigate(stored, null);
      },
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  // Foreground: draw a real heads-up notification ourselves (Android suppresses
  // the system one while the app is open). The archive syncs from Firestore.
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final stored = _messageFrom(message);

    final notification = message.notification;
    final title = notification?.title ?? stored.title;
    final body = notification?.body ?? stored.reference ?? stored.body;

    await _localNotifications.show(
      id: stored.id.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
          color: const Color(0xFF1A237E),
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: stored.id,
    );
  }

  void _onMessageTap(RemoteMessage message) {
    final stored = _messageFrom(message);
    _navigate(stored, message.data['songNumber']?.toString());
  }

  // Route to the right place: a song deep link, the devotional page for a
  // scripture, or the inbox for anything else.
  void _navigate(ScriptureMessage stored, String? songNumberStr) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    // Optional song deep link: data {"songNumber": "42"}.
    if (songNumberStr != null && songNumberStr.isNotEmpty) {
      final song = _songByNumber(songNumberStr);
      if (song != null) {
        nav.push(MaterialPageRoute(builder: (_) => SongDetailScreen(song: song)));
        return;
      }
    }

    final message = messageStore.byId(stored.id) ?? stored;
    nav.push(MaterialPageRoute(builder: (_) => ScriptureDetailScreen(message: message)));
  }

  Song? _songByNumber(String value) {
    final number = int.tryParse(value);
    if (number == null) return null;
    try {
      return songService.songs.firstWhere((s) => s.number == number);
    } catch (_) {
      return null;
    }
  }

  // Opens the inbox screen (used by the home-screen bell).
  void openInbox() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const ScriptureInboxScreen()),
    );
  }
}

final notificationService = NotificationService.instance;
