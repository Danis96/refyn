import 'package:flutter/material.dart';

class StepRow extends StatelessWidget {
  const StepRow({
    super.key,
    required this.title,
    required this.done,
    required this.active,
    required this.pulseAnim,
    required this.accent,
    required this.secondary,
    required this.onSurface,
  });

  final String title;
  final bool done;
  final bool active;
  final Animation<double> pulseAnim;
  final Color accent;
  final Color secondary;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    final Color doneColor = Color.lerp(accent, const Color(0xFF22C77A), 0.68)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: active ? accent.withValues(alpha: 0.09) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: done
                  ? Icon(Icons.check_circle_rounded, color: doneColor, size: 16)
                  : active
                  ? AnimatedBuilder(
                animation: pulseAnim,
                builder: (_, __) {
                  final double s =
                      0.70 + (pulseAnim.value - 0.5).abs() * 0.60;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 15 * s,
                        height: 15 * s,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.22),
                        ),
                      ),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.55),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              )
                  : Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: secondary.withValues(alpha: 0.30),
                ),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: done
                      ? onSurface.withValues(alpha: 0.70)
                      : active
                      ? onSurface
                      : onSurface.withValues(alpha: 0.40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
