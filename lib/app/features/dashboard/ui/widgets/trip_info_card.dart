import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/features/dashboard/action_utils/dashboard_action_utils.dart';
import 'package:refyn/app/features/travel_mode/action_utils/travel_mode_action_utils.dart';
import 'package:refyn/app/features/travel_mode/controllers/travel_mode_controller.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/theme/app_spacing.dart';

class TripInfoCard extends StatelessWidget {
  const TripInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TravelModeController travel = context.watch<TravelModeController>();
    final String homeCode = travel.homeCurrency;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm + 1,
        AppSpacing.sm,
        AppSpacing.sm + 1,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        border: Border.all(color: HomeThemePalette.cardBorder(context)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.20 : 0.12,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.flag_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  context.l10n.tripInfoCardTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.tripInfoCardSubtitle(homeCode),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _EndTripPill(
            onPressed: () => TravelModeActionUtils.endTrip(context),
          ),
        ],
      ),
    );
  }
}

class _EndTripPill extends StatelessWidget {
  const _EndTripPill({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color bg = theme.colorScheme.error;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.flight_land_rounded,
                size: 15,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                context.l10n.travelModeEndTrip,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
