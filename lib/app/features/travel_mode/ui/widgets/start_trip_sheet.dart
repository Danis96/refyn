import 'package:flutter/material.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/shared/utils/currency_presets.dart';
import 'package:refyn/theme/app_colors.dart';

Future<String?> showStartTripSheet(
  BuildContext context, {
  required String homeCurrency,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return _StartTripSheet(homeCurrency: homeCurrency);
    },
  );
}

class _StartTripSheet extends StatefulWidget {
  const _StartTripSheet({required this.homeCurrency});

  final String homeCurrency;

  @override
  State<_StartTripSheet> createState() => _StartTripSheetState();
}

class _StartTripSheetState extends State<_StartTripSheet> {
  String? _selectedCode;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<CurrencyPreset> options = kCurrencyPresets
        .where((CurrencyPreset p) => p.code != widget.homeCurrency)
        .toList(growable: false);

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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flight_takeoff_rounded,
                  color: AppColors.brandPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.l10n.travelStartSheetTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      context.l10n.travelStartSheetSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: options.map((CurrencyPreset p) {
                  final bool selected = _selectedCode == p.code;
                  return _CurrencyChip(
                    preset: p,
                    selected: selected,
                    onTap: () => setState(() => _selectedCode = p.code),
                  );
                }).toList(growable: false),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(context.l10n.cancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _selectedCode == null
                      ? null
                      : () => Navigator.of(context).pop(_selectedCode),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: AppColors.brandOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(context.l10n.travelStartSheetConfirm),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  const _CurrencyChip({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final CurrencyPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color bg = selected
        ? AppColors.brandPrimary
        : scheme.surfaceContainerHighest;
    final Color fg = selected
        ? AppColors.brandOnPrimary
        : scheme.onSurface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(preset.flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                preset.code,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
