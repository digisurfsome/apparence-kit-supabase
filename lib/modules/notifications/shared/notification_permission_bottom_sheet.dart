import 'package:apparence_kit/core/states/components/maybeshow_component.dart';
import 'package:apparence_kit/core/states/models/event_model.dart';
import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/i18n/translations.g.dart';
import 'package:apparence_kit/modules/notifications/api/local_notifier.dart';
import 'package:apparence_kit/modules/notifications/repositories/notifications_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// This widget is used to show the notification permission dialog
/// if user didn't grant permission, we will show the dialog again
/// if user granted permission, we will not show the dialog again
/// customize the trigger condition to your needs
class MaybeShowNotificationPermission extends MaybeShowWithContext {
  @override
  Future<bool> handle(BuildContext context, AppEvent? event) async {
    if (event == null) {
      return false;
    }
    return switch (event) {
      OnAppStartEvent() => showNotificationPermissionSheetIfNeeded(context),
      _ => false,
    };
  }
}

Future<bool> showNotificationPermissionSheetIfNeeded(
  BuildContext context, {
  bool force = false,
}) async {
  Logger().d("🔔 [MaybeShowNotificationPermission] checking permission status");
  final permissionStatus = await Permission.notification.status;
  if (permissionStatus.isGranted && !force) {
    debugPrint('🔔 [MaybeShowNotificationPermission] permission is granted ✅');
    return false;
  }
  if (context.mounted) {
    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      useRootNavigator: true,
      barrierColor: context.colors.background.withValues(alpha: 0.90),
      isScrollControlled: true,
      builder: (context) => const NotificationPermissionBottomSheet(),
    );
  }
  return true;
}

class NotificationPermissionBottomSheet extends ConsumerWidget {
  const NotificationPermissionBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = Translations.of(
      context,
    ).request_notification_permission;
    final notificationSettings = ref.read(notificationsSettingsProvider);
    final notificationRepository = ref.read(notificationRepositoryProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.background.withValues(alpha: 1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border.all(
          color: context.colors.onBackground.withValues(alpha: 0.15),
          strokeAlign: BorderSide.strokeAlignOutside,
          width: 4,
        ),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            // Align(
            //   child: Image.asset(
            //     'assets/images/notifications.png',
            //     width: 230,
            //     height: 230,
            //   ),
            // ),
            // const SizedBox(height: 32),

            // Header with icon
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notification_add,
                    color: context.colors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    translations.title,
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: context.colors.onBackground,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              translations.description,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onBackground.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 24),

            Flexible(
              flex: 0,
              child: ElevatedButton(
                onPressed: () => _requestNotificationPermission(
                  context,
                  notificationSettings,
                  notificationRepository,
                ),
                child: Text(translations.continue_button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestNotificationPermission(
    BuildContext context,
    NotificationSettings notificationSettings,
    NotificationsRepository notificationRepository,
  ) async {
    try {
      final permissionStatus = await Permission.notification.status;

      if (permissionStatus.isDenied) {
        final granted = await notificationSettings.askPermission();

        if (granted) {
          await notificationRepository.init();
          if (!context.mounted) {
            return;
          }
          Navigator.of(context).pop();
        } else {
          if (!context.mounted) {
            return;
          }
          await _showPermissionDeniedDialog(context);
        }
      } else if (permissionStatus.isPermanentlyDenied) {
        if (!context.mounted) {
          return;
        }
        await _showPermissionDeniedDialog(context);
      }
    } catch (e, stackTrace) {
      if (!context.mounted) {
        return;
      }
      debugPrint('🔔 [NotificationPermissionBottomSheet] error: $e');
      Sentry.captureException(e, stackTrace: stackTrace);
      Navigator.of(context).pop();
    }
  }

  Future<void> _showPermissionDeniedDialog(BuildContext context) {
    final translations = Translations.of(
      context,
    ).notification_permission_denied;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          translations.title,
          style: context.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          translations.description,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              translations.cancel_button,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: Text(
              translations.open_settings_button,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
