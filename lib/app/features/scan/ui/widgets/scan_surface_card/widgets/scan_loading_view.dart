import 'package:flutter/material.dart';
import 'package:refyn/app/features/scan/ui/widgets/premium_scan_loading_panel/premium_scan_loading_panel.dart';
import 'package:refyn/theme/app_spacing.dart';

class ScanLoadingView extends StatelessWidget {
  const ScanLoadingView({
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
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: PremiumScanLoadingPanel(
          imagePath: imagePath,
          loadingStep: loadingStep,
          steps: steps,
          onCancel: onCancel,
          cancelLabel: cancelLabel,
          scanningLabel: scanningLabel,
        ),
      ),
    );
  }
}