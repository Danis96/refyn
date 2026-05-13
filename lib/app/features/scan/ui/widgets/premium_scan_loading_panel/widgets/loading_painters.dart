import 'dart:math' as math;

import 'package:flutter/material.dart';

class LeftWipeClipper extends CustomClipper<Rect> {
  const LeftWipeClipper(this.fraction);
  final double fraction;

  @override
  Rect getClip(Size s) => Rect.fromLTWH(0, 0, s.width * fraction, s.height);

  @override
  bool shouldReclip(LeftWipeClipper oldClipper) => oldClipper.fraction != fraction;
}

class DotGridPainter extends CustomPainter {
  DotGridPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = color.withValues(alpha: 0.14);
    const double gap = 14.0;
    for (double x = gap / 2; x < size.width; x += gap) {
      for (double y = gap / 2; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.1, p);
      }
    }
  }

  @override
  bool shouldRepaint(DotGridPainter oldDelegate) => oldDelegate.color != color;
}

class BracketPainter extends CustomPainter {
  BracketPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const double arm = 12.0, m = 9.0;
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void b(Offset o, double dx, double dy) {
      canvas.drawLine(o, o.translate(dx, 0), p);
      canvas.drawLine(o, o.translate(0, dy), p);
    }

    b(const Offset(m, m), arm, arm);
    b(Offset(size.width - m, m), -arm, arm);
    b(Offset(m, size.height - m), arm, -arm);
    b(Offset(size.width - m, size.height - m), -arm, -arm);
  }

  @override
  bool shouldRepaint(BracketPainter oldDelegate) => oldDelegate.color != color;
}

class ScanLinePainter extends CustomPainter {
  ScanLinePainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double t = progress < 0.5 ? progress * 2 : (1 - progress) * 2;
    final double y =
        size.height * 0.10 + Curves.easeInOut.transform(t) * size.height * 0.80;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, y),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.0), color.withValues(alpha: 0.08)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, y)),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, y - 9, size.width, 18),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            color.withValues(alpha: 0.38),
            color.withValues(alpha: 0.58),
            color.withValues(alpha: 0.38),
            Colors.transparent,
          ],
          stops: const [0, 0.28, 0.5, 0.72, 1.0],
        ).createShader(Rect.fromLTWH(0, y - 9, size.width, 18))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = color
        ..strokeWidth = 1.4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8),
    );
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class PulseRingPainter extends CustomPainter {
  PulseRingPainter({required this.pulse, required this.color});
  final double pulse;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;

    canvas.drawCircle(
      c,
      r * (0.62 + pulse * 0.38),
      Paint()
        ..color = color.withValues(alpha: (1 - pulse) * 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    canvas.drawCircle(
      c,
      r * 0.42,
      Paint()
        ..color = color.withValues(alpha: 0.32 + pulse * 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    canvas.drawCircle(
      c,
      5.5,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + pulse * 3),
    );

    canvas.drawCircle(
      c,
      3.2,
      Paint()..color = Colors.white.withValues(alpha: 0.90),
    );
  }

  @override
  bool shouldRepaint(PulseRingPainter oldDelegate) =>
      oldDelegate.pulse != pulse || oldDelegate.color != color;
}

class OrbitPainter extends CustomPainter {
  OrbitPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  static const List<OrbitParticleData> _ps = [
    OrbitParticleData(rf: 0.30, sz: 2.2, sp: 1.00, ph: 0.00),
    OrbitParticleData(rf: 0.38, sz: 1.6, sp: 0.72, ph: 0.33),
    OrbitParticleData(rf: 0.26, sz: 1.9, sp: 1.35, ph: 0.67),
    OrbitParticleData(rf: 0.44, sz: 1.4, sp: 0.52, ph: 0.15),
    OrbitParticleData(rf: 0.20, sz: 2.0, sp: 1.80, ph: 0.82),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);
    final double maxR = math.min(size.width, size.height) / 2;

    for (final p in _ps) {
      final double angle = (progress * p.sp + p.ph) * 2 * math.pi;
      final Offset pos = c +
          Offset(math.cos(angle) * maxR * p.rf, math.sin(angle) * maxR * p.rf);
      final double alpha = 0.35 + 0.45 * math.sin(angle + math.pi / 2).abs();

      canvas.drawCircle(
        pos,
        p.sz,
        Paint()
          ..color = color.withValues(alpha: alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.sz * 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(OrbitPainter oldDelegate) => oldDelegate.progress != progress;
}

class OrbitParticleData {
  const OrbitParticleData({
    required this.rf,
    required this.sz,
    required this.sp,
    required this.ph,
  });
  final double rf, sz, sp, ph;
}
