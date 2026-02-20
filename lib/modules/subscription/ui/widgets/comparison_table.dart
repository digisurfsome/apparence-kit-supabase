import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/environnements.dart';
import 'package:apparence_kit/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Returns a list of [ComparisonTableRow] instances representing the features
/// available in the free and premium versions of the application.
/// Check the [ComparisonTableComponent] documentation for instructions on how to
/// add new features to the comparison table.
List<ComparisonTableRow> _getComparisonRows(BuildContext context, Environment environment) {
  final translations = Translations.of(context).premium.comparison;
  
  return [
    ComparisonTableRow(
      feature: translations.no_ads,
      isFree: false,
      isPremium: true,
    ),
    ComparisonTableRow(
      feature: translations.premium_themes,
      isFree: false,
      isPremium: true,
    ),
    ComparisonTableRow(
      feature: translations.advanced_customization,
      isFree: false,
      isPremium: true,
    ),
    ComparisonTableRow(
      feature: translations.priority_support,
      isFree: false,
      isPremium: true,
    ),
    ComparisonTableRow(
      feature: translations.home_widget,
      isFree: true,
      isPremium: true,
    ),
    ComparisonTableRow(
      feature: translations.talk_with_assistant,
      isFree: false,
      isPremium: true,
    ),
  ];
}

/// A widget that displays a comparison table between free and premium subscription features.
///
/// ### Usage
/// To use the `ComparisonTableComponent`, simply include it in your widget tree:
///
/// ```dart
/// ComparisonTableComponent(),
/// ```
///
/// ### Adding Features to the Comparison Table
/// To add new features to the comparison table, you need to modify the `getComparisonRows` method
/// in the [ComparisonTableRow] class. This method returns a list of `ComparisonTableRow` instances,
/// each representing a feature in the comparison table.
///
/// 1. **Define a New Feature**: Create a new instance of [ComparisonTableRow] with the appropriate
///    parameters:
///    - `feature`: A string representing the feature name.
///    - `isPremium`: A boolean indicating if the feature is available in the premium version.
///    - `isFree`: A boolean indicating if the feature is available in the free version.
///    - `premiumValue`: An optional string for any additional information specific to the premium version.
///    - `freeValue`: An optional string for any additional information specific to the free version.
///
/// 2. **Update the List**: Add the new [ComparisonTableRow] instance to the list returned by
///    `getComparisonRows`. For example:
///
/// ```dart
/// ComparisonTableRow(
///   feature: translations.new_feature,
///   isFree: true,
///   isPremium: true,
/// ),
/// ```
///
/// ### Translations
/// The `Translations` class is used to fetch localized strings for the comparison table. Ensure that
/// the new feature strings are added to the appropriate translation files to support multiple languages.
///
/// ### Example
/// Here’s an example of how to add a new feature called "Custom Reports":
///
/// ```dart
/// static List<ComparisonTableRow> getComparisonRows(BuildContext context, Environment environment) {
///   final translations = Translations.of(context).premium.comparison;
///
///   return [
///     ComparisonTableRow(
///       feature: translations.no_ads,
///       isFree: false,
///       isPremium: true,
///     ),
///     // ... other existing rows ...
///     ComparisonTableRow(
///       feature: translations.custom_reports, // New feature
///       isFree: false,
///       isPremium: true,
///     ),
///   ];
/// }
/// ```
///
/// This will add a new row to the comparison table indicating that "Custom Reports" is a premium-only feature.
class ComparisonTableComponent extends ConsumerWidget {
  const ComparisonTableComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ComparisonTable(
      rows: _getComparisonRows(context, ref.read(environmentProvider)),
      freeColumnTitle: ComparisonTableRow.getFreeColumnTitle(context),
      premiumColumnTitle: ComparisonTableRow.getPremiumColumnTitle(context),
    );
  }
}


class _ComparisonTable extends StatelessWidget {
  final List<ComparisonTableRow> rows;
  final String freeColumnTitle;
  final String premiumColumnTitle;

  const _ComparisonTable({
    required this.rows,
    required this.freeColumnTitle,
    required this.premiumColumnTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.onBackground.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              ...rows.asMap().entries.map(
                (entry) => _buildRow(
                  context,
                  entry.value,
                  isLast: entry.key == rows.length - 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                Translations.of(context).premium.comparison.features_label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: context.colors.grey1.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Text(
                freeColumnTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                border: Border(
                  left: BorderSide(
                    color: context.colors.grey1.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Text(
                premiumColumnTitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, ComparisonTableRow row, {required bool isLast}) {
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: context.colors.grey1.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                row.feature,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: context.colors.grey1.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: _buildCell(context, row.isFree, row.freeValue),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: context.colors.grey1.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: _buildCell(context, row.isPremium, row.premiumValue, isPremium: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(BuildContext context, bool isAvailable, String? value, {bool isPremium = false}) {
    if (value != null && value.isNotEmpty) {
      return Text(
        value,
        textAlign: TextAlign.center,
        style: context.textTheme.bodySmall?.copyWith(
          color: isPremium ? context.colors.primary : context.colors.onSurface,
          fontWeight: isPremium ? FontWeight.w600 : FontWeight.normal,
        ),
      );
    }

    return Icon(
      isAvailable 
        ? Icons.check
        : Icons.close,
      size: 20,
      color: isAvailable 
        ? (isPremium ? context.colors.primary : Colors.green)
        : context.colors.error,
    );
  }
}


class ComparisonTableRow {
  final String feature;
  final bool isPremium;
  final bool isFree;
  final String? premiumValue;
  final String? freeValue;

  const ComparisonTableRow({
    required this.feature,
    required this.isPremium,
    required this.isFree,
    this.premiumValue,
    this.freeValue,
  });

  static String getFreeColumnTitle(BuildContext context) {
    return Translations.of(context).premium.comparison.free_version;
  }

  static String getPremiumColumnTitle(BuildContext context) {
    return Translations.of(context).premium.comparison.premium_version;
  }
}
