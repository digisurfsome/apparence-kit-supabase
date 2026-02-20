
import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/modules/settings/settings_page.dart';
import 'package:apparence_kit/modules/settings/ui/widgets/admin_card.dart';
import 'package:apparence_kit/modules/settings/ui/widgets/settings_tile.dart';
import 'package:apparence_kit/modules/subscription/ui/component/premium_page_factory.dart';
import 'package:apparence_kit/modules/subscription/ui/premium_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminPaywalls extends ConsumerWidget {
  const AdminPaywalls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paywalls Admin Panel")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SettingsContainer(
          child: Wrap(
            children: [
              
              for (var paywall in PaywallFactory.values) ...[
                SettingsTile(
                  icon: Icons.payments_outlined,
                  title: paywall.name,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PremiumPage(paywall: paywall),
                      ),
                    );
                  },
                ),
                const SettingsDivider(),
              ],
              
            ],
          ),
        ),
      ),
    );
  }
}
