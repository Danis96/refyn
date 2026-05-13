import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/theme/app_colors.dart';
import 'package:refyn/theme/app_spacing.dart';
import 'scan_success_row.dart';

class ScanSuccessView extends StatelessWidget {
  const ScanSuccessView({
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
    final receipt = result;
    if (receipt == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final successColor = AppColors.success;
    final String localeTag = Localizations.localeOf(context).toLanguageTag();
    final DateFormat dateFormat = DateFormat.yMd(localeTag);

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
                  style: theme.textTheme.titleLarge?.copyWith(
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
                color: cs.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: cs.secondary.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                lowConfidenceWarningLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          ScanSuccessRow(label: merchantLabel, value: receipt.merchant.name),
          ScanSuccessRow(
            label: totalLabel,
            value:
            '${receipt.totals.total.toStringAsFixed(2)} ${receipt.currency}',
          ),
          ScanSuccessRow(
            label: dateLabel,
            value: dateFormat.format(receipt.createdAt),
          ),
          ScanSuccessRow(
            label: itemsLabel,
            value: '${receipt.items.length}',
          ),
          ScanSuccessRow(
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