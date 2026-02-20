import 'dart:convert';

import 'package:apparence_kit/core/initializer/onstart_service.dart';
import 'package:apparence_kit/modules/notifications/providers/models/notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:universal_html/js.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest_all.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
import 'package:universal_io/io.dart';

final localNotifierProvider = Provider<LocalNotifier>((ref) {
  return LocalNotifier(
    notificationManager: FlutterLocalNotificationsPlugin(),
  );
});

const kAppName = 'ApparenceKit';

final notificationsSettingsProvider = Provider<NotificationSettings>((ref) => defaultNotificationSettings);

final defaultNotificationSettings = NotificationSettings(
  notificationManager: FlutterLocalNotificationsPlugin(),
  androidChannel: const AndroidNotificationChannel(
    // channel id - you can use different channels for different purposes (News, Messages, etc)
    kAppName,
    // app id
    kAppName,
    // this is the description of the channel that will be shown in the Android notification settings
    description: 'general $kAppName channel',
    importance: Importance.max,
  ),
);

/// Firebase shows automatically notifications when the app is in background
/// But when the app is in foreground, you have to show the notification yourself on iOS
/// Also with this you can schedule notifications
/// For more informations check the documentation: https://pub.dev/packages/flutter_local_notifications
///
/// As we don't rely on mocks we wrapped the flutter_local_notifications plugin for our needs
class LocalNotifier {
  final FlutterLocalNotificationsPlugin _notificationManager;

  TimezoneInfo? _currentTimeZone;

  LocalNotifier({
    required FlutterLocalNotificationsPlugin notificationManager,
  }) : _notificationManager = notificationManager;

  Future<void> show(NotificationSettings settings, Notification message) async {
    
    if (kIsWeb) {
      context.callMethod("showNotification", [
        message.title,
        message.body,
      ]);
      return;
    }
    
    
    _notificationManager.show(
      id:message.hashCode,
      title: message.title,
      body: message.body,
      payload: jsonEncode(message.toJson()),
      notificationDetails:  NotificationDetails(
        android: AndroidNotificationDetails(
          settings.androidChannel.id,
          settings.androidChannel.name,
          importance: settings.androidChannel.importance,
          priority: Priority.high,
          channelDescription: settings.androidChannel.description ?? '',
        ),
      ),
      // you can add a payload to redirect the user to a specific page
      // payload: message.payload
    );
  }

  /// Setup the time zone for the notifications
  /// Returns the current time in the user's time zone
  Future<String> _setupTimeZones() async {
    if (_currentTimeZone == null) {
      tz.initializeTimeZones();
      _currentTimeZone = await FlutterTimezone.getLocalTimezone();
    }
    return _currentTimeZone?.identifier ?? '';
  }

  ////////////////////////
  /// Scheduling
  ////////////////////////

  Future<void> scheduleDailyAt({
    required int notificationId,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    await _notificationManager.cancel(id: notificationId);

    final currentTimeZone = await _setupTimeZones();
    final now = tz.TZDateTime.now(tz.getLocation(currentTimeZone));
    final scheduledDate = tz.TZDateTime(
      tz.getLocation(currentTimeZone),
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    const androidDetails = AndroidNotificationDetails(
      kAppName,
      kAppName,
      importance: Importance.max,
    );
    const iosDetails = DarwinNotificationDetails(
      threadIdentifier: kAppName,
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notificationManager.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleWeekly({
    required String title,
    required String body,
    required int dayOfWeekIndex,
    required int hour,
    required int minute,
    String? payload,
    int notificationId = 0,
  }) async {
    await _notificationManager.cancel(id: notificationId);

    final currentTimeZone = await _setupTimeZones();
    final now = tz.TZDateTime.now(tz.getLocation(currentTimeZone));
    final scheduledDate = tz.TZDateTime(
      tz.getLocation(currentTimeZone),
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    final daysUntilNext = (dayOfWeekIndex - scheduledDate.weekday) % 7;
    final nextScheduledDate = scheduledDate.add(Duration(days: daysUntilNext));

    const androidDetails = AndroidNotificationDetails(
      kAppName,
      kAppName,
      importance: Importance.max,
    );
    const iosDetails = DarwinNotificationDetails(
      threadIdentifier: kAppName,
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notificationManager.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: nextScheduledDate,
      notificationDetails: platformChannelSpecifics,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleAt({
    required String title,
    required String body,
    required DateTime date,
    String? payload,
    int notificationId = 0,
  }) async {
    await _notificationManager.cancel(id: notificationId);
    
    final currentTimeZone = await _setupTimeZones();
    final scheduledDate = tz.TZDateTime.from(
      date,
      tz.getLocation(currentTimeZone),
    );

    const androidDetails = AndroidNotificationDetails(
      kAppName,
      kAppName,
      importance: Importance.max,
    );
    const iosDetails = DarwinNotificationDetails(
      threadIdentifier: kAppName,
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notificationManager.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
  
  Future<void> scheduleFromNow({
    required String title,
    required String body,
    required Duration duration,
    required String channel,
  }) async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await _notificationManager.pendingNotificationRequests();
    if (pendingNotificationRequests.isEmpty) {
      return;
    }

    final androidNotificationDetails = AndroidNotificationDetails(
      channel,
      channel,
      channelDescription: '$kAppName notification $channel',
    );
    final iosDetails = DarwinNotificationDetails(
      threadIdentifier: channel,
    );
    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosDetails,
    );
    await Future.delayed(
      duration,
      () => _notificationManager.show(
        id: 0,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      ),
    );
  }

  Future<void> cancelAll() async {
    await _notificationManager.cancelAll();
  }

  Future<void> cancel(int notificationId) async {
    await _notificationManager.cancel(id: notificationId);
  }

  Future<List<PendingNotificationRequest>> listPendingNotifications() async {
    return await _notificationManager.pendingNotificationRequests();
  }
  
}

/// This is the settings for the notifications
/// You could have this directly in LocalNotifier but it's better to separate the concerns
/// So now you can send different notifications with different settings
/// [init] method will be called automatically by the [Initializer] class
class NotificationSettings implements OnStartService {
  final FlutterLocalNotificationsPlugin _notificationManager;
  final AndroidNotificationChannel androidChannel;

  NotificationSettings({
    required FlutterLocalNotificationsPlugin notificationManager,
    required this.androidChannel,
  }) : _notificationManager = notificationManager;

  @override
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    // we don't want to request permissions for iOS directly
    // we ask it nicely during the onboarding process
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    _notificationManager.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (payload) => redirectToPayload(payload),
    );
    await _notificationManager
        .resolvePlatformSpecificImplementation //
        <AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<bool> askPermission() async {
    if (Platform.isAndroid) {
      final result = await _notificationManager
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    } else if (Platform.isIOS) {
      final result = await _notificationManager
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    throw 'Platform not supported';
  }

  Future<void> redirectToPayload(
    NotificationResponse notificationResponse,
  ) async {
    if (notificationResponse.payload == null) {
      return;
    }
    if (notificationResponse.payload!.isEmpty == true) {
      Logger().i("Payload is empty");
      return;
    }
    try {
      final json = jsonDecode(notificationResponse.payload!) as Map<String, dynamic>;
      final notification = Notification.fromJson(json);
      await notification.onTap();
    } catch (e, s) {
      Logger().e("--> json : ${notificationResponse.payload}");
      Logger().e("error $e, $s");
      Sentry.captureException(e, stackTrace: s);
    }
  }
}
