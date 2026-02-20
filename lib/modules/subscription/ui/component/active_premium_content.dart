import 'package:apparence_kit/core/states/user_state_notifier.dart';
import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/i18n/translations.g.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/premium_background.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/premium_card.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/unsubscribe_feedback_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

typedef OnTapUnSubscribe = void Function(String reason);
typedef OnExit = void Function();

class ActivePremiumContent extends ConsumerWidget {
  final OnTapUnSubscribe? onTap;
  final OnExit? onExit;

  const ActivePremiumContent({super.key, this.onExit, required this.onTap});

  void _showUnsubscribePopup(BuildContext context) {
    UnsubscribeFeedbackPopup.show(
      context: context,
      onConfirm: (String reason) {
        Navigator.of(context).pop();
        onTap?.call(reason);
      },
      onCancel: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateNotifierProvider);
    final features = [
      Translations.of(context).premium.feature_1,
      Translations.of(context).premium.feature_2,
      Translations.of(context).premium.feature_3,
    ];

    return PremiumBackground(
      bgImagePath: "assets/images/premium-bg.jpg",
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: PremiumCard(
                bgColor: Colors.black54,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Chip(
                        backgroundColor: Theme.of(context).primaryColor,
                        label: Text(
                          "ACTIVE",
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "Premium",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.albertSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // for (var i = 0; i < features.length; i++)
                    //   Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //     child: FeatureLine(
                    //       title: translations.features[i],
                    //       topPadding: i > 0 ? 4 : 0,
                    //       icon: switch (i) {
                    //         0 => HugeIcons.strokeRoundedTaskDone02,
                    //         1 => HugeIcons.strokeRoundedCheckmarkSquare01,
                    //         2 => HugeIcons.strokeRoundedGame,
                    //         _ => Icons.check,
                    //       },
                    //     ),
                    //   ),
                    const SizedBox(height: 40),
                    if (userState.subscription?.isLifetime == true)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                        child: Text(
                          Translations.of(
                            context,
                          ).activePremium.lifetime_user_description,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    // SliverToBoxAdapter(
                    //   child: Padding(
                    //     padding: hPadding,
                    //     child: ComparisonTable(
                    //       rows: ComparisonTableRow.getComparisonRows(
                    //         context,
                    //         ref.read(environmentProvider),
                    //       ),
                    //       freeColumnTitle:
                    //           ComparisonTableRow.getFreeColumnTitle(context),
                    //       premiumColumnTitle:
                    //           ComparisonTableRow.getPremiumColumnTitle(context),
                    //     ),
                    //   ),
                    // ),
                    if (userState.subscription?.isLifetime == false)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
                        child: OutlinedButton(
                          onPressed: () => _showUnsubscribePopup(context),
                          child: Text(
                            Translations.of(
                              context,
                            ).activePremium.unsubscribe_button,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
