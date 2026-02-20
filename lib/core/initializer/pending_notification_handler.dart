import 'package:apparence_kit/modules/notifications/api/local_notifier.dart';
import 'package:apparence_kit/modules/notifications/api/notifications_api.dart';
import 'package:apparence_kit/modules/notifications/providers/models/notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pendingNotificationHandlerProvider = Provider<PendingNotificationHandler>(
  (ref) => PendingNotificationHandler(
    notificationsApi: ref.watch(notificationsApiProvider),
  ),
);

/// This class is responsible for handling the pending notification
/// and when the app is ready, we process the notification
/// Firebase automatically stores the initial message and remove it after getting it
class PendingNotificationHandler {

  final NotificationsApi _notificationsApi;

  PendingNotificationHandler({
    required NotificationsApi notificationsApi,
  }) : _notificationsApi = notificationsApi;

  Future<Notification?> fetchNotificationToProcess() async {
    final message = await _notificationsApi.getInitialMessage();
    if (message == null) {
      return null;
    }
    final notification = Notification.from(
      message.notification!.toMap(),
      data: message.data,
      notifierApi: LocalNotifier(notificationManager: FlutterLocalNotificationsPlugin()),
      notifierSettings: defaultNotificationSettings,
    );
    return notification;
  }

}
