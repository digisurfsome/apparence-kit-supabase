import 'package:apparence_kit/core/data/api/analytics_api.dart';
import 'package:apparence_kit/core/rating/providers/rating_repository.dart';
import 'package:apparence_kit/core/states/user_state_notifier.dart';
import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/core/widgets/responsive_layout.dart';
import 'package:apparence_kit/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

Future<bool> showReviewDialog(WidgetRef ref, {bool force = false}) {
  if (!ref.context.mounted) {
    return Future.value(false);
  }
  final ratingRepository = ref.watch(ratingRepositoryProvider);
  final userState = ref.watch(userStateNotifierProvider);
  final ratingFuture = ratingRepository.getReview(userState.user);

  return ratingFuture.then((rating) {
    final shouldAsk = rating.shouldAsk();
    Logger().d('should Ask for review: $shouldAsk');
    if (!shouldAsk && !force) {
      return false;
    }
    if (!ref.context.mounted) {
      return false;
    }
    showDialog(
      context: ref.context,
      barrierDismissible: false,
      builder: (context) {
        ratingRepository.delay();
        return Animate(
          effects: const [
            FadeEffect(
              delay: Duration(milliseconds: 100),
              duration: Duration(milliseconds: 300),
            ),
            MoveEffect(
              delay: Duration(milliseconds: 100),
              duration: Duration(milliseconds: 450),
              curve: Curves.easeOut,
              begin: Offset(0, 50),
              end: Offset.zero,
            ),
          ],
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: DeviceSizeBuilder(
              builder: (device) {
                final maxWidth = switch (device) {
                  DeviceType.medium => MediaQuery.of(context).size.width - 32,
                  _ => 550.0,
                };
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colors.background,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: context.colors.onBackground.withValues(
                            alpha: .3,
                          ),
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16.0),
                                    topRight: Radius.circular(16.0),
                                  ),
                                  child: Image.asset(
                                    'assets/images/review.png',
                                    fit: BoxFit.fitWidth,
                                    width: maxWidth,
                                  ),
                                ),
                                Positioned(
                                  top: 16.0,
                                  left: 16.0,
                                  child: CloseIcon(
                                    onExit: () {
                                      ref
                                          .read(analyticsApiProvider)
                                          .logEvent('rating_popup_close', {});
                                      // ignore: use_build_context_synchronously
                                      rating.delay().then(
                                        (_) => Navigator.of(context).pop(),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Flexible(
                            flex: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Text(
                                Translations.of(context).review_popup.title,
                                textAlign: TextAlign.center,
                                style: context.textTheme.headlineSmall,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              Translations.of(context).review_popup.description,
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(analyticsApiProvider)
                                    .logEvent('rating_popup_show', {});
                                ratingRepository
                                    .rate()
                                    .then((res) => rating.review())
                                    .then((_) => Navigator.of(context).pop());
                              },
                              child: Text(
                                Translations.of(
                                  context,
                                ).review_popup.rate_button,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextButton(
                            onPressed: () {
                              /// Close the dialog and open the feedback page as we return true
                              Navigator.of(context).pop(true);
                            },
                            child: Text(
                              Translations.of(
                                context,
                              ).review_popup.cancel_button,
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: context.colors.onBackground,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    ).then((shouldOpenFeedbackPage) {
      if (shouldOpenFeedbackPage == true && ref.context.mounted) {
        ref.context.push("/feedback");
      }
    });
    return true;
  });
}

class CloseIcon extends StatelessWidget {
  final VoidCallback onExit;

  const CloseIcon({super.key, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onExit.call(),
          child: Ink(
            width: 32,
            height: 32,
            // padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: context.colors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              color: context.colors.onBackground,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}
