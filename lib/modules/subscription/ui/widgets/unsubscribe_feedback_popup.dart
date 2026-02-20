import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/i18n/translations.g.dart';
import 'package:flutter/material.dart';

const int kMinimumUnsubscribeReasonLength = 6;

typedef OnUnsubscribeConfirm = void Function(String reason);

/// This widget is used to show the unsubscribe feedback dialog
/// We kindly ask the user to provide a reason before unsubscribing
/// This is to help us improve the app and provide better support to our users
class UnsubscribeFeedbackPopup extends StatefulWidget {
  final OnUnsubscribeConfirm onConfirm;
  final VoidCallback onCancel;

  const UnsubscribeFeedbackPopup({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  static Future<void> show({
    required BuildContext context,
    required OnUnsubscribeConfirm onConfirm,
    required VoidCallback onCancel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return UnsubscribeFeedbackPopup(
          onConfirm: onConfirm,
          onCancel: onCancel,
        );
      },
    );
  }

  @override
  State<UnsubscribeFeedbackPopup> createState() =>
      _UnsubscribeFeedbackPopupState();
}

class _UnsubscribeFeedbackPopupState extends State<UnsubscribeFeedbackPopup> {
  final TextEditingController _reasonController = TextEditingController();
  bool _canUnsubscribe = false;

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(_onReasonChanged);
  }

  @override
  void dispose() {
    _reasonController.removeListener(_onReasonChanged);
    _reasonController.dispose();
    super.dispose();
  }

  void _onReasonChanged() {
    final hasMinimumLength =
        _reasonController.text.trim().length > kMinimumUnsubscribeReasonLength;
    if (hasMinimumLength != _canUnsubscribe) {
      setState(() {
        _canUnsubscribe = hasMinimumLength;
      });
    }
  }

  void _handleUnsubscribe() {
    if (_canUnsubscribe) {
      widget.onConfirm(_reasonController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context).activePremium;

    return Dialog(
      backgroundColor: context.colors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.onSurface.withValues(alpha: 0.15),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                translations.unsubscribe_feedback_title,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                translations.unsubscribe_feedback_description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: translations.unsubscribe_feedback_hint,
                  hintStyle: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: context.colors.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: context.colors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: context.colors.surface,
                ),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translations.unsubscribe_feedback_min_chars,
                style: context.textTheme.bodySmall?.copyWith(
                  color: !_canUnsubscribe
                      ? context.colors.primary
                      : context.colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: Text(translations.cancel_button),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: !_canUnsubscribe ? null : _handleUnsubscribe,
                      child: Text(translations.unsubscribe_button),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
