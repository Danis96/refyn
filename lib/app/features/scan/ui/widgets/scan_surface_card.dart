import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/features/scan/controllers/scan_controller.dart';
import 'package:refyn/app/features/scan/ui/widgets/premium_scan_loading_panel.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/theme/app_colors.dart';
import 'package:refyn/theme/app_spacing.dart';

enum ScanSurfaceState { idle, imageSelected, loading, success, error }

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
  });

  final ScanSurfaceState state;
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

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final Animation<Offset> slide = Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (state) {
      case ScanSurfaceState.idle:
        return _IdleView(
          key: const ValueKey(ScanSurfaceState.idle),
          onGallery: onGallery,
          onCamera: onCamera,
          uploadTitle: uploadTitle,
          uploadSubtitle: uploadSubtitle,
          cameraTitle: cameraTitle,
          cameraSubtitle: cameraSubtitle,
          supportFormatsText: supportFormatsText,
        );
      case ScanSurfaceState.imageSelected:
        return _ImageSelectedView(
          key: ValueKey<String>(
            'selected-${imagePaths.isEmpty ? imagePath ?? '' : imagePaths.join('|')}',
          ),
          imagePaths: imagePaths.isNotEmpty
              ? imagePaths
              : (imagePath == null ? const <String>[] : <String>[imagePath!]),
          onScan: onScan,
          onReset: onReset,
          onAddPage: onAddPage,
          onRemoveImage: onRemoveImage,
          scanButtonText: scanButtonText,
          resetLabel: resetLabel,
        );
      case ScanSurfaceState.loading:
        return _LoadingView(
          key: const ValueKey(ScanSurfaceState.loading),
          imagePath: imagePath,
          loadingStep: loadingStep,
          steps: loadingSteps,
          onCancel: onCancelScan,
          cancelLabel: cancelLabel,
        );
      case ScanSurfaceState.success:
        return _SuccessView(
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
      case ScanSurfaceState.error:
        return _ErrorView(
          key: const ValueKey(ScanSurfaceState.error),
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

// --- View Widgets ---

class _IdleView extends StatelessWidget {
  const _IdleView({
    super.key,
    required this.onGallery,
    required this.onCamera,
    required this.uploadTitle,
    required this.uploadSubtitle,
    required this.cameraTitle,
    required this.cameraSubtitle,
    required this.supportFormatsText,
  });

  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final String uploadTitle;
  final String uploadSubtitle;
  final String cameraTitle;
  final String cameraSubtitle;
  final String supportFormatsText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestureDetector(
          onTap: onGallery,
          child: CustomPaint(
            painter: _DashedRoundedBorderPainter(
              color: colorScheme.secondary.withValues(alpha: 0.45),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  const _UploadDecorCircle(
                    alignment: Alignment.bottomLeft,
                    size: 108,
                    offset: Offset(-30, 28),
                  ),
                  const _UploadDecorCircle(
                    alignment: Alignment.topRight,
                    size: 108,
                    offset: Offset(30, -28),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 22,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withValues(
                                alpha: 0.16,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.upload_outlined, size: 34),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            uploadTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            uploadSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: onCamera,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.secondary.withValues(alpha: 0.26),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.camera_alt_outlined),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cameraTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        cameraSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.arrow_forward, color: colorScheme.secondary),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.tertiary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.tertiary.withValues(alpha: 0.22),
            ),
          ),
          child: Text(
            context.l10n.scanLongReceiptHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.78),
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Text(
            supportFormatsText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageSelectedView extends StatelessWidget {
  const _ImageSelectedView({
    super.key,
    required this.imagePaths,
    required this.onScan,
    required this.onReset,
    required this.onAddPage,
    required this.onRemoveImage,
    required this.scanButtonText,
    required this.resetLabel,
  });

  final List<String> imagePaths;
  final VoidCallback onScan;
  final VoidCallback onReset;
  final VoidCallback onAddPage;
  final void Function(int index) onRemoveImage;
  final String scanButtonText;
  final String resetLabel;

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      return const SizedBox.shrink();
    }
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool canAddMore = imagePaths.length < ScanController.maxImageCount;
    final int total = imagePaths.length;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Page count indicator
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.collections_outlined,
                        size: 14,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$total / ${ScanController.maxImageCount}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (!canAddMore)
                  Text(
                    context.l10n.scanImageLimitReached,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Horizontal thumbnail carousel
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: imagePaths.length + (canAddMore ? 1 : 0),
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (BuildContext context, int index) {
                  if (index < imagePaths.length) {
                    return _ReceiptPageTile(
                      imagePath: imagePaths[index],
                      pageIndex: index + 1,
                      pageTotal: total,
                      onRemove: () => onRemoveImage(index),
                    );
                  }
                  return _AddPageTile(onTap: onAddPage);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Hint banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: cs.tertiary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.tertiary.withValues(alpha: 0.25)),
              ),
              child: Expanded(
                child: Text(
                  context.l10n.scanLongReceiptHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: onScan,
                    child: Text(scanButtonText),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: onReset,
                    child: Text(resetLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptPageTile extends StatelessWidget {
  const _ReceiptPageTile({
    required this.imagePath,
    required this.pageIndex,
    required this.pageTotal,
    required this.onRemove,
  });

  final String imagePath;
  final int pageIndex;
  final int pageTotal;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return SizedBox(
      width: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // Image card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) => Container(
                          color: cs.surfaceContainerHighest,
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 36),
                          ),
                        ),
                  ),
                  // Subtle bottom gradient for badge readability
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Page badge
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        context.l10n.scanPageBadge(pageIndex, pageTotal),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Remove button — floating
          Positioned(
            top: -6,
            right: -6,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPageTile extends StatelessWidget {
  const _AddPageTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    return SizedBox(
      width: 150,
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedRoundedBorderPainter(
            color: cs.primary.withValues(alpha: 0.55),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: cs.primary.withValues(alpha: 0.04),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_rounded, size: 26, color: cs.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.scanAddPage,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      context.l10n.scanAddPageHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({
    super.key,
    required this.imagePath,
    required this.loadingStep,
    required this.steps,
    required this.onCancel,
    required this.cancelLabel,
  });

  final String? imagePath;
  final int loadingStep;
  final List<String> steps;
  final VoidCallback onCancel;
  final String cancelLabel;

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
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    super.key,
    required this.result,
    required this.title,
    required this.hasDraft,
    required this.lowConfidence,
    required this.lowConfidenceWarningLabel,
    required this.savingDraft,
    required this.savingLabel,
    required this.saveReceiptLabel,
    required this.editBeforeSaveLabel,
    required this.onScanAnother,
    required this.onEditDraft,
    required this.onSaveDraft,
    required this.scanAnotherLabel,
    required this.merchantLabel,
    required this.totalLabel,
    required this.dateLabel,
    required this.categoryLabel,
    required this.itemsLabel,
    required this.confidenceLabel,
  });

  final ReceiptModel? result;
  final String title;
  final bool hasDraft;
  final bool lowConfidence;
  final String lowConfidenceWarningLabel;
  final bool savingDraft;
  final String savingLabel;
  final String saveReceiptLabel;
  final String editBeforeSaveLabel;
  final VoidCallback onScanAnother;
  final VoidCallback onEditDraft;
  final VoidCallback onSaveDraft;
  final String scanAnotherLabel;
  final String merchantLabel;
  final String totalLabel;
  final String dateLabel;
  final String categoryLabel;
  final String itemsLabel;
  final String confidenceLabel;

  @override
  Widget build(BuildContext context) {
    final ReceiptModel? receipt = result;
    if (receipt == null) {
      return const SizedBox.shrink();
    }

    final DateFormat dateFormat = DateFormat('M/d/yyyy');
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color successColor = AppColors.success;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: successColor.withValues(alpha: 0.55),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: successColor),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: successColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (lowConfidence) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                lowConfidenceWarningLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _ScanSuccessRow(label: merchantLabel, value: receipt.merchant.name),
          _ScanSuccessRow(
            label: totalLabel,
            value:
                '${receipt.totals.total.toStringAsFixed(2)} ${receipt.currency}',
          ),
          _ScanSuccessRow(
            label: dateLabel,
            value: dateFormat.format(receipt.createdAt),
          ),
          _ScanSuccessRow(label: itemsLabel, value: '${receipt.items.length}'),
          _ScanSuccessRow(
            label: confidenceLabel,
            value: '${(receipt.confidence * 100).round()}%',
          ),
          const SizedBox(height: AppSpacing.md),
          if (hasDraft)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: savingDraft ? null : onSaveDraft,
                    child: Text(savingDraft ? savingLabel : saveReceiptLabel),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: savingDraft ? null : onEditDraft,
                    child: Text(context.l10n.edit),
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onScanAnother,
              child: Text(scanAnotherLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    required this.retryLabel,
    required this.onReset,
    required this.resetLabel,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;
  final VoidCallback onReset;
  final String resetLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color errorColor = colorScheme.error;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: errorColor.withValues(alpha: 0.55),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: errorColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: errorColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(message),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: Text(retryLabel),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: onReset,
                  child: Text(resetLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Helper Widgets ---

class _ScanSuccessRow extends StatelessWidget {
  const _ScanSuccessRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium!.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadDecorCircle extends StatelessWidget {
  const _UploadDecorCircle({
    required this.alignment,
    required this.size,
    this.offset = Offset.zero,
  });

  final Alignment alignment;
  final double size;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const double radius = 18;
    const double dashWidth = 7;
    const double dashSpace = 5;
    const double strokeWidth = 1.3;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dashWidth).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
