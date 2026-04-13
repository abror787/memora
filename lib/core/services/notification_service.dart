import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

enum NotificationAction {
  reviewNow,
  snooze15,
  openApp,
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'memora_review_reminders';
  static const String _channelName = 'Напоминания о повторении';
  static const String _channelDescription =
      'Уведомления о карточках, готовых к повторению';

  static const int _reviewNotificationId = 1;

  bool _isInitialized = false;

  final StreamController<NotificationAction> _actionController =
      StreamController<NotificationAction>.broadcast();

  Stream<NotificationAction> get onNotificationAction =>
      _actionController.stream;

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    }
    return true;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Error setting timezone: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    _isInitialized = true;
  }

  void _handleNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');

    final payload = response.payload;
    if (payload == null) {
      _actionController.add(NotificationAction.openApp);
      return;
    }

    switch (payload) {
      case 'review_now':
        _actionController.add(NotificationAction.reviewNow);
        break;
      case 'snooze_15':
        _actionController.add(NotificationAction.snooze15);
        break;
      default:
        _actionController.add(NotificationAction.openApp);
    }
  }

  Future<void> scheduleReviewReminder({
    required Duration delay,
    required int cardsToReviewCount,
  }) async {
    await cancelAllNotifications();

    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

    debugPrint('Scheduling notification for: $scheduledDate');
    debugPrint('Delay: $delay');

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF6750A4),
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(''),
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'review_now',
          'Повторить сейчас',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'snooze_15',
          'Отложить 15 мин',
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _reviewNotificationId,
      'Memora — время повторять!',
      'У тебя $cardsToReviewCount ${_pluralize(cardsToReviewCount, 'карточка', 'карточки', 'карточек')} ждут повторения',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'review_reminder',
    );

    debugPrint('Notification scheduled successfully!');
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF6750A4),
      enableVibration: true,
      playSound: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'review_now',
          'Повторить сейчас',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'snooze_15',
          'Отложить 15 мин',
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelReviewReminder() async {
    await _notifications.cancel(_reviewNotificationId);
  }

  String _pluralize(int count, String one, String few, String many) {
    if (count % 10 == 1 && count % 100 != 11) {
      return one;
    }
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return few;
    }
    return many;
  }

  void dispose() {
    _actionController.close();
  }
}
