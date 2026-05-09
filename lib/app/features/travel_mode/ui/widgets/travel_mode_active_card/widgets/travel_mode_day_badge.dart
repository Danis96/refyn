import 'package:flutter/material.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';

class TravelModeDayBadge extends StatelessWidget {
  const TravelModeDayBadge({
    super.key,
    required this.dayNumber,
  });

  final int dayNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        context.l10n.travelModeDayBadge(dayNumber),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
