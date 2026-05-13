import 'dart:io';

import 'package:flutter/material.dart';

import 'loading_painters.dart';

class ScanThumbnail extends StatelessWidget {
  const ScanThumbnail({
    super.key,
    required this.imagePath,
    required this.scanReveal,
    required this.scanAnim,
    required this.pulseAnim,
    required this.orbitAnim,
    required this.accent,
    required this.scanBg,
  });

  static const double thumbnailWidth = 92;
  static const double thumbnailHeight = 124;

  final String? imagePath;
  final Animation<double> scanReveal;
  final Animation<double> scanAnim;
  final Animation<double> pulseAnim;
  final Animation<double> orbitAnim;
  final Color accent;
  final Color scanBg;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: thumbnailWidth,
      height: thumbnailHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imagePath != null)
              Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                cacheWidth: (thumbnailWidth * 3).round(),
                filterQuality: FilterQuality.low,
                errorBuilder: (_, __, ___) =>
                    FallbackBg(color: scanBg, accent: accent),
              )
            else
              FallbackBg(color: scanBg, accent: accent),
            AnimatedBuilder(
              animation: scanReveal,
              builder: (_, __) {
                return ClipRect(
                  clipper: LeftWipeClipper(scanReveal.value),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: scanBg.withValues(alpha: 0.80)),
                      CustomPaint(painter: DotGridPainter(accent)),
                      AnimatedBuilder(
                        animation: orbitAnim,
                        builder: (_, __) => CustomPaint(
                          painter: OrbitPainter(
                            progress: orbitAnim.value,
                            color: accent,
                          ),
                        ),
                      ),
                      CustomPaint(painter: BracketPainter(accent)),
                      AnimatedBuilder(
                        animation: scanAnim,
                        builder: (_, __) => CustomPaint(
                          painter: ScanLinePainter(
                            progress: scanAnim.value,
                            color: accent,
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: pulseAnim,
                        builder: (_, __) => Center(
                          child: CustomPaint(
                            painter: PulseRingPainter(
                              pulse: pulseAnim.value,
                              color: accent,
                            ),
                            size: const Size(52, 52),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: scanReveal,
              builder: (_, __) {
                final double v = scanReveal.value;
                if (v <= 0 || v >= 1) return const SizedBox.shrink();
                return Positioned(
                  left: v * thumbnailWidth - 10,
                  top: 0,
                  bottom: 0,
                  width: 20,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          accent.withValues(alpha: 0.70),
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
      ),
    );
  }
}

class FallbackBg extends StatelessWidget {
  const FallbackBg({
    super.key,
    required this.color,
    required this.accent,
  });

  final Color color;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Center(
        child: Icon(
          Icons.receipt_long_outlined,
          size: 36,
          color: accent.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
