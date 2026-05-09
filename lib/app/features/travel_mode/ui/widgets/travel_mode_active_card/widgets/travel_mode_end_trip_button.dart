import 'package:flutter/material.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';

class TravelModeEndTripButton extends StatelessWidget {
  const TravelModeEndTripButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.flag_rounded,
                size: 16,
                color: Color(0xFF1B1F4B),
              ),
              const SizedBox(width: 6),
              Text(
                context.l10n.travelModeEndTrip,
                style: const TextStyle(
                  color: Color(0xFF1B1F4B),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
