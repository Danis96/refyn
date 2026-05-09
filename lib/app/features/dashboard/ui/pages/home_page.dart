import 'package:flutter/material.dart';
import 'package:wiggly_loaders/wiggly_loaders.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/features/dashboard/action_utils/dashboard_action_utils.dart';
import 'package:refyn/app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:refyn/app/features/dashboard/repository/dashboard_budget_progress_model.dart';
import 'package:refyn/app/features/dashboard/repository/home_dashboard_model.dart';
import 'package:refyn/app/features/dashboard/ui/widgets/home_recent_receipts_card.dart';
import 'package:refyn/app/features/dashboard/ui/widgets/home_summary_hero.dart';
import 'package:refyn/app/features/dashboard/ui/widgets/home_trip_body.dart';
import 'package:refyn/app/features/dashboard/ui/widgets/home_view_mode_switcher.dart';
import 'package:refyn/app/features/dashboard/ui/widgets/trip_summary_hero.dart';
import 'package:refyn/app/features/travel_mode/controllers/travel_mode_controller.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/theme/app_spacing.dart';

import '../widgets/home_category_budget_cards.dart';
import '../widgets/home_quick_actions_rows.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeViewMode _mode = HomeViewMode.home;
  bool _wasTravelActive = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder:
          (
            BuildContext context,
            DashboardController controller,
            Widget? child,
          ) {
            if (controller.isLoading && controller.homeData == null) {
              return const SafeArea(
                child: Center(child: WigglyLoader.indeterminate()),
              );
            }

            if (controller.errorMessage != null &&
                controller.homeData == null) {
              return SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        controller.errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: controller.refreshHome,
                        child: Text(context.l10n.retryHome),
                      ),
                    ],
                  ),
                ),
              );
            }

            final HomeDashboardModel data =
                controller.homeData ??
                const HomeDashboardModel(
                  totalReceipts: 0,
                  thisMonthReceipts: 0,
                  thisMonthSpending: 0,
                  totalBudget: 0,
                  remainingBudget: 0,
                  currency: 'BAM',
                  topCategoryLabel: 'No spending',
                  budgetProgress: <DashboardBudgetProgressModel>[],
                  recentReceipts: <ReceiptModel>[],
                );

            final bool travelActive = context
                .watch<TravelModeController>()
                .isActive;

            // Reset to home view whenever travel mode flips off; jump to trip
            // the first time it turns on so the switch is discoverable.
            if (travelActive != _wasTravelActive) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  if (!travelActive) {
                    _mode = HomeViewMode.home;
                  }
                  _wasTravelActive = travelActive;
                });
              });
            }

            return WigglyRefreshIndicator(
              onRefresh: () async {
                final TravelModeController travel = context
                    .read<TravelModeController>();
                await controller.refreshHome();
                await travel.refresh();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _AnimatedHero(mode: _mode, data: data),
                    if (travelActive)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          0,
                        ),
                        child: HomeViewModeSwitcher(
                          mode: _mode,
                          homeLabel: context.l10n.homeViewSwitcherHome,
                          tripLabel: context.l10n.homeViewSwitcherTrip,
                          onChanged: (HomeViewMode m) {
                            if (m == _mode) return;
                            setState(() => _mode = m);
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: _AnimatedBody(
                        mode: travelActive ? _mode : HomeViewMode.home,
                        data: data,
                        controller: controller,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }
}

const Duration _kSwapDuration = Duration(milliseconds: 420);
const Curve _kSwapCurve = Curves.easeInOutCubicEmphasized;

class _AnimatedHero extends StatelessWidget {
  const _AnimatedHero({required this.mode, required this.data});

  final HomeViewMode mode;
  final HomeDashboardModel data;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(24),
      ),
      child: AnimatedCrossFade(
        duration: _kSwapDuration,
        sizeCurve: _kSwapCurve,
        firstCurve: Curves.easeOut,
        secondCurve: Curves.easeOut,
        alignment: Alignment.topCenter,
        crossFadeState: mode == HomeViewMode.home
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        firstChild: HomeSummaryHero(data: data),
        secondChild: const TripSummaryHero(),
      ),
    );
  }
}

class _AnimatedBody extends StatelessWidget {
  const _AnimatedBody({
    required this.mode,
    required this.data,
    required this.controller,
  });

  final HomeViewMode mode;
  final HomeDashboardModel data;
  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSize(
        duration: _kSwapDuration,
        curve: _kSwapCurve,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: _kSwapDuration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final bool incomingTrip =
                (child.key as ValueKey<String>?)?.value == 'trip-body';
            final Offset begin = incomingTrip
                ? const Offset(0.12, 0)
                : const Offset(-0.12, 0);
            final Animation<Offset> slide = Tween<Offset>(
              begin: begin,
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
            final Animation<double> scale = Tween<double>(
              begin: 0.97,
              end: 1.0,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slide,
                child: ScaleTransition(scale: scale, child: child),
              ),
            );
          },
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ...previousChildren,
                ?currentChild,
              ],
            );
          },
          child: mode == HomeViewMode.home
              ? KeyedSubtree(
                  key: const ValueKey<String>('home-body'),
                  child: _HomeBody(data: data, controller: controller),
                )
              : const KeyedSubtree(
                  key: ValueKey<String>('trip-body'),
                  child: HomeTripBody(),
                ),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.data, required this.controller});

  final HomeDashboardModel data;
  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
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
          HomeCategoryBudgetsCard(
            data: data,
            onOpenCategory: (String category) =>
                DashboardActionUtils.onBudgetCategoryPressed(
                  context,
                  category: category,
                ),
            onManageBudgets: () => DashboardActionUtils.onManageBudgets(
              context,
              budgetProgress: data.budgetProgress,
              supportedCategories: controller.supportedBudgetCategories,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          HomeRecentReceiptsCard(
            data: data,
            onViewAll: () =>
                DashboardActionUtils.onTabSelected(context, 2),
            onOpenReceipt: (ReceiptModel receipt) =>
                DashboardActionUtils.onOpenReceipt(context, receipt),
          ),
        ],
      ),
    );
  }
}
