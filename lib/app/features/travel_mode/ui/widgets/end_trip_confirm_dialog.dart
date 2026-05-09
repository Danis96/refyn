import 'package:flutter/material.dart';
import 'package:refyn/app/features/travel_mode/repository/travel_mode_service.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/theme/app_colors.dart';

Future<TripEndStrategy?> showEndTripConfirmDialog(
  BuildContext context, {
  required String tripCurrency,
  required String homeCurrency,
  required int receiptCount,
}) {
  return showDialog<TripEndStrategy>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) => _EndTripConfirmDialog(
      tripCurrency: tripCurrency,
      homeCurrency: homeCurrency,
      receiptCount: receiptCount,
    ),
  );
}

class _EndTripConfirmDialog extends StatefulWidget {
  const _EndTripConfirmDialog({
    required this.tripCurrency,
    required this.homeCurrency,
    required this.receiptCount,
  });

  final String tripCurrency;
  final String homeCurrency;
  final int receiptCount;

  @override
  State<_EndTripConfirmDialog> createState() => _EndTripConfirmDialogState();
}

class _EndTripConfirmDialogState extends State<_EndTripConfirmDialog> {
  TripEndStrategy _strategy = TripEndStrategy.perDayRates;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final navigator = Navigator.of(context);

    return Dialog(
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Header(
              tripCurrency: widget.tripCurrency,
              homeCurrency: widget.homeCurrency,
              isDark: isDark,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 6),
              child: Text(
                context.l10n.tripEndDialogTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                context.l10n.tripEndDialogIntro(
                  widget.receiptCount,
                  widget.tripCurrency,
                  widget.homeCurrency,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                children: <Widget>[
                  _StrategyTile(
                    icon: Icons.timeline_rounded,
                    title: context.l10n.tripEndStrategyPerDayTitle,
                    subtitle: context.l10n.tripEndStrategyPerDaySubtitle,
                    selected: _strategy == TripEndStrategy.perDayRates,
                    onTap: () => setState(
                      () => _strategy = TripEndStrategy.perDayRates,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StrategyTile(
                    icon: Icons.bolt_rounded,
                    title: context.l10n.tripEndStrategyTodayTitle,
                    subtitle: context.l10n.tripEndStrategyTodaySubtitle,
                    selected: _strategy == TripEndStrategy.todaysRate,
                    onTap: () => setState(
                      () => _strategy = TripEndStrategy.todaysRate,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => navigator.pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: Text(context.l10n.cancel),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    onPressed: () => navigator.pop(_strategy),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: AppColors.brandOnPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(context.l10n.tripEndDialogConfirm),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.tripCurrency,
    required this.homeCurrency,
    required this.isDark,
  });

  final String tripCurrency;
  final String homeCurrency;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const <Color>[
                    AppColors.brandPrimaryContainerDark,
                    Color(0xFF2A140A),
                  ]
                : const <Color>[
                    AppColors.brandPrimaryContainerLight,
                    Color(0xFFFFCFB1),
                  ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _Chip(code: tripCurrency, isDark: isDark),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.east_rounded,
                size: 28,
                color: isDark
                    ? AppColors.brandOnPrimaryContainerDark
                    : AppColors.brandOnPrimaryContainerLight,
              ),
            ),
            _Chip(code: homeCurrency, isDark: isDark, highlight: true),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.code,
    required this.isDark,
    this.highlight = false,
  });

  final String code;
  final bool isDark;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final Color background = highlight
        ? AppColors.brandPrimary
        : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white);
    final Color foreground = highlight
        ? AppColors.brandOnPrimary
        : (isDark
              ? AppColors.brandOnPrimaryContainerDark
              : AppColors.brandOnPrimaryContainerLight);

    return Expanded(
      child: Container(
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          boxShadow: highlight
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.brandPrimary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Text(
          code,
          style: TextStyle(
            color: foreground,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _StrategyTile extends StatelessWidget {
  const _StrategyTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color borderColor = selected
        ? AppColors.brandPrimary
        : scheme.outlineVariant.withValues(alpha: 0.5);
    final Color bg = selected
        ? AppColors.brandPrimary.withValues(alpha: 0.08)
        : Colors.transparent;
    final Color iconBg = selected
        ? AppColors.brandPrimary
        : scheme.surfaceContainerHighest;
    final Color iconFg = selected
        ? AppColors.brandOnPrimary
        : scheme.onSurfaceVariant;
    final ThemeData theme = Theme.of(context);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: selected ? 1.6 : 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: selected
                    ? AppColors.brandPrimary
                    : scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
