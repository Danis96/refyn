import 'package:flutter/material.dart';

class TravelModeOrbsPainter extends CustomPainter {
  TravelModeOrbsPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    final Paint p2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    final double drift = (progress - 0.5) * 18;
    canvas.drawCircle(
      Offset(size.width * 0.85 + drift, size.height * 0.25),
      80,
      p1,
    );
    canvas.drawCircle(
      Offset(size.width * 0.15 - drift, size.height * 0.85),
      60,
      p2,
    );
  }

  @override
  bool shouldRepaint(covariant TravelModeOrbsPainter old) => old.progress != progress;
}
