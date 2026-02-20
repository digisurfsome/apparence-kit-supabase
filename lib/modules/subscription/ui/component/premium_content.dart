import 'package:apparence_kit/core/data/models/subscription.dart';
import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/i18n/translations.g.dart';
import 'package:apparence_kit/core/animations/movefade_anim.dart';
import 'package:apparence_kit/modules/subscription/ui/component/premium_page_factory.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/premium_background.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/premium_bottom_menu.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/premium_card.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/premium_close_button.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/premium_feature.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/selectable_row.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class BasicPaywall extends StatelessWidget {
  final List<SubscriptionProduct> offers;
  final SubscriptionProduct? selectedOffer;
  final OnSelectItem<SubscriptionProduct> onSelectItem;
  final OnTapSubscription? onTap;
  final OnTap? onTapRestore;
  final OnTap? onSkip;

  const BasicPaywall({
    super.key,
    required this.offers,
    required this.onSelectItem,
    required this.onTap,
    required this.onTapRestore,
    required this.selectedOffer,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      bgImagePath: "assets/images/premium-bg.jpg",
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: AppCloseButton(
            onTap: () {
              onSkip?.call();
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 32,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PremiumCard(
                bgColor: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MoveFadeAnim(
                      delayInMs: 200,
                      child: Text(
                        Translations.of(context).premium.title_1,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.albertSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      children: AnimateList(
                        interval: 150.ms,
                        delay: 500.ms,
                        effects: [FadeEffect(duration: 300.ms)],
                        children: [
                          PremiumFeature(text: Translations.of(context).premium.feature_1),
                          PremiumFeature(text: Translations.of(context).premium.feature_2),
                          PremiumFeature(text: Translations.of(context).premium.feature_3),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SelectableRowGroup<SubscriptionProduct>(
                      // ignore: avoid_redundant_argument_values
                      brightness: Brightness.light,
                      items: offers
                          .map(
                            (el) => SelectableOption(
                              /// On iOS you have to show the product title from the store (or Apple will reject the app)
                              /// On android you can show custom titles using your own translations
                              label: switch(defaultTargetPlatform) {
                                TargetPlatform.iOS => el.title ?? '',
                                TargetPlatform.android when el.durationType == DurationType.lifetime => 
                                  Translations.of(context).premium.duration_lifetime.toUpperCase(),
                                TargetPlatform.android when el.durationType == DurationType.year => 
                                  Translations.of(context).premium.duration_recuring_label_annual.toUpperCase(),
                                TargetPlatform.android when el.durationType == DurationType.month => 
                                  Translations.of(context).premium.duration_recuring_label_monthly.toUpperCase(),
                                TargetPlatform.android when el.durationType == DurationType.week => 
                                  Translations.of(context).premium.duration_recuring_label_weekly.toUpperCase(),
                                _ => el.title ?? '',
                              },
                              price: el.formattedPrice(context),
                              sublabel: switch (el.durationType) {
                                DurationType.week => el.formattedPrice(context),
                                DurationType.year => el.formattedPrice(context),
                                DurationType.lifetime => el.formattedPrice(context),
                                DurationType.month => el.formattedPrice(context),
                                _ => '--',
                              },
                              pricePerOtherDuration: switch (el.durationType) {
                                DurationType.year => el.pricePerMonth(context),
                                _ => null,
                              },
                              trial: switch(el.trialDays) {
                                null => null,
                                _ => Translations.of(context).paywallWithSwitch.withTrial.trial_switch_title(days: el.trialDays!),
                              },
                              data: el,
                            ),
                          )
                          .toList(),
                      onSelectItem: onSelectItem,
                    ),
                    const SizedBox(height: 48),
                    MoveFadeAnim(
                      delayInMs: 350,
                      child: ElevatedButton(
                        onPressed: onTap,
                        child: onTap != null
                            ? Text(Translations.of(context).premium.action_button)
                            : const CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BottomPremiumMenu(
                  textColor: Colors.white,
                  onTapRestore: onTapRestore,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
