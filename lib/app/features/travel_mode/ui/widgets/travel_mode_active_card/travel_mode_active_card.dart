import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/features/travel_mode/controllers/travel_mode_controller.dart';
import 'package:refyn/app/features/travel_mode/ui/widgets/travel_mode_active_card/widgets/travel_mode_day_badge.dart';
import 'package:refyn/app/features/travel_mode/ui/widgets/travel_mode_active_card/widgets/travel_mode_end_trip_button.dart';
import 'package:refyn/app/features/travel_mode/ui/widgets/travel_mode_active_card/widgets/travel_mode_obs_painter.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';

class TravelModeActiveCard extends StatefulWidget {
  const TravelModeActiveCard({
    super.key,
    required this.onEndTrip,
    required this.onOpenReceipts,
  });

  final VoidCallback onEndTrip;
  final VoidCallback onOpenReceipts;

  @override
  State<TravelModeActiveCard> createState() => _TravelModeActiveCardState();
}

class _TravelModeActiveCardState extends State<TravelModeActiveCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _planeController;

  @override
  void initState() {
    super.initState();
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _planeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TravelModeController controller = context.watch<TravelModeController>();
    if (!controller.isActive || controller.tripCurrency == null) {
      return const SizedBox.shrink();
    }

    final String code = controller.tripCurrency!;
    final NumberFormat fmt = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    );
    final String spendText = fmt.format(controller.tripSpend).trim();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF1B1F4B),
            Color(0xFF3A2C66),
            Color(0xFFDE6834),
          ],
          stops: <double>[0.0, 0.55, 1.0],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF1B1F4B).withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: widget.onOpenReceipts,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _planeController,
                    builder: (BuildContext context, Widget? child) {
                      final double t = _planeController.value;
                      return CustomPaint(
                        painter: TravelModeOrbsPainter(progress: t),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          AnimatedBuilder(
                            animation: _planeController,
                            builder: (BuildContext context, Widget? child) {
                              final double t = _planeController.value;
                              return Transform.translate(
                                offset: Offset(t * 6 - 3, -t * 2),
                                child: const Icon(
                                  Icons.flight_takeoff_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.travelModeActiveLabel.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              letterSpacing: 1.6,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          TravelModeDayBadge(dayNumber: controller.tripDayNumber),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            code,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              context.l10n.travelModeScanningIn,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  context.l10n.travelModeSpentSoFar,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        spendText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      code,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  context.l10n.travelModeReceiptCount(
                                    controller.tripReceiptCount,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      context.l10n.travelModeViewReceipts,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.keyboard_arrow_up_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          TravelModeEndTripButton(onPressed: widget.onEndTrip),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
