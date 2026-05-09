import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/features/travel_mode/controllers/travel_mode_controller.dart';
import 'package:refyn/app/features/travel_mode/ui/widgets/travel_mode_active_card/widgets/travel_mode_obs_painter.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/theme/app_spacing.dart';

class TripSummaryHero extends StatefulWidget {
  const TripSummaryHero({super.key});

  @override
  State<TripSummaryHero> createState() => _TripSummaryHeroState();
}

class _TripSummaryHeroState extends State<TripSummaryHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TravelModeController controller = context.watch<TravelModeController>();
    final String code = controller.tripCurrency ?? '';
    final String homeCode = controller.homeCurrency;
    final NumberFormat fmt = NumberFormat.currency(symbol: '', decimalDigits: 2);
    final String spend = fmt.format(controller.tripSpend).trim();
    final int day = controller.tripDayNumber;
    final double avg = controller.tripSpend / (day <= 0 ? 1 : day);
    final String avgText = fmt.format(avg).trim();
    final double topInset = MediaQuery.paddingOf(context).top;
    final ThemeData theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFF1B1F4B),
                    Color(0xFF3A2C66),
                    Color(0xFFDE6834),
                  ],
                  stops: <double>[0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambient,
              builder: (BuildContext context, Widget? _) => CustomPaint(
                painter: TravelModeOrbsPainter(progress: _ambient.value),
              ),
            ),
          ),
          Positioned(
            top: topInset + 8,
            right: -10,
            child: AnimatedBuilder(
              animation: _ambient,
              builder: (BuildContext context, Widget? _) {
                final double t = _ambient.value;
                return Transform.translate(
                  offset: Offset(-t * 8, t * 4),
                  child: Transform.rotate(
                    angle: -0.35 + t * 0.05,
                    child: Icon(
                      Icons.flight_rounded,
                      size: 88,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              topInset + AppSpacing.md,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: _ambient,
                      builder: (BuildContext context, Widget? _) {
                        final double t = _ambient.value;
                        return Transform.translate(
                          offset: Offset(t * 4 - 2, -t * 2),
                          child: const Icon(
                            Icons.flight_takeoff_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.travelModeActiveLabel.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        letterSpacing: 1.6,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    _ConvertsChip(homeCode: homeCode),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.travelModeDayBadge(day),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.12),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        context.l10n.travelModeSpentSoFar,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              spend,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              code,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          _MetricChip(
                            icon: Icons.receipt_long_rounded,
                            label: context.l10n.travelModeReceiptCount(
                              controller.tripReceiptCount,
                            ),
                          ),
                          _MetricChip(
                            icon: Icons.trending_up_rounded,
                            label: context.l10n.tripHeroAvgPerDay(avgText, code),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConvertsChip extends StatelessWidget {
  const _ConvertsChip({required this.homeCode});

  final String homeCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.swap_horiz_rounded,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            context.l10n.tripHeroConvertsTo(homeCode),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.85)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
