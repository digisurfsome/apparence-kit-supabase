import 'package:apparence_kit/core/rating/widgets/review_popup.dart';
import 'package:apparence_kit/core/states/user_state_notifier.dart';
import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/core/widgets/update_bottom_sheet.dart';
import 'package:apparence_kit/modules/notifications/shared/notification_permission_bottom_sheet.dart';
import 'package:apparence_kit/modules/settings/settings_page.dart';
import 'package:apparence_kit/modules/settings/ui/components/admin/admin_home_widgets.dart';
import 'package:apparence_kit/modules/settings/ui/widgets/settings_tile.dart';
import 'package:apparence_kit/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:apparence_kit/modules/settings/ui/components/admin/admin_paywalls.dart';

class AdminPanel extends ConsumerWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateNotifierProvider);

    return SettingsContainer(
      child: Wrap(
        children: [
          SettingsTile(
            icon: Icons.note_outlined,
            title: "Update bottom sheet",
            onTap: () {
              showUpdateBottomSheet(
                context: navigatorKey.currentContext!,
                version: "0.0.0",
              );
            },
          ),
          
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.payments_outlined,
            title: "Paywalls",
            onTap: () => Navigator.of(navigatorKey.currentContext!).push(
              MaterialPageRoute(builder: (context) => const AdminPaywalls()),
            ),
          ),
          
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.check,
            title: "Test onboarding",
            onTap: () => context.go("/onboarding"),
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.person,
            title: "Copy user id",
            onTap: () {
              Clipboard.setData(ClipboardData(text: userState.user.idOrThrow));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User id copié dans le presse-papiers'),
                ),
              );
            },
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.notifications_on,
            title: "Ask for notification",
            onTap: () =>
                showNotificationPermissionSheetIfNeeded(context, force: true),
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.rate_review,
            title: "Ask for review",
            onTap: () => showReviewDialog(ref, force: true),
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.message_rounded,
            title: "Home Widgets panel",
            onTap: () => Navigator.of(navigatorKey.currentContext!).push(
              MaterialPageRoute(builder: (context) => const AdminHomeWidgets()),
            ),
          ),
        ],
      ),
    );
  }
}
