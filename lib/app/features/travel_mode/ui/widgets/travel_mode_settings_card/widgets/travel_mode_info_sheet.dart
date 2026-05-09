import 'package:flutter/material.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/theme/app_colors.dart';

class TravelModeInfoSheet extends StatelessWidget {
  const TravelModeInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: AppColors.brandPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.l10n.travelModeInfoTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.travelModeInfoSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _TravelModeInfoStep(
            icon: Icons.looks_one_rounded,
            titleKey: _TravelModeInfoStepKey.pickCurrencyTitle,
            bodyKey: _TravelModeInfoStepKey.pickCurrencyBody,
          ),
          const SizedBox(height: 12),
          const _TravelModeInfoStep(
            icon: Icons.looks_two_rounded,
            titleKey: _TravelModeInfoStepKey.scanNormallyTitle,
            bodyKey: _TravelModeInfoStepKey.scanNormallyBody,
          ),
          const SizedBox(height: 12),
          const _TravelModeInfoStep(
            icon: Icons.looks_3_rounded,
            titleKey: _TravelModeInfoStepKey.finishTripTitle,
            bodyKey: _TravelModeInfoStepKey.finishTripBody,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.tips_and_updates_outlined,
                  color: scheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.travelModeInfoNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: AppColors.brandOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(context.l10n.travelModeInfoConfirm),
          ),
        ],
      ),
    );
  }
}

enum _TravelModeInfoStepKey {
  pickCurrencyTitle,
  pickCurrencyBody,
  scanNormallyTitle,
  scanNormallyBody,
  finishTripTitle,
  finishTripBody,
}

class _TravelModeInfoStep extends StatelessWidget {
  const _TravelModeInfoStep({
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
  });

  final IconData icon;
  final _TravelModeInfoStepKey titleKey;
  final _TravelModeInfoStepKey bodyKey;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.brandPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _title(context),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _body(context),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _title(BuildContext context) {
    switch (titleKey) {
      case _TravelModeInfoStepKey.pickCurrencyTitle:
        return context.l10n.travelModeInfoStep1Title;
      case _TravelModeInfoStepKey.scanNormallyTitle:
        return context.l10n.travelModeInfoStep2Title;
      case _TravelModeInfoStepKey.finishTripTitle:
        return context.l10n.travelModeInfoStep3Title;
      default:
        throw StateError('Invalid title key: $titleKey');
    }
  }

  String _body(BuildContext context) {
    switch (bodyKey) {
      case _TravelModeInfoStepKey.pickCurrencyBody:
        return context.l10n.travelModeInfoStep1Body;
      case _TravelModeInfoStepKey.scanNormallyBody:
        return context.l10n.travelModeInfoStep2Body;
      case _TravelModeInfoStepKey.finishTripBody:
        return context.l10n.travelModeInfoStep3Body;
      default:
        throw StateError('Invalid body key: $bodyKey');
    }
  }
}
