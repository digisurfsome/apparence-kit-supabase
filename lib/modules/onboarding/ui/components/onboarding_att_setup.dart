import 'package:apparence_kit/core/data/api/analytics_api.dart';
import 'package:apparence_kit/core/data/api/tracking_api.dart';
import 'package:apparence_kit/core/states/user_state_notifier.dart';
import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/i18n/translations.g.dart';
import 'package:apparence_kit/modules/onboarding/ui/widgets/onboarding_progress.dart';
import 'package:apparence_kit/modules/subscription/repositories/subscription_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// ATT Permission Step
/// ATT is only available on iOS
/// This is the consent screen for iOS 14+ that asks the user to allow the app to access the ATT framework
/// In a few words you need this to get the IDFA (Identifier for Advertisers) which is used for tracking purposes
/// So you can create better facebook ads, google ads, etc...
class AttPermissionStep extends ConsumerWidget {
  final String nextRoute;

  const AttPermissionStep({
    super.key,
    required this.nextRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = Translations.of(context).onboarding.att;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const OnboardingProgress(value: 0.9),
          const SizedBox(height: 16),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Center(
                child: Image.asset(
                  'assets/images/onboarding/img3.jpg',
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              translations.title,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              translations.description,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ElevatedButton(
              onPressed: () async {
                // We ask the user to allow the app to access the ATT framework
                final Map<Permission, PermissionStatus> permission = await [
                  Permission.appTrackingTransparency,
                ].request();
                final isGranted = permission.values.first == PermissionStatus.granted;

                // save analytics event
                ref.read(analyticsApiProvider).logEvent('att_request', {
                  'granted': isGranted,
                });

                final userState = ref.read(userStateNotifierProvider);
                
                // We set the user IDFA to revenue cat
                ref
                    .read(subscriptionRepositoryProvider)
                    .initUser(userState.user.idOrThrow)
                    .ignore();
                
                // We set the user IDFA to facebook
                ref
                    .read(facebookEventApiProvider)
                    .initUser(userState.user.idOrThrow)
                    .ignore();

                Navigator.of(context).pushNamed(nextRoute);
              },
              child: Text(translations.continue_button),
            ),
          ),
        ],
      ),
    );
  }
}
