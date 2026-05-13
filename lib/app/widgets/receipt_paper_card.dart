import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/models/receipt/receipt_item_model.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/theme/app_spacing.dart';

class ReceiptPaperList extends StatefulWidget {
  const ReceiptPaperList({
    super.key,
    required this.receipts,
    this.onOpenReceipt,
    this.heroTagBuilder,
    this.enableEntranceAnimation = false,
    this.expandFirstByDefault = true,
  });

  final List<ReceiptModel> receipts;
  final Future<void> Function(ReceiptModel receipt)? onOpenReceipt;
  final String? Function(ReceiptModel receipt)? heroTagBuilder;
  final bool enableEntranceAnimation;
  final bool expandFirstByDefault;

  @override
  State<ReceiptPaperList> createState() => _ReceiptPaperListState();
}

class _ReceiptPaperListState extends State<ReceiptPaperList> {
  static const int _collapsedItemLimit = 12;

  late Set<String> _expandedReceiptIds;
  late Set<String> _expandedItemReceiptIds;

  @override
  void initState() {
    super.initState();
    _expandedReceiptIds = <String>{
      if (widget.expandFirstByDefault && widget.receipts.isNotEmpty)
        widget.receipts.first.id,
    };
    _expandedItemReceiptIds = <String>{};
  }

  @override
  void didUpdateWidget(covariant ReceiptPaperList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.receipts != widget.receipts) {
      _expandedReceiptIds = _expandedReceiptIds
          .where(
            (String id) =>
                widget.receipts.any((ReceiptModel item) => item.id == id),
          )
          .toSet();
      _expandedItemReceiptIds = _expandedItemReceiptIds
          .where(
            (String id) =>
                widget.receipts.any((ReceiptModel item) => item.id == id),
          )
          .toSet();
      if (widget.expandFirstByDefault &&
          _expandedReceiptIds.isEmpty &&
          widget.receipts.isNotEmpty) {
        _expandedReceiptIds.add(widget.receipts.first.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.receipts.asMap().entries.map((
        MapEntry<int, ReceiptModel> entry,
      ) {
        final int index = entry.key;
        final ReceiptModel receipt = entry.value;
        final bool expanded = _expandedReceiptIds.contains(receipt.id);
        final bool showAllItems = _expandedItemReceiptIds.contains(receipt.id);

        final Widget card = Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ReceiptPaperCard(
            receipt: receipt,
            expanded: expanded,
            collapsedItemLimit: _collapsedItemLimit,
            showAllItems: showAllItems,
            heroTag: widget.heroTagBuilder?.call(receipt),
            onOpen: widget.onOpenReceipt == null
                ? null
                : () => widget.onOpenReceipt!(receipt),
            onToggleExpanded: () {
              setState(() {
                if (expanded) {
                  _expandedReceiptIds.remove(receipt.id);
                  _expandedItemReceiptIds.remove(receipt.id);
                } else {
                  _expandedReceiptIds.add(receipt.id);
                }
              });
            },
            onToggleItems: () {
              setState(() {
                if (showAllItems) {
                  _expandedItemReceiptIds.remove(receipt.id);
                } else {
                  _expandedItemReceiptIds.add(receipt.id);
                }
              });
            },
          ),
        );

        if (!widget.enableEntranceAnimation) {
          return card;
        }

        return TweenAnimationBuilder<double>(
          key: ValueKey<String>('receipt-paper-${receipt.id}'),
          duration: Duration(milliseconds: 260 + (index * 55).clamp(0, 280)),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: 1),
          builder: (BuildContext context, double value, Widget? child) {
            return Transform.translate(
              offset: Offset(0, 22 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: card,
        );
      }).toList(),
    );
  }
}

class ReceiptPaperCard extends StatelessWidget {
  const ReceiptPaperCard({
    super.key,
    required this.receipt,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onToggleItems,
    required this.collapsedItemLimit,
    required this.showAllItems,
    this.onOpen,
    this.heroTag,
  });

  final ReceiptModel receipt;
  final bool expanded;
  final Future<void> Function()? onOpen;
  final VoidCallback onToggleExpanded;
  final VoidCallback onToggleItems;
  final int collapsedItemLimit;
  final bool showAllItems;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isTripReceipt = receipt.travelSessionId != null;
    final String merchant = receipt.merchant.name.trim().isEmpty
        ? context.l10n.receiptPaperStore.toUpperCase()
        : receipt.merchant.name.trim().toUpperCase();
    final int itemCount = receipt.items.length;
    final int quantityCount = receipt.items
        .fold<double>(
          0,
          (double sum, ReceiptItemModel item) => sum + item.quantity,
        )
        .round();
    final bool hasLongItemList = itemCount > collapsedItemLimit;
    final List<ReceiptItemModel> visibleItems =
        expanded && hasLongItemList && !showAllItems
        ? receipt.items.take(collapsedItemLimit).toList()
        : receipt.items;
    final int hiddenItemCount = itemCount - visibleItems.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen == null ? null : () => onOpen!(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: isTripReceipt
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      theme.colorScheme.surface,
                      const Color(0xFFFFF7E9),
                    ],
                  )
                : null,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: isTripReceipt
                    ? const Color(0xFFDE6834).withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: isTripReceipt ? 22 : 16,
                offset: Offset(0, isTripReceipt ? 10 : 6),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isTripReceipt
                    ? ReceiptPaperPalette.tripBorder(context)
                    : ReceiptPaperPalette.border(context),
              ),
            ),
            child: Stack(
              children: <Widget>[
                if (isTripReceipt)
                  Positioned(
                    left: 0,
                    top: 18,
                    bottom: 18,
                    child: Container(
                      width: 7,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(999),
                        ),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[Color(0xFFDE6834), Color(0xFFF2B35D)],
                        ),
                      ),
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ReceiptPerforation(isTripReceipt: isTripReceipt),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Column(
                        children: <Widget>[
                          if (isTripReceipt) ...<Widget>[
                            const _TripReceiptBadge(),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          heroTag == null
                              ? ReceiptPaperText.header(merchant)
                              : Hero(
                                  tag: heroTag!,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: ReceiptPaperText.header(merchant),
                                  ),
                                ),
                          const SizedBox(height: 4),
                          ReceiptPaperText.meta(
                            DateFormat(
                              'EEE, MMM d, yyyy',
                            ).format(receipt.createdAt),
                          ),
                          const SizedBox(height: 2),
                          ReceiptPaperText.meta(
                            DateFormat('hh:mm a').format(receipt.createdAt),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Divider(
                            color: isTripReceipt
                                ? ReceiptPaperPalette.tripBorder(context)
                                : ReceiptPaperPalette.border(context),
                            height: 1,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ReceiptTotalsRow(
                            label: context.l10n
                                .receiptPaperItemsLabel(itemCount)
                                .toUpperCase(),
                            value: '$quantityCount x',
                            emphasized: false,
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeInOutCubic,
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: expanded
                                  ? <Widget>[
                                      const SizedBox(height: AppSpacing.xs),
                                      ...visibleItems.map(
                                        (ReceiptItemModel item) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: ReceiptItemRow(
                                            item: item,
                                            currency: receipt.currency,
                                          ),
                                        ),
                                      ),
                                      if (hasLongItemList) ...<Widget>[
                                        const SizedBox(height: 2),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: TextButton(
                                            onPressed: onToggleItems,
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              foregroundColor: theme
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.56),
                                              textStyle:
                                                  ReceiptPaperText.buttonStyle(
                                                    context,
                                                  ),
                                            ),
                                            child: Text(
                                              showAllItems
                                                  ? context
                                                        .l10n
                                                        .receiptPaperShowLess
                                                        .toUpperCase()
                                                  : '${context.l10n.receiptPaperShowMore.toUpperCase()} ($hiddenItemCount)',
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: AppSpacing.xs),
                                      Divider(
                                        color: isTripReceipt
                                            ? ReceiptPaperPalette.tripBorder(
                                                context,
                                              )
                                            : ReceiptPaperPalette.border(
                                                context,
                                              ),
                                        height: 1,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      ReceiptTotalsRow(
                                        label:
                                            '${context.l10n.receiptPaperSubtotal.toUpperCase()}:',
                                        value:
                                            '${ReceiptPaperMoney.format(receipt.totals.subtotal ?? 0)} ${ReceiptPaperMoney.currencyLabel(receipt.currency)}',
                                        emphasized: false,
                                      ),
                                      const SizedBox(height: 4),
                                      ReceiptTotalsRow(
                                        label:
                                            '${context.l10n.receiptPaperTax.toUpperCase()}:',
                                        value:
                                            '${ReceiptPaperMoney.format(receipt.totals.vatAmount ?? 0)} ${ReceiptPaperMoney.currencyLabel(receipt.currency)}',
                                        emphasized: false,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                    ]
                                  : const <Widget>[
                                      SizedBox(height: AppSpacing.xs),
                                    ],
                            ),
                          ),
                          Divider(
                            color: isTripReceipt
                                ? ReceiptPaperPalette.tripStrongRule(context)
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.72,
                                  ),
                            height: 1,
                            thickness: 1.4,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ReceiptTotalsRow(
                            label:
                                '${context.l10n.receiptPaperTotal.toUpperCase()}:',
                            value:
                                '${ReceiptPaperMoney.format(receipt.totals.total)} ${ReceiptPaperMoney.currencyLabel(receipt.currency)}',
                            emphasized: true,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: <Widget>[
                              ReceiptConfidencePill(
                                confidence: receipt.confidence,
                              ),
                              if (isTripReceipt) const _TripScanStamp(),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: onToggleExpanded,
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.52),
                              textStyle: ReceiptPaperText.buttonStyle(context),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 200),
                                  crossFadeState: expanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  firstChild: Text(
                                    context.l10n.receiptPaperShowMore
                                        .toUpperCase(),
                                    style: ReceiptPaperText.buttonStyle(context)
                                        .copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.52),
                                        ),
                                  ),
                                  secondChild: Text(
                                    context.l10n.receiptPaperShowLess
                                        .toUpperCase(),
                                    style: ReceiptPaperText.buttonStyle(context)
                                        .copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.52),
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                AnimatedRotation(
                                  turns: expanded ? 0.5 : 0.0,
                                  duration: const Duration(milliseconds: 320),
                                  curve: Curves.easeInOutCubic,
                                  child: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeInOutCubic,
                            alignment: Alignment.topCenter,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 240),
                              opacity: expanded ? 1.0 : 0.0,
                              child: expanded
                                  ? Column(
                                      children: <Widget>[
                                        const SizedBox(height: AppSpacing.sm),
                                        Divider(
                                          color: isTripReceipt
                                              ? ReceiptPaperPalette.tripBorder(
                                                  context,
                                                )
                                              : ReceiptPaperPalette.border(
                                                  context,
                                                ),
                                          height: 1,
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        if (isTripReceipt) ...<Widget>[
                                          ReceiptPaperText.footer(
                                            context.l10n.receiptPaperTripReceipt
                                                .toUpperCase(),
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                        ReceiptPaperText.footer(
                                          context.l10n
                                              .receiptPaperReceiptIdLabel(
                                                receipt.id,
                                              )
                                              .toUpperCase(),
                                        ),
                                        const SizedBox(height: 4),
                                        ReceiptPaperText.footer(
                                          context.l10n.receiptPaperThankYou
                                              .toUpperCase(),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ReceiptPerforation(isTripReceipt: isTripReceipt),
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

class ReceiptPerforation extends StatelessWidget {
  const ReceiptPerforation({super.key, required this.isTripReceipt});

  final bool isTripReceipt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List<Widget>.generate(
          22,
          (int index) => Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTripReceipt
                  ? ReceiptPaperPalette.tripPerforation(context)
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.18),
            ),
          ),
        ),
      ),
    );
  }
}

class ReceiptItemRow extends StatelessWidget {
  const ReceiptItemRow({super.key, required this.item, required this.currency});

  final ReceiptItemModel item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final String quantityLabel = item.quantity % 1 == 0
        ? item.quantity.toStringAsFixed(0)
        : item.quantity.toStringAsFixed(2);
    final String name = item.name.trim().isEmpty
        ? context.l10n.item
        : item.name.trim();

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            '$quantityLabel x $name',
            style: ReceiptPaperText.item(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${ReceiptPaperMoney.format(item.finalPrice)} ${ReceiptPaperMoney.currencyLabel(currency)}',
          style: ReceiptPaperText.itemValue(context),
        ),
      ],
    );
  }
}

class ReceiptTotalsRow extends StatelessWidget {
  const ReceiptTotalsRow({
    super.key,
    required this.label,
    required this.value,
    required this.emphasized,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: emphasized
                ? ReceiptPaperText.total(context)
                : ReceiptPaperText.rowLabel(context),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: emphasized
              ? ReceiptPaperText.total(context)
              : ReceiptPaperText.rowValue(context),
        ),
      ],
    );
  }
}

class ReceiptConfidencePill extends StatelessWidget {
  const ReceiptConfidencePill({super.key, required this.confidence});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final int percent = confidence <= 1
        ? (confidence * 100).round().clamp(0, 100)
        : confidence.round().clamp(0, 100);
    final bool high = percent >= 95;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: high ? const Color(0xFFDDF5E3) : const Color(0xFFF9E9A8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        context.l10n.receiptPaperScanConfidenceLabel(percent),
        style: ReceiptPaperText.confidence(
          context,
          color: high ? const Color(0xFF2F9B53) : const Color(0xFFBE8A14),
        ),
      ),
    );
  }
}

class _TripReceiptBadge extends StatelessWidget {
  const _TripReceiptBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE7D1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFFDE6834).withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.luggage_rounded,
              size: 14,
              color: Color(0xFFB45309),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripScanStamp extends StatelessWidget {
  const _TripScanStamp();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.06,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFFDE6834).withValues(alpha: 0.6),
            width: 1.4,
          ),
        ),
        child: Text(
          context.l10n.receiptPaperScannedOnTrip.toUpperCase(),
          style: ReceiptPaperText.confidence(
            context,
            color: const Color(0xFFDE6834),
          ),
        ),
      ),
    );
  }
}

class ReceiptPaperText extends StatelessWidget {
  const ReceiptPaperText._({
    required this.text,
    required this.textAlign,
    required this.style,
  });

  final String text;
  final TextAlign textAlign;
  final TextStyle? style;

  const ReceiptPaperText.header(String text)
    : this._(text: text, textAlign: TextAlign.center, style: null);
  const ReceiptPaperText.meta(String text)
    : this._(text: text, textAlign: TextAlign.center, style: null);
  const ReceiptPaperText.muted(String text)
    : this._(text: text, textAlign: TextAlign.left, style: null);
  const ReceiptPaperText.footer(String text)
    : this._(text: text, textAlign: TextAlign.center, style: null);

  @override
  Widget build(BuildContext context) {
    TextStyle? resolvedStyle = style;
    if (resolvedStyle == null) {
      final String store = context.l10n.receiptPaperStore.toUpperCase();
      final String receiptId = context.l10n.receiptPaperReceiptId.toUpperCase();
      final String thankYou = context.l10n.receiptPaperThankYou.toUpperCase();

      if (textAlign == TextAlign.center && text.contains(store)) {
        resolvedStyle = headerStyle(context);
      } else if (textAlign == TextAlign.center && text.contains(receiptId)) {
        resolvedStyle = footerStyle(context);
      } else if (textAlign == TextAlign.center && text == thankYou) {
        resolvedStyle = footerStyle(context);
      } else if (textAlign == TextAlign.center) {
        resolvedStyle = metaStyle(context);
      } else {
        resolvedStyle = mutedStyle(context);
      }
    }

    return Text(text, textAlign: textAlign, style: resolvedStyle);
  }

  static TextStyle base(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontFamily: 'monospace',
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.88),
    );
  }

  static TextStyle headerStyle(BuildContext context) {
    return base(context).copyWith(
      fontSize: 22,
      height: 1.0,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.1,
    );
  }

  static TextStyle metaStyle(BuildContext context) {
    return base(context).copyWith(
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
    );
  }

  static TextStyle mutedStyle(BuildContext context) {
    return base(context).copyWith(
      fontSize: 12,
      height: 1.2,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
    );
  }

  static TextStyle footerStyle(BuildContext context) {
    return base(context).copyWith(
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.9,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.42),
    );
  }

  static TextStyle item(BuildContext context) {
    return base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w700);
  }

  static TextStyle itemValue(BuildContext context) {
    return base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800);
  }

  static TextStyle rowLabel(BuildContext context) {
    return base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800);
  }

  static TextStyle rowValue(BuildContext context) {
    return base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800);
  }

  static TextStyle total(BuildContext context) {
    return base(context).copyWith(
      fontSize: 19,
      height: 1.0,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
    );
  }

  static TextStyle confidence(BuildContext context, {required Color color}) {
    return base(context).copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.8,
      color: color,
    );
  }

  static TextStyle buttonStyle(BuildContext context) {
    return base(
      context,
    ).copyWith(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8);
  }
}

class ReceiptPaperMoney {
  const ReceiptPaperMoney._();

  static String format(double value) {
    return NumberFormat('0.00').format(value);
  }

  static String currencyLabel(String currency) {
    return currency;
  }
}

class ReceiptPaperPalette {
  const ReceiptPaperPalette._();

  static bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color border(BuildContext context) {
    return Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: _dark(context) ? 0.18 : 0.08);
  }

  static Color tripBorder(BuildContext context) {
    return const Color(
      0xFFDE6834,
    ).withValues(alpha: _dark(context) ? 0.42 : 0.22);
  }

  static Color tripStrongRule(BuildContext context) {
    return const Color(
      0xFFB45309,
    ).withValues(alpha: _dark(context) ? 0.72 : 0.86);
  }

  static Color tripPerforation(BuildContext context) {
    return const Color(
      0xFFDE6834,
    ).withValues(alpha: _dark(context) ? 0.48 : 0.28);
  }
}
