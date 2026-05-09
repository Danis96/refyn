import 'package:flutter/material.dart';
import 'package:refyn/app/features/dashboard/action_utils/dashboard_action_utils.dart';

enum HomeViewMode { home, trip }

class HomeViewModeSwitcher extends StatelessWidget {
  const HomeViewModeSwitcher({
    super.key,
    required this.mode,
    required this.onChanged,
    required this.homeLabel,
    required this.tripLabel,
  });

  final HomeViewMode mode;
  final ValueChanged<HomeViewMode> onChanged;
  final String homeLabel;
  final String tripLabel;

  static const Duration _kAnimDuration = Duration(milliseconds: 260);
  static const Curve _kAnimCurve = Curves.easeOutCubic;
  static const double _kHeight = 40;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final Color trackColor = theme.colorScheme.surface;
    final Color borderColor = HomeThemePalette.cardBorder(context);
    final Color indicatorColor = theme.colorScheme.primary.withValues(
      alpha: dark ? 0.20 : 0.12,
    );

    return Container(
      height: _kHeight,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Stack(
        children: <Widget>[
          AnimatedAlign(
            duration: _kAnimDuration,
            curve: _kAnimCurve,
            alignment: mode == HomeViewMode.home
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              _SegmentLabel(
                label: homeLabel,
                icon: Icons.home_rounded,
                selected: mode == HomeViewMode.home,
                onTap: () => onChanged(HomeViewMode.home),
              ),
              _SegmentLabel(
                label: tripLabel,
                icon: Icons.flight_takeoff_rounded,
                selected: mode == HomeViewMode.trip,
                onTap: () => onChanged(HomeViewMode.trip),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color selectedColor = theme.colorScheme.primary;
    final Color unselectedColor = theme.colorScheme.secondary;
    final Color color = selected ? selectedColor : unselectedColor;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: HomeViewModeSwitcher._kAnimDuration,
                curve: HomeViewModeSwitcher._kAnimCurve,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.2,
                  height: 1,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
