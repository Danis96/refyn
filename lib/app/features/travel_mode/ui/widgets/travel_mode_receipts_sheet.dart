import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/app/widgets/receipt_paper_card.dart';
import 'package:refyn/theme/app_spacing.dart';

class TravelModeReceiptsSheet extends StatelessWidget {
  const TravelModeReceiptsSheet({
    super.key,
    required this.receipts,
    required this.tripCurrency,
    required this.onOpenReceipt,
  });

  final List<ReceiptModel> receipts;
  final String tripCurrency;
  final Future<void> Function(ReceiptModel receipt) onOpenReceipt;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final double maxSheetHeight = MediaQuery.sizeOf(context).height * 0.88;
    final double totalSpent = receipts.fold<double>(
      0,
      (double sum, ReceiptModel receipt) => sum + receipt.totals.total,
    );
    final String spentLabel = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    ).format(totalSpent).trim();

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Flexible(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  Color(0xFF1B1F4B),
                                  Color(0xFF3A2C66),
                                  Color(0xFFDE6834),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.flight_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        context.l10n.travelModeSheetTitle,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        context.l10n.travelModeSheetSubtitle(
                                          tripCurrency,
                                        ),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.white70,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _TripStatPill(
                                  label: context.l10n.travelModeSpentSoFar,
                                  value: '$spentLabel $tripCurrency',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _TripStatPill(
                                  label: context.l10n.travelModeSheetItems,
                                  value: context.l10n.travelModeReceiptCount(
                                    receipts.length,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            context.l10n.travelModeSheetHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (receipts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _TravelReceiptsEmptyState(
                        tripCurrency: tripCurrency,
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: ReceiptPaperList(
                          receipts: receipts,
                          onOpenReceipt: onOpenReceipt,
                          heroTagBuilder: (ReceiptModel receipt) =>
                              'receipt-hero-travel-${receipt.id}',
                          enableEntranceAnimation: true,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripStatPill extends StatelessWidget {
  const _TripStatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelReceiptsEmptyState extends StatelessWidget {
  const _TravelReceiptsEmptyState({required this.tripCurrency});

  final String tripCurrency;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 34,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.travelModeSheetEmptyTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.travelModeSheetEmptySubtitle(tripCurrency),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
