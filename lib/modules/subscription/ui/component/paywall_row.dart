import 'package:apparence_kit/core/animations/movefade_anim.dart';
import 'package:apparence_kit/core/data/models/subscription.dart';
import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/environments.dart';
import 'package:apparence_kit/i18n/translations.g.dart';
import 'package:apparence_kit/modules/subscription/ui/component/premium_page_factory.dart';
import 'package:apparence_kit/modules/subscription/ui/premium_page.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/comparison_table.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/feature_line.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/premium_bottom_menu.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/premium_close_button.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/selectable_col.dart';
import 'package:apparence_kit/modules/subscription/ui/widgets/selectable_row.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class PaywallRow extends ConsumerStatefulWidget {
  final List<SubscriptionProduct> offers;
  final SubscriptionProduct? selectedOffer;
  final OnSelectItem<SubscriptionProduct> onSelectItem;
  final OnTapSubscription? onTap;
  final OnTap? onTapRestore;
  final OnTap? onSkip;
  final PremiumPageArgs? args;
  final bool showCoupon;
  

  const PaywallRow({
    super.key,
    required this.offers,
    required this.onSelectItem,
    required this.onTap,
    required this.onTapRestore,
    required this.selectedOffer,
    required this.onSkip,
    required this.args,
    this.showCoupon = false,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BasicPaywallRowState();
}

class _BasicPaywallRowState extends ConsumerState<PaywallRow> {
  final ValueNotifier<bool> showCloseBtnNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    if (widget.args?.delayCloseMs != null) {
      Future.delayed(Duration(milliseconds: widget.args!.delayCloseMs!), () {
        if (mounted) {
          showCloseBtnNotifier.value = true;
        }
      });
    } else {
      showCloseBtnNotifier.value = true;
    }
  }

  EdgeInsets get hPadding => const EdgeInsets.symmetric(horizontal: 24.0);

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context).premium;
    final features = [
      translations.feature_1,
      translations.feature_2,
      translations.feature_3,
    ];

    return Scaffold(
      backgroundColor: context.colors.background,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: false,
        top: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  'assets/images/premium-bg.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: context.colors.background,
                    elevation: 0,
                    expandedHeight: 130,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.asset(
                        'assets/images/premium-switch-header.png',
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: MoveFadeAnim(
                      child: Text(
                        translations.title_1,
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.onBackground,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  for (var i = 0; i < features.length; i++)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: hPadding,
                        child: FeatureLine(
                          title: features[i],
                          topPadding: i > 0 ? 4 : 0,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SelectableColGroup<SubscriptionProduct>(
                        brightness: Brightness.light,
                        items: widget.offers
                            .map(
                              (el) => SelectableOption(
                                sublabel: switch (el.durationType) {
                                  DurationType.week => Translations.of(context).premium.duration_weekly,
                                  DurationType.year => Translations.of(context).premium.duration_annual,
                                  DurationType.month => Translations.of(context).premium.duration_monthly,
                                  DurationType.lifetime => Translations.of(context).premium.duration_lifetime,
                                  _ => '--',
                                },
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
                                price: el.priceString,
                                icon: switch (el.durationType) {
                                  DurationType.lifetime => Icons.book,
                                  _ => null,
                                },
                                trial: switch(el.trialDays) {
                                  null => null,
                                  _ => Translations.of(context).paywallWithSwitch.withTrial.trial_switch_title(days: el.trialDays!),
                                },
                                promotion: switch (el.durationType) {
                                  DurationType.year => "best deal",
                                  _ => null,
                                },
                                data: el,
                              ),
                            )
                            .toList(),
                        onSelectItem: widget.onSelectItem,
                        initialSelectedIndex: widget.selectedOffer != null
                            ? widget.offers.indexOf(widget.selectedOffer!)
                            : 0,
                      ),
                    ),
                  ),
                  if (widget.showCoupon)
                    SliverToBoxAdapter(
                      child: Align(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 24, 0),
                          child: TextButton(
                            onPressed: () => debugPrint("coupon"),
                            // onPressed: () => askForCoupon(ref),
                            child: Text(translations.coupon_title,
                              style: context.kitTheme.defaultTextTheme.primary.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: context.colors.background,
                                decoration: TextDecoration.underline,
                                decorationColor: context.colors.background,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverToBoxAdapter(
                    child: Text(Translations.of(context).premium.comparison.title,
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.onBackground,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: hPadding,
                      child: const ComparisonTableComponent(),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 300)),
                ],
              ),
            ),
            Positioned(
              top: defaultTargetPlatform == TargetPlatform.android ? 8 : 0,
              right: 24,
              child: SafeArea(
                child: AppCloseButtonComponent(
                  showCloseBtn: showCloseBtnNotifier,
                  onTap: () => widget.onSkip?.call(),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ColoredBox(
                color: context.colors.onBackground.withValues(alpha: .9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    switch((widget.selectedOffer?.trialDays, widget.selectedOffer?.durationType)) {
                      (_, DurationType.lifetime) => Padding(
                        padding: hPadding,
                        child: const SizedBox.shrink(),
                      ),
                      (null, _) => Padding(
                        padding: hPadding,
                        child: Text(
                          translations.payment_cancel_reassurance,
                          textAlign: TextAlign.center,
                          style: context.kitTheme.defaultTextTheme.primary.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: context.colors.background.withValues(alpha: .9),
                          ),
                        ),
                      ),
                      (_, _) => Padding(
                        padding: hPadding,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.security, 
                              size: 14,
                              color: context.colors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              translations.payment_cancel_reassurance_free_trial,
                              style: context.kitTheme.defaultTextTheme.primary.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: context.colors.background.withValues(alpha: .9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    },
                    const SizedBox(height: 12),
                    _buildButton(context, ref),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: BottomPremiumMenu(
                        textColor: Colors.white,
                        onTapRestore: widget.onTapRestore,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, WidgetRef ref) {
    final translations = Translations.of(context).premium;
    return Animate(
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
      child: Padding(
        padding: hPadding,
        child: ElevatedButton(
          onPressed: widget.onTap,
          child: widget.onTap != null
              ? Text(
                  widget.selectedOffer?.trialDays != null
                      ? translations.try_free_btn_action(days: widget.selectedOffer!.trialDays!)
                      : translations.action_button,
                )
              : const CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
        ),
      ),
    );
  }
  
}

  