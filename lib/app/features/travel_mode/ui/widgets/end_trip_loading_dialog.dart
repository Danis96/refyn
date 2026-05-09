import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/features/travel_mode/controllers/travel_mode_controller.dart';
import 'package:refyn/app/features/travel_mode/repository/travel_mode_service.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/theme/app_colors.dart';
import 'package:wiggly_loaders/wiggly_loaders.dart';

/// Shows a non-dismissible loading dialog that mirrors the active
/// [TravelModeController]'s end-trip progress. The caller is responsible for
/// running the `endTrip` future and popping the dialog when done.
Future<void> showEndTripLoadingDialog(
  BuildContext context, {
  required String tripCurrency,
  required String homeCurrency,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (BuildContext dialogContext) {
      return PopScope(
        canPop: false,
        child: _EndTripLoadingDialog(
          tripCurrency: tripCurrency,
          homeCurrency: homeCurrency,
        ),
      );
    },
  );
}

class _EndTripLoadingDialog extends StatelessWidget {
  const _EndTripLoadingDialog({
    required this.tripCurrency,
    required this.homeCurrency,
  });

  final String tripCurrency;
  final String homeCurrency;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 32,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const WigglyLoader.indeterminate(
              size: 64,
              strokeWidth: 3,
              arcSpan: 0.85,
              wiggleAmplitude: 1.6,
              progressColor: AppColors.brandPrimary,
            ),
            const SizedBox(height: 22),
            Text(
              '$tripCurrency  →  $homeCurrency',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Consumer<TravelModeController>(
              builder: (BuildContext context, TravelModeController c, _) {
                final TripEndProgress? progress = c.endProgress;
                final String label = _labelFor(context, progress);
                final double percent = progress?.percent ?? 0;
                return Column(
                  children: <Widget>[
                    SizedBox(
                      height: 22,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                        child: Text(
                          label,
                          key: ValueKey<String>(label),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: percent.clamp(0, 1),
                        minHeight: 6,
                        backgroundColor: scheme.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.brandPrimary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(BuildContext context, TripEndProgress? progress) {
    if (progress == null) {
      return context.l10n.tripEndLoadingFetchingRate;
    }
    switch (progress.step) {
      case TripEndStep.fetchingRate:
        return context.l10n.tripEndLoadingFetchingRate;
      case TripEndStep.fetchingHistorical:
        final String? date = progress.dateKey;
        return date == null
            ? context.l10n.tripEndLoadingFetchingRate
            : context.l10n.tripEndLoadingFetchingDate(date);
      case TripEndStep.converting:
        return context.l10n.tripEndLoadingConverting;
      case TripEndStep.finishing:
        return context.l10n.tripEndLoadingFinishing;
    }
  }
}
