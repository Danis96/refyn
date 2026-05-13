import 'package:flutter/material.dart';
import 'package:refyn/app/features/scan/ui/widgets/scan_surface_card/widgets/scan_error_view.dart';
import 'package:refyn/app/features/scan/ui/widgets/scan_surface_card/widgets/scan_idle_view.dart';
import 'package:refyn/app/features/scan/ui/widgets/scan_surface_card/widgets/scan_image_selected_view.dart';
import 'package:refyn/app/features/scan/ui/widgets/scan_surface_card/widgets/scan_loading_view.dart';
import 'package:refyn/app/features/scan/ui/widgets/scan_surface_card/widgets/scan_success_view.dart';
import 'package:refyn/app/features/scan/controllers/scan_view_state.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';

class ScanSurfaceCard extends StatelessWidget {
  const ScanSurfaceCard({
    super.key,
    required this.state,
    this.imagePath,
    this.imagePaths = const <String>[],
    this.loadingStep = 0,
    this.errorMessage,
    this.result,
    this.hasDraft = false,
    this.lowConfidence = false,
    this.savingDraft = false,
    required this.onGallery,
    required this.onCamera,
    required this.onAddPage,
    required this.onRemoveImage,
    required this.onScan,
    required this.onCancelScan,
    required this.onRetry,
    required this.onReset,
    required this.onScanAnother,
    required this.onEditDraft,
    required this.onSaveDraft,
    required this.scanButtonText,
    required this.retryLabel,
    required this.pickAnotherImageLabel,
    required this.resetLabel,
    required this.scanAnotherLabel,
    required this.saveReceiptLabel,
    required this.editBeforeSaveLabel,
    required this.savingLabel,
    required this.lowConfidenceWarningLabel,
    required this.successTitle,
    required this.errorTitle,
    required this.errorFallback,
    required this.loadingSteps,
    required this.merchantLabel,
    required this.totalLabel,
    required this.dateLabel,
    required this.categoryLabel,
    required this.itemsLabel,
    required this.confidenceLabel,
    required this.uploadTitle,
    required this.uploadSubtitle,
    required this.cameraTitle,
    required this.cameraSubtitle,
    required this.supportFormatsText,
    required this.cancelLabel,
    required this.scanningLabel,
  });

  final ScanViewState state;
  final String? imagePath;
  final List<String> imagePaths;
  final int loadingStep;
  final String? errorMessage;
  final ReceiptModel? result;
  final bool hasDraft;
  final bool lowConfidence;
  final bool savingDraft;
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final VoidCallback onAddPage;
  final void Function(int index) onRemoveImage;
  final VoidCallback onScan;
  final VoidCallback onCancelScan;
  final VoidCallback onRetry;
  final VoidCallback onReset;
  final VoidCallback onScanAnother;
  final VoidCallback onEditDraft;
  final VoidCallback onSaveDraft;
  final String scanButtonText;
  final String retryLabel;
  final String pickAnotherImageLabel;
  final String resetLabel;
  final String scanAnotherLabel;
  final String saveReceiptLabel;
  final String editBeforeSaveLabel;
  final String savingLabel;
  final String lowConfidenceWarningLabel;
  final String successTitle;
  final String errorTitle;
  final String errorFallback;
  final List<String> loadingSteps;
  final String merchantLabel;
  final String totalLabel;
  final String dateLabel;
  final String categoryLabel;
  final String itemsLabel;
  final String confidenceLabel;
  final String uploadTitle;
  final String uploadSubtitle;
  final String cameraTitle;
  final String cameraSubtitle;
  final String supportFormatsText;
  final String cancelLabel;
  final String scanningLabel;

  /// Normalised image paths list — prefers [imagePaths] when non-empty,
  /// falls back to wrapping the legacy [imagePath] single-value.
  List<String> get _resolvedImagePaths {
    if (imagePaths.isNotEmpty) return imagePaths;
    final p = imagePath;
    return p == null ? const <String>[] : <String>[p];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (state) {
      case ScanViewState.idle:
        return ScanIdleView(
          key: const ValueKey(ScanViewState.idle),
          onGallery: onGallery,
          onCamera: onCamera,
          uploadTitle: uploadTitle,
          uploadSubtitle: uploadSubtitle,
          cameraTitle: cameraTitle,
          cameraSubtitle: cameraSubtitle,
          supportFormatsText: supportFormatsText,
        );

      case ScanViewState.imageSelected:
        final paths = _resolvedImagePaths;
        return ScanImageSelectedView(
          key: ValueKey<String>('selected-${paths.join('|')}'),
          imagePaths: paths,
          onScan: onScan,
          onReset: onReset,
          onAddPage: onAddPage,
          onRemoveImage: onRemoveImage,
          scanButtonText: scanButtonText,
          resetLabel: resetLabel,
        );

      case ScanViewState.loading:
        return ScanLoadingView(
          key: const ValueKey(ScanViewState.loading),
          imagePath: imagePath,
          loadingStep: loadingStep,
          steps: loadingSteps,
          onCancel: onCancelScan,
          cancelLabel: cancelLabel,
          scanningLabel: scanningLabel,
        );

      case ScanViewState.success:
        return ScanSuccessView(
          key: ValueKey(result?.id),
          result: result,
          title: successTitle,
          hasDraft: hasDraft,
          lowConfidence: lowConfidence,
          lowConfidenceWarningLabel: lowConfidenceWarningLabel,
          savingDraft: savingDraft,
          savingLabel: savingLabel,
          saveReceiptLabel: saveReceiptLabel,
          editBeforeSaveLabel: editBeforeSaveLabel,
          onScanAnother: onScanAnother,
          onEditDraft: onEditDraft,
          onSaveDraft: onSaveDraft,
          scanAnotherLabel: scanAnotherLabel,
          merchantLabel: merchantLabel,
          totalLabel: totalLabel,
          dateLabel: dateLabel,
          categoryLabel: categoryLabel,
          itemsLabel: itemsLabel,
          confidenceLabel: confidenceLabel,
        );

      case ScanViewState.error:
        return ScanErrorView(
          key: const ValueKey(ScanViewState.error),
          title: errorTitle,
          message: errorMessage ?? errorFallback,
          onRetry: onRetry,
          retryLabel: retryLabel,
          onReset: onReset,
          resetLabel: pickAnotherImageLabel,
        );
    }
  }
}