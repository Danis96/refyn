import 'package:flutter/material.dart';
import 'package:refyn/app/features/export/repository/receipt_export_service.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/features/receipt_details/ui/widgets/receipt_action_toolbar.dart';
import 'package:refyn/app/features/receipt_details/ui/widgets/receipt_items_card.dart';
import 'package:refyn/app/features/receipt_details/ui/widgets/receipt_overview_card.dart';
import 'package:refyn/app/features/receipt_details/ui/widgets/receipt_payment_summary.dart';
import 'package:refyn/app/features/receipt_details/ui/widgets/receipt_top_bar.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';

class ReceiptDetailsScaffold extends StatelessWidget {
  const ReceiptDetailsScaffold({
    super.key,
    required this.receipt,
    required this.deleting,
    required this.exporting,
    required this.onViewImage,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
    required this.onExportSelected,
    required this.onEditItemCategory,
  });

  final ReceiptModel receipt;
  final bool deleting;
  final bool exporting;
  final VoidCallback onViewImage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final Future<void> Function(ReceiptExportFormat format) onExportSelected;
  final Future<void> Function(int itemIndex) onEditItemCategory;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      children: <Widget>[
        const ReceiptTopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              18,
              16,
              28 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: <Widget>[
                ReceiptActionToolbar(
                  hasImage:
                      receipt.imagePath != null &&
                      receipt.imagePath!.trim().isNotEmpty,
                  deleting: deleting,
                  exporting: exporting,
                  onViewImage: onViewImage,
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onShare: onShare,
                  onExportSelected: onExportSelected,
                ),
                if (receipt.travelSessionId != null) ...<Widget>[
                  const SizedBox(height: 16),
                  const _TripReceiptBanner(),
                ],
                const SizedBox(height: 22),
                ReceiptOverviewCard(receipt: receipt),
                const SizedBox(height: 16),
                ReceiptItemsCard(
                  receipt: receipt,
                  onEditItemCategory: onEditItemCategory,
                ),
                const SizedBox(height: 16),
                ReceiptPaymentSummaryCard(receipt: receipt),
                const SizedBox(height: 24),
                Text(
                  context.l10n.keepReceiptForRecords,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TripReceiptBanner extends StatelessWidget {
  const _TripReceiptBanner();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final List<Color> gradientColors = isDark
        ? <Color>[
            const Color(0xFF2A1E1A),
            const Color(0xFF3B281D),
            const Color(0xFF5A351E),
          ]
        : <Color>[const Color(0xFFFFF4E7), colorScheme.surface];
    final Color borderColor = isDark
        ? const Color(0xFFF2B35D).withValues(alpha: 0.28)
        : const Color(0xFFDE6834).withValues(alpha: 0.22);
    final Color iconBackground = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFDE6834).withValues(alpha: 0.12);
    final Color accentColor = isDark
        ? const Color(0xFFF2B35D)
        : const Color(0xFFB45309);
    final Color secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.78)
        : colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFFDE6834).withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.luggage_rounded, size: 18, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.travelModeActiveLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.travelModeSheetTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
