import 'package:flutter/material.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/theme/app_spacing.dart';
import 'dash_rounded_border_painter.dart';
import 'upload_decor_circle.dart';

class ScanIdleView extends StatelessWidget {
  const ScanIdleView({
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onGallery,
          child: CustomPaint(
            painter: DashedRoundedBorderPainter(
              color: cs.secondary.withValues(alpha: 0.45),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  const UploadDecorCircle(
                    alignment: Alignment.bottomLeft,
                    size: 108,
                    offset: Offset(-30, 28),
                  ),
                  const UploadDecorCircle(
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
                              color: cs.secondary.withValues(alpha: 0.16),
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
                              color: cs.secondary,
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
                color: cs.secondary.withValues(alpha: 0.26),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: cs.secondary.withValues(alpha: 0.12),
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
                          color: cs.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.arrow_forward, color: cs.secondary),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: cs.tertiary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.tertiary.withValues(alpha: 0.22)),
          ),
          child: Text(
            context.l10n.scanLongReceiptHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.78),
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
              color: cs.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}