import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/features/travel_mode/controllers/travel_mode_controller.dart';
import 'package:refyn/app/features/travel_mode/ui/widgets/travel_mode_active_card/widgets/travel_mode_day_badge.dart';
import 'package:refyn/app/features/travel_mode/ui/widgets/travel_mode_active_card/widgets/travel_mode_obs_painter.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';

class ScanTravelModeBanner extends StatefulWidget {
  const ScanTravelModeBanner({super.key});

  @override
  State<ScanTravelModeBanner> createState() => _ScanTravelModeBannerState();
}

class _ScanTravelModeBannerState extends State<ScanTravelModeBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TravelModeController travel = context.watch<TravelModeController>();
    if (!travel.isActive || travel.tripCurrency == null) {
      return const SizedBox.shrink();
    }
    final String code = travel.tripCurrency!;
    final String home = travel.homeCurrency;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double scale, Widget? child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
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
              color: const Color(0xFF1B1F4B).withValues(alpha: 0.30),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget? _) => CustomPaint(
                    painter: TravelModeOrbsPainter(progress: _controller.value),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _IconBadge(controller: _controller),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  context.l10n.scanTravelBannerTitle(code),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                    letterSpacing: 0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              TravelModeDayBadge(
                                dayNumber: travel.tripDayNumber,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.l10n.scanTravelBannerSubtitle(home),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, Widget? _) {
              final double t = controller.value;
              return Container(
                width: 42 + t * 4,
                height: 42 + t * 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10 + t * 0.06),
                ),
              );
            },
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.30),
              ),
            ),
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: controller,
              builder: (BuildContext context, Widget? _) {
                final double t = controller.value;
                return Transform.translate(
                  offset: Offset(t * 4 - 2, -t * 1.5),
                  child: const Icon(
                    Icons.flight_takeoff_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
