/// Local notifications service (no Firebase — uses flutter_local_notifications only).
///
/// Push notifications fire only when the app is backgrounded.
/// When foregrounded, the UI shows in-app SnackBars instead.

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/formatters.dart';

class NotificationsService {
  // ── singleton ────────────────────────────────────────────────────────────
  static final NotificationsService _instance =
      NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _isAppInForeground = true;

  // Notification channel
  static const _channelId = 'codetwin_channel';
  static const _channelName = 'CodeTwin Notifications';
  static const _channelDesc = 'Notifications from CodeTwin agent';

  // ── initialisation ───────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('[NotificationsService] Initialized');
  }

  /// Request permission (returns true if granted).
  Future<bool> requestPermission() async {
    // Android 13+ needs explicit permission
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  // ── foreground / background tracking ─────────────────────────────────

  void setAppInForeground(bool v) => _isAppInForeground = v;

  // ── notification triggers ────────────────────────────────────────────

  Future<void> showPreflightNotification(
      String taskDescription, String blastRadius) async {
    if (_isAppInForeground) return; // in-app SnackBar handles foreground
    await _show(
      id: 1,
      title: 'CodeTwin needs your approval',
      body: '${truncate(taskDescription, 60)} — blast: $blastRadius',
    );
  }

  Future<void> showApprovalNotification(
      String question, String awaitingResponseId) async {
    if (_isAppInForeground) return;
    await _show(
      id: 2,
      title: 'CodeTwin is asking',
      body: truncate(question, 60),
      payload: 'decision:$awaitingResponseId',
    );
  }

  Future<void> showCompleteNotification(String summary) async {
    if (_isAppInForeground) return;
    await _show(
      id: 3,
      title: 'Task complete',
      body: truncate(summary, 80),
    );
  }

  Future<void> showFailedNotification(String error) async {
    if (_isAppInForeground) return;
    await _show(
      id: 4,
      title: 'Task failed',
      body: 'Tap to see details',
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── internal ─────────────────────────────────────────────────────────

  Future<void> _show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details, payload: payload);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to relevant screen — handled by main.dart router listener
    debugPrint(
        '[NotificationsService] Tapped: ${response.payload}');
  }
}
