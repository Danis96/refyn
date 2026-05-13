import 'package:flutter/material.dart';
import 'package:refyn/app/features/scan/ui/widgets/premium_scan_loading_panel/widgets/right_panel_component.dart';
import 'package:refyn/app/features/scan/ui/widgets/premium_scan_loading_panel/widgets/scan_thumbnail_component.dart';

/// Entry sequence (1100 ms one-shot):
///   0 – 420 ms   card slides up from below + scale pop (easeOutBack)
///   220 – 720 ms scan overlay wipes left→right across thumbnail
///   440 – 820 ms right panel fades + slides in from right
///   560 – 1100ms step rows stagger in one-by-one
///
/// Loop animations:
///   scan line sweeps top↔bottom (ping-pong, 2 s)
///   concentric pulse rings (1.8 s reverse)
///   5 particles orbit the centre (4 s)
///   progress-bar shimmer (1.5 s)
class PremiumScanLoadingPanel extends StatefulWidget {
  const PremiumScanLoadingPanel({
    super.key,
    required this.imagePath,
    required this.loadingStep,
    required this.steps,
    required this.onCancel,
    required this.cancelLabel,
    required this.scanningLabel,
  });

  final String? imagePath;
  final int loadingStep;
  final List<String> steps;
  final VoidCallback onCancel;
  final String cancelLabel;
  final String scanningLabel;

  @override
  State<PremiumScanLoadingPanel> createState() =>
      _PremiumScanLoadingPanelState();
}

class _PremiumScanLoadingPanelState extends State<PremiumScanLoadingPanel>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final Animation<double> _cardSlide;
  late final Animation<double> _cardScale;
  late final Animation<double> _scanReveal;
  late final Animation<double> _panelFade;
  late final Animation<Offset> _panelSlide;

  late final AnimationController _scanCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _orbitCtrl;
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _cardSlide = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.42, curve: Curves.easeOutBack),
    );

    _cardScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.80, end: 1.04)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.04, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 55,
      ),
    ]).animate(
      CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0, 0.50)),
    );

    _scanReveal = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.20, 0.68, curve: Curves.easeOutCubic),
    );

    _panelFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.40, 0.80, curve: Curves.easeOut),
    );

    _panelSlide = Tween<Offset>(
      begin: const Offset(0.10, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.40, 0.82, curve: Curves.easeOutCubic),
      ),
    );

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    _orbitCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final int clamped = widget.loadingStep.clamp(0, widget.steps.length);
    final double progress =
    widget.steps.isEmpty ? 0 : clamped / widget.steps.length;

    final Color accent = cs.primary;
    final Color scanBg = isDark
        ? Color.lerp(cs.surface, Colors.black, 0.60)!
        : Color.lerp(cs.surface, cs.primary, 0.07)!;

    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, 44 * (1 - _cardSlide.value)),
          child: Opacity(
            opacity: _cardSlide.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _cardScale.value,
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(
                    alpha: isDark ? 0.55 : 0.45,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.20),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: isDark ? 0.10 : 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        ScanThumbnail(
                          imagePath: widget.imagePath,
                          scanReveal: _scanReveal,
                          scanAnim: _scanCtrl,
                          pulseAnim: _pulseCtrl,
                          orbitAnim: _orbitCtrl,
                          accent: accent,
                          scanBg: scanBg,
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SlideTransition(
                        position: _panelSlide,
                        child: FadeTransition(
                          opacity: _panelFade,
                          child: RightPanel(
                            steps: widget.steps,
                            loadingStep: clamped,
                            progress: progress,
                            onCancel: widget.onCancel,
                            cancelLabel: widget.cancelLabel,
                            scanningLabel: widget.scanningLabel,
                            pulseAnim: _pulseCtrl,
                            shimmerAnim: _shimmerCtrl,
                            entryValue: _entryCtrl.value,
                            accent: accent,
                            onSurface: cs.onSurface,
                            secondary: cs.secondary,
                            tertiaryColor: cs.tertiary,
                            progressBg: cs.secondary.withValues(alpha: 0.14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
