import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/environnements.dart';
import 'package:apparence_kit/i18n/translations.g.dart';
import 'package:apparence_kit/modules/subscription/ui/component/premium_page_factory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// The bottom menu of the premium page
/// - It contains the restore button, terms and privacy buttons
/// You must show this on your paywall pages to be compliant with the app store guidelines
/// -------------------------------
/// Privacy    Restore     Terms
/// -------------------------------
class BottomPremiumMenu extends StatelessWidget {
  final OnTap? onTapRestore;
  final Color? textColor;
  
  const BottomPremiumMenu({super.key, this.onTapRestore, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPrivacyButton(context),
        _buildRestoreButton(context),
        _buildTermsButton(context),
      ],
    );
  }


  Widget _buildTermsButton(BuildContext context) {
    final translations = Translations.of(context).premium;
    return Padding(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
      ),
      child: TextButton(
        onPressed: () {
          switch (defaultTargetPlatform) {
            case TargetPlatform.iOS: {
              launchUrl(Uri.parse("https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"));
            } 
            case TargetPlatform.android: 
            default: {
              launchUrl(Uri.parse(kTermsUrl));
            }
          }
        },
        child: Text(
          translations.terms,
          style: TextStyle(
            color: textColor ?? context.colors.onBackground.withValues(alpha: .9),
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }


  Widget _buildPrivacyButton(BuildContext context) {
    final translations = Translations.of(context).premium;
    return Padding(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
      ),
      child: TextButton(
        onPressed: () {
          launchUrl(Uri.parse(kPrivacyUrl));
        },
        child: Text(
          translations.privacy,
          style: TextStyle(
            color: textColor ?? context.colors.onBackground.withValues(alpha: .9),
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreButton(BuildContext context) {
    final translations = Translations.of(context).premium;
    return Padding(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
      ),
      child: TextButton(
        onPressed: onTapRestore,
        child: onTapRestore != null
            ? Text(
                translations.restore_action,
                style: TextStyle(
                  color: textColor ?? context.colors.onBackground.withValues(alpha: .9),
                  fontWeight: FontWeight.w400,
                  fontSize: 13,

                ),
              )
            : const CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
      ),
    );
  }
}