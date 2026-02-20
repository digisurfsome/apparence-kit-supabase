import 'package:apparence_kit/modules/notifications/api/local_notifier.dart';
import 'package:apparence_kit/modules/notifications/providers/models/notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  if (message.notification == null) {
    return;
  }
  final notification = Notification.from(
    message.notification!.toMap(),
    data: message.data,
    notifierApi: LocalNotifier(notificationManager: FlutterLocalNotificationsPlugin()),
    notifierSettings: defaultNotificationSettings,
  );
  await notification.show();
}