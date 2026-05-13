import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.progress,
    required this.shimmerAnim,
    required this.accent,
    required this.tertiaryColor,
    required this.bgColor,
  });

  final double progress;
  final Animation<double> shimmerAnim;
  final Color accent;
  final Color tertiaryColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double filled = constraints.maxWidth * progress.clamp(0.0, 1.0);
        return Container(
          height: 6,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                width: filled,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(colors: [accent, tertiaryColor]),
                ),
              ),
              if (progress > 0 && progress < 1)
                AnimatedBuilder(
                  animation: shimmerAnim,
                  builder: (_, __) {
                    final double sx = shimmerAnim.value * filled - 20;
                    return Positioned(
                      left: sx,
                      top: 0,
                      bottom: 0,
                      width: 40,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.40),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
