import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Here is just a simple content card
class AdminPanelCard extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String description;
  final Color? textColor;
  final Color? backgroundColor;

  const AdminPanelCard({
    super.key,
    required this.onTap,
    required this.title,
    required this.description,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.mediumImpact();
        onTap.call();
      },
      child: Card(
        color: backgroundColor ?? context.colors.primary.withValues(alpha: .15),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                title,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: textColor ?? context.colors.onSurface,
                ),
              ),
              Text(
                description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color:
                      textColor ??
                      context.colors.onSurface.withValues(alpha: .6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
