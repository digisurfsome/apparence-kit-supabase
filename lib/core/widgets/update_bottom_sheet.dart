import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Shows a modal bottom sheet displaying app update information
Future<void> showUpdateBottomSheet({
  required BuildContext context,
  required String version,
  bool useRootNavigator = true,
}) async {
  await showModalBottomSheet(
    context: context,
    useSafeArea: true,
    useRootNavigator: useRootNavigator,
    barrierColor: context.colors.background.withValues(alpha: 0.90),
    isScrollControlled: true,
    builder: (context) => _UpdateBottomSheet(version: version),
  );
}

class _UpdateBottomSheet extends StatelessWidget {
  final String version;

  const _UpdateBottomSheet({required this.version});

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context).update_bottom_sheet;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
          strokeAlign: BorderSide.strokeAlignOutside,
          width: 2,
        ),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 0,
              child: Align(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/images/update.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Header with sparkle icon and close button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.star_border_purple500,
                      color: context.colors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translations.title,
                          style: context.textTheme.headlineSmall?.copyWith(
                            color: context.colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Version $version",
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Update highlights
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemBuilder: (context, index) {
                    final highlight = translations.highlights[index];
                    return _UpdateHighlightTile(highlight: highlight);
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemCount: translations.highlights.length,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(translations.continue_button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateHighlightTile extends StatelessWidget {
  final String highlight;

  const _UpdateHighlightTile({required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: context.colors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            highlight,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
