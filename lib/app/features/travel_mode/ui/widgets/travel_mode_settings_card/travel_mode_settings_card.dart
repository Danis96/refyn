import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/features/travel_mode/controllers/travel_mode_controller.dart';
import 'package:refyn/app/features/travel_mode/ui/widgets/travel_mode_active_card/travel_mode_active_card.dart';
import 'package:refyn/app/features/travel_mode/ui/widgets/travel_mode_settings_card/widgets/travel_mode_idle_card.dart';

class TravelModeSettingsCard extends StatelessWidget {
  const TravelModeSettingsCard({
    super.key,
    required this.onStartTrip,
    required this.onEndTrip,
    required this.onOpenReceipts,
  });

  final VoidCallback onStartTrip;
  final VoidCallback onEndTrip;
  final VoidCallback onOpenReceipts;

  @override
  Widget build(BuildContext context) {
    final TravelModeController controller = context.watch<TravelModeController>();

    if (controller.isActive) {
      return TravelModeActiveCard(
        onEndTrip: onEndTrip,
        onOpenReceipts: onOpenReceipts,
      );
    }

    return TravelModeIdleCard(onStartTrip: onStartTrip);
  }
}
