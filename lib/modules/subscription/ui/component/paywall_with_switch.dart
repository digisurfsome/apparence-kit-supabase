import 'package:apparence_kit/core/data/models/subscription.dart';
import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/i18n/translations.g.dart';
import 'package:apparence_kit/modules/subscription/ui/component/premium_page_factory.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/premium_background_gradient.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/premium_bottom_menu.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/premium_close_button.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/premium_feature.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/selectable_row.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/trial_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';


/// The paywall with switch is a paywall with a switch to toggle the trial offer
/// (You have to have 1 offer with a trial period and 1 offer without a trial period)
/// Once the user toggles the switch, the selected offer is updated
/// - Offer with trial period is most of the time more expensive 
/// - try different pricing strategies to see which one converts the best
class PaywallWithSwitch extends StatelessWidget {
  final List<SubscriptionProduct> offers;
  final SubscriptionProduct? selectedOffer;
  final OnSelectItem<SubscriptionProduct> onSelectItem;
  final OnTapSubscription? onTap;
  final VoidCallback? onTapCoupon;
  final VoidCallback? onTapPrivacy;
  final VoidCallback? onTapTerms;
  final OnTap? onTapRestore;
  final OnTap? onSkip;

  const PaywallWithSwitch({
    super.key,
    required this.offers,
    required this.onSelectItem,
    required this.onTap,
    required this.onTapRestore,
    required this.selectedOffer,
    this.onTapCoupon,
    this.onSkip,
    this.onTapPrivacy,
    this.onTapTerms,
  });

  @override
  Widget build(BuildContext context) {
    var detailedPrice = "";
    var btnActionText = "";
    var title = "";

    final translations = Translations.of(context).paywallWithSwitch;
    final selectedOfferTrialDays = selectedOffer?.trialDays ?? 0;

    title = translations.noTrial.title;
    if (selectedOfferTrialDays > 0) {
      detailedPrice = translations.withTrial.details(
        price: selectedOffer?.formattedPrice(context) ?? "",
        days: selectedOfferTrialDays,
      );
      btnActionText = translations.withTrial.btnAction;
      title = translations.withTrial.title(
        days: selectedOfferTrialDays,
      );
    } else {
      detailedPrice = selectedOffer?.formattedPrice(context) ?? "";
      title = translations.noTrial.title;
      btnActionText = translations.noTrial.btnAction;
    }

    return Scaffold(
      backgroundColor: context.colors.primary,
      body: PremiumBackgroundGradient(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          "assets/images/premium-switch-header.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 0,
                        child: AppCloseButton(
                          onTap: () {
                            onSkip?.call();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Animate(
                  effects: const [
                    FadeEffect(
                      delay: Duration(milliseconds: 100),
                      duration: Duration(milliseconds: 300),
                    ),
                  ],
                  child: Text(
                    title,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.albertSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: context.colors.background,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: AnimateList(
                    interval: 150.ms,
                    delay: 500.ms,
                    effects: [FadeEffect(duration: 300.ms)],
                    children: translations.features
                        .map((el) => PremiumFeature(text: el))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                if (offers.length > 1)
                  TrialSwitcher(
                    onUpdate: (withTrial) {
                      final offer = selectedOffer;
                      final otherOffer = offers.firstWhere(
                        (element) => element != offer,
                      );
                      onSelectItem(otherOffer);
                    },
                    trialDays: selectedOffer!.trialDays ?? 0,
                  ),
                const SizedBox(height: 16),
                Animate(
                  effects: const [
                    FadeEffect(
                      delay: Duration(milliseconds: 100),
                      duration: Duration(milliseconds: 300),
                    ),
                  ],
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: Text(
                      key: ValueKey(detailedPrice),
                      detailedPrice,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.colors.background,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Animate(
                  effects: const [
                    FadeEffect(
                      delay: Duration(milliseconds: 300),
                      duration: Duration(milliseconds: 300),
                    ),
                    ScaleEffect(
                      delay: Duration(milliseconds: 300),
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.elasticInOut,
                    ),
                  ],
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: onTap != null
                        ? Text(btnActionText)
                        : const CircularProgressIndicator.adaptive(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                BottomPremiumMenu(
                  textColor: Colors.white,
                  onTapRestore: onTapRestore,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}