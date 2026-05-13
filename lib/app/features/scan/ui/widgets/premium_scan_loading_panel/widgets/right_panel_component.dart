import 'package:flutter/material.dart';
import 'package:refyn/app/features/scan/ui/widgets/premium_scan_loading_panel/widgets/progress_bar_component.dart';
import 'package:refyn/app/features/scan/ui/widgets/premium_scan_loading_panel/widgets/step_row_component.dart';

class RightPanel extends StatelessWidget {
  const RightPanel({
    super.key,
    required this.steps,
    required this.loadingStep,
    required this.progress,
    required this.onCancel,
    required this.cancelLabel,
    required this.scanningLabel,
    required this.pulseAnim,
    required this.shimmerAnim,
    required this.entryValue,
    required this.accent,
    required this.onSurface,
    required this.secondary,
    required this.tertiaryColor,
    required this.progressBg,
  });

  final List<String> steps;
  final int loadingStep;
  final double progress;
  final VoidCallback onCancel;
  final String cancelLabel;
  final String scanningLabel;
  final Animation<double> pulseAnim;
  final Animation<double> shimmerAnim;
  final double entryValue;
  final Color accent;
  final Color onSurface;
  final Color secondary;
  final Color tertiaryColor;
  final Color progressBg;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, __) => Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(
                        alpha: 0.45 + pulseAnim.value * 0.45,
                      ),
                      blurRadius: 5 + pulseAnim.value * 5,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                scanningLabel,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: tt.labelSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Semantics(
          label: scanningLabel,
          value: '${(progress * 100).round()}%',
          child: ProgressBar(
            progress: progress,
            shimmerAnim: shimmerAnim,
            accent: accent,
            tertiaryColor: tertiaryColor,
            bgColor: progressBg,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(steps.length, (i) {
          final bool done = i < loadingStep;
          final bool active = i == loadingStep && loadingStep < steps.length;
          final double start = 0.52 + i * 0.07;
          final double localT =
          ((entryValue - start) / (1.0 - start)).clamp(0.0, 1.0);
          final double opacity = Curves.easeOut.transform(localT);

          return Transform.translate(
            offset: Offset((1 - opacity) * 10, 0),
            child: Opacity(
              opacity: opacity,
              child: StepRow(
                title: steps[i],
                done: done,
                active: active,
                pulseAnim: pulseAnim,
                accent: accent,
                secondary: secondary,
                onSurface: onSurface,
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: onSurface,
              backgroundColor: accent.withValues(alpha: 0.06),
              side: BorderSide(color: accent.withValues(alpha: 0.16)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 38),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.close_rounded, size: 16),
            label: Text(
              cancelLabel,
              style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
