import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppCloseButtonComponent extends ConsumerWidget {
  final ValueNotifier<bool> showCloseBtn;

  final VoidCallback? onTap;

  const AppCloseButtonComponent({
    super.key,
    required this.showCloseBtn,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: showCloseBtn,
      builder: (context, value, child) {
        if (value) {
          return AppCloseButton(onTap: onTap);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class AppCloseButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AppCloseButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTapUp: (_) {
          onTap?.call();
        },
        child: Ink(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.onBackground.withValues(alpha: 0.6),
          ),
          child: Center(
            child: Icon(
              Icons.close,
              color: context.colors.background,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}
