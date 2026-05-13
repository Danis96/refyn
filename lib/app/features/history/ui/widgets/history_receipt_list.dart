import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/features/budgets/repository/category_budget_catalog.dart';
import 'package:refyn/app/features/history/controllers/history_controller.dart';
import 'package:refyn/app/features/history/controllers/history_receipt_list_entry.dart';
import 'package:refyn/app/features/history/ui/utils/history_ui_utils.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/app/widgets/category_asset_image.dart';
import 'package:refyn/theme/app_spacing.dart';
import 'package:refyn/theme/category_palette.dart';

class HistoryReceiptsList extends StatelessWidget {
  const HistoryReceiptsList({
    super.key,
    required this.viewMode,
    required this.entries,
    required this.receipts,
    required this.onOpenDetails,
  });

  final HistoryViewMode viewMode;
  final List<HistoryReceiptListEntry> entries;
  final List<ReceiptModel> receipts;
  final Future<void> Function(ReceiptModel receipt) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    if (viewMode == HistoryViewMode.receipts) {
      return Column(
        children: receipts
            .asMap()
            .entries
            .map(
              (MapEntry<int, ReceiptModel> entry) => HistoryReceiptSummaryCard(
                key: ValueKey<String>('receipt-${entry.value.id}'),
                receipt: entry.value,
                index: entry.key,
                onOpenDetails: onOpenDetails,
              ),
            )
            .toList(growable: false),
      );
    }

    return Column(
      children: entries
          .asMap()
          .entries
          .map(
            (MapEntry<int, HistoryReceiptListEntry> entry) =>
                HistoryReceiptListCard(
                  key: ValueKey<String>(entry.value.id),
                  entry: entry.value,
                  index: entry.key,
                  onOpenDetails: onOpenDetails,
                ),
          )
          .toList(growable: false),
    );
  }
}

class HistoryReceiptSummaryCard extends StatelessWidget {
  const HistoryReceiptSummaryCard({
    super.key,
    required this.receipt,
    required this.index,
    required this.onOpenDetails,
  });

  final ReceiptModel receipt;
  final int index;
  final Future<void> Function(ReceiptModel receipt) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = CategoryPalette.primaryFor(receipt.category, context);
    final String merchantName = receipt.merchant.name.trim().isEmpty
        ? context.l10n.unknownMerchant
        : receipt.merchant.name.trim();
    final String totalLabel =
        '${receipt.totals.total.toStringAsFixed(2)} ${receipt.currency}';
    final List<_HistoryReceiptPreviewItemData> previewItems = receipt.items
        .take(3)
        .map(
          (item) => _HistoryReceiptPreviewItemData(
            title: item.name.trim().isEmpty
                ? context.l10n.unnamedItem
                : item.name.trim(),
            amount: '${item.finalPrice.toStringAsFixed(2)} ${receipt.currency}',
          ),
        )
        .toList(growable: false);
    final int remainingItems = receipt.items.length - previewItems.length;
    final String dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(receipt.createdAt);
    final String categoryLabel = CategoryBudgetCatalog.labelFor(
      receipt.category,
    );

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 240 + (index * 45).clamp(0, 240)),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Material(
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onOpenDetails(receipt),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: HistoryThemePalette.border(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      HistoryItemCategoryBadge(
                                        category: receipt.category,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          merchantName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: -0.2,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    categoryLabel,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: accent,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _HistoryReceiptTotalPanel(
                              amount: totalLabel,
                              accent: accent,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _HistoryReceiptStatTile(
                                label: context.l10n.date,
                                value: dateLabel,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: _HistoryReceiptStatTile(
                                label: context.l10n.scanItems,
                                value: '${receipt.items.length}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _HistoryReceiptDivider(accent: accent),
                        const SizedBox(height: AppSpacing.md),
                        if (previewItems.isNotEmpty)
                          ...previewItems.asMap().entries.map(
                            (
                              MapEntry<int, _HistoryReceiptPreviewItemData>
                              entry,
                            ) => Padding(
                              padding: EdgeInsets.only(
                                bottom: entry.key == previewItems.length - 1
                                    ? 0
                                    : AppSpacing.xs,
                              ),
                              child: _HistoryReceiptPreviewRow(
                                item: entry.value,
                              ),
                            ),
                          ),
                        if (remainingItems > 0) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.add_circle_outline_rounded,
                                  size: 18,
                                  color: accent,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    '+$remainingItems more items',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: accent,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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

class HistoryReceiptListCard extends StatelessWidget {
  const HistoryReceiptListCard({
    super.key,
    required this.entry,
    required this.index,
    required this.onOpenDetails,
  });

  final HistoryReceiptListEntry entry;
  final int index;
  final Future<void> Function(ReceiptModel receipt) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String merchantName = entry.merchantName.trim().isEmpty
        ? context.l10n.unknownMerchant
        : entry.merchantName.trim();
    final String itemName = entry.itemName.trim().isEmpty
        ? context.l10n.unnamedItem
        : entry.itemName.trim();
    final String quantityLabel = entry.item.quantity % 1 == 0
        ? entry.item.quantity.toStringAsFixed(0)
        : entry.item.quantity.toStringAsFixed(2);
    final String priceLabel =
        '${entry.amount.toStringAsFixed(2)} ${entry.receipt.currency}';

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 220 + (index * 40).clamp(0, 240)),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onOpenDetails(entry.receipt),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: HistoryThemePalette.border(context)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            merchantName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            itemName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      priceLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      children: <Widget>[
                        HistoryReceiptMetaChip(
                          label: context.l10n.qtyLabel(quantityLabel),
                        ),
                        const SizedBox(width: 6),
                        HistoryReceiptMetaChip(
                          label: DateFormat.yMMMd(
                            Localizations.localeOf(context).toLanguageTag(),
                          ).format(entry.createdAt),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        HistoryItemCategoryBadge(category: entry.category),
                        const SizedBox(width: 6),
                        HistoryReceiptMetaChip(
                          label: CategoryBudgetCatalog.labelFor(
                            entry.category,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryReceiptPreviewItemData {
  const _HistoryReceiptPreviewItemData({
    required this.title,
    required this.amount,
  });

  final String title;
  final String amount;
}

class _HistoryReceiptTotalPanel extends StatelessWidget {
  const _HistoryReceiptTotalPanel({required this.amount, required this.accent});

  final String amount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            context.l10n.total.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryReceiptStatTile extends StatelessWidget {
  const _HistoryReceiptStatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HistoryThemePalette.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryReceiptDivider extends StatelessWidget {
  const _HistoryReceiptDivider({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(
        18,
        (int index) => Expanded(
          child: Container(
            height: 1,
            margin: EdgeInsets.only(right: index == 17 ? 0 : 4),
            color: index.isEven
                ? accent.withValues(alpha: 0.3)
                : accent.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }
}

class _HistoryReceiptPreviewRow extends StatelessWidget {
  const _HistoryReceiptPreviewRow({required this.item});

  final _HistoryReceiptPreviewItemData item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          item.amount,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class HistoryItemCategoryBadge extends StatelessWidget {
  const HistoryItemCategoryBadge({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CategoryPalette.surfaceFor(category, context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CategoryPalette.primaryFor(
            category,
            context,
          ).withValues(alpha: 0.22),
        ),
      ),
      child: CategoryAssetImage(category: category, size: 28),
    );
  }
}

class HistoryReceiptMetaChip extends StatelessWidget {
  const HistoryReceiptMetaChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
