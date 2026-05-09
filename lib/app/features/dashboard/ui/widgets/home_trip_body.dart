import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/features/dashboard/action_utils/dashboard_action_utils.dart';
import 'package:refyn/app/features/dashboard/ui/widgets/home_card_empty_state.dart';
import 'package:refyn/app/features/dashboard/ui/widgets/home_quick_actions_rows.dart';
import 'package:refyn/app/features/dashboard/ui/widgets/trip_info_card.dart';
import 'package:refyn/app/features/travel_mode/action_utils/travel_mode_action_utils.dart';
import 'package:refyn/app/features/travel_mode/controllers/travel_mode_controller.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/app/widgets/receipt_paper_card.dart';
import 'package:refyn/routing/app_router.dart';
import 'package:refyn/theme/app_spacing.dart';

class HomeTripBody extends StatefulWidget {
  const HomeTripBody({super.key});

  @override
  State<HomeTripBody> createState() => _HomeTripBodyState();
}

class _HomeTripBodyState extends State<HomeTripBody> {
  late Future<List<ReceiptModel>> _receiptsFuture;
  int? _lastReceiptCount;

  @override
  void initState() {
    super.initState();
    _receiptsFuture = context
        .read<TravelModeController>()
        .loadActiveTripReceipts();
  }

  @override
  Widget build(BuildContext context) {
    final TravelModeController travel = context.watch<TravelModeController>();
    final int count = travel.tripReceiptCount;
    if (_lastReceiptCount != null && _lastReceiptCount != count) {
      _receiptsFuture = travel.loadActiveTripReceipts();
    }
    _lastReceiptCount = count;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          HomeQuickActionsRow(
            onScanReceipt: () => DashboardActionUtils.onScanReceipt(context),
            onUploadReceipt: () =>
                DashboardActionUtils.onUploadReceipt(context),
          ),
          const SizedBox(height: AppSpacing.md),
          const TripInfoCard(),
          const SizedBox(height: AppSpacing.md),
          _TripRecentReceiptsCard(future: _receiptsFuture),
        ],
      ),
    );
  }
}

class _TripRecentReceiptsCard extends StatelessWidget {
  const _TripRecentReceiptsCard({required this.future});

  final Future<List<ReceiptModel>> future;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        border: Border.all(color: HomeThemePalette.cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                context.l10n.travelModeSheetTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => TravelModeActionUtils.showTripReceipts(context),
                child: Text(
                  context.l10n.viewAll,
                  style: theme.textTheme.titleSmall!.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<List<ReceiptModel>>(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<List<ReceiptModel>> snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              final List<ReceiptModel> receipts = snap.data ?? const <ReceiptModel>[];
              if (receipts.isEmpty) {
                final String code = context
                    .read<TravelModeController>()
                    .tripCurrency ?? '';
                return HomeCardEmptyState(
                  imageCategory: 'miscellaneous',
                  title: context.l10n.travelModeSheetEmptyTitle,
                  message: context.l10n.travelModeSheetEmptySubtitle(code),
                );
              }
              final List<ReceiptModel> top = receipts.take(5).toList(growable: false);
              return ReceiptPaperList(
                receipts: top,
                heroTagBuilder: (ReceiptModel receipt) =>
                    AppRouter.receiptHeroTag('travel-home', receipt.id),
                onOpenReceipt: (ReceiptModel receipt) async {
                  await DashboardActionUtils.onOpenReceipt(context, receipt);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
