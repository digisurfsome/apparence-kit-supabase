import 'package:apparence_kit/core/states/user_state_notifier.dart';
import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/core/theme/providers/theme_provider.dart';
import 'package:apparence_kit/modules/settings/ui/components/admin_panel.dart';
import 'package:apparence_kit/modules/settings/ui/components/avatar_component.dart';
import 'package:apparence_kit/modules/settings/ui/components/delete_user_component.dart';
import 'package:apparence_kit/modules/settings/ui/widgets/settings_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// This is an example of a settings page.
/// You are free to use it or not.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // you can fetch the user state like this
    // final userState = ref.watch(userStateNotifierProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
          child: ListView(
            children: [
              Text(
                "Settings",
                style: context.textTheme.headlineLarge!.copyWith(
                  color: context.colors.onBackground,
                ),
              ),
              const SizedBox(height: 24),
              const ProfileTile(
                title: "My account", // userState.user.name,
                subtitle: "johndoe@gmail.com", // userState.user.email,
              ),
              const SizedBox(height: 24),
              SettingsContainer(
                child: Wrap(
                  children: [
                    const ThemeSwitcher(),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.message_rounded,
                      title: "Send feedback",
                      onTap: () => context.push('/feedback'),
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.payment,
                      title: "Premium",
                      onTap: () => context.push('/premium'),
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.privacy_tip,
                      title: "Privacy policy",
                      onTap: () {
                        // you may need to add some url_launcher configuration in your app for iOS and Android
                        // https://pub.dev/packages/url_launcher
                        launchUrl(
                          Uri.parse("https://apparencekit.dev/privacy/"),
                        );
                      },
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.help,
                      title: "Support",
                      onTap: () {
                        // you may need to add some url_launcher configuration in your app for iOS and Android
                        // https://pub.dev/packages/url_launcher
                        launchUrl(Uri.parse("https://apparencekit.dev/"));
                      },
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.logout,
                      title: "Disconnect",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog.adaptive(
                              title: const Text('Disconnect'),
                              content: const Text(
                                'Are you sure you want to disconnect?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Disconnect'),
                                  onPressed: () {
                                    ref
                                        .read(
                                          userStateNotifierProvider.notifier,
                                        )
                                        .onLogout();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Admin Panel",
                    style: context.textTheme.headlineSmall!.copyWith(
                      color: context.colors.onBackground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const AdminPanel(),
              ],
              const DeleteUserButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsContainer extends StatelessWidget {
  final Widget child;

  const SettingsContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: child,
    );
  }
}

class ProfileTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imagePath;

  const ProfileTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      child: Row(
        children: [
          const EditableUserAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({super.key});

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  bool darkMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      darkMode = ThemeProvider.of(context).mode == ThemeMode.dark;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: darkMode,
      onChanged: (value) {
        setState(() {
          darkMode = value;
        });
        ThemeProvider.of(context).toggle();
      },
      title: Text(
        "Light/Dark mode",
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
