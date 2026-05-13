import 'package:flutter/material.dart';
import 'package:refyn/app/features/scan/controllers/scan_controller.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/theme/app_spacing.dart';
import 'add_page_tile.dart';
import 'receipt_page_tile.dart';

class ScanImageSelectedView extends StatelessWidget {
  const ScanImageSelectedView({
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
    if (imagePaths.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final canAddMore = imagePaths.length < ScanController.maxImageCount;
    final total = imagePaths.length;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
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
                    children: [
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
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: imagePaths.length + (canAddMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  if (index < imagePaths.length) {
                    return ReceiptPageTile(
                      imagePath: imagePaths[index],
                      pageIndex: index + 1,
                      pageTotal: total,
                      onRemove: () => onRemoveImage(index),
                    );
                  }
                  return AddPageTile(onTap: onAddPage);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: cs.tertiary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.tertiary.withValues(alpha: 0.25)),
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
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
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