import 'package:flutter/material.dart';
import 'package:wiggly_loaders/wiggly_loaders.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/features/history/action_utils/history_action_utils.dart';
import 'package:refyn/app/features/history/controllers/history_controller.dart';
import 'package:refyn/app/features/history/ui/widgets/history_category_chips.dart';
import 'package:refyn/app/features/history/ui/widgets/history_empty_state.dart';
import 'package:refyn/app/features/history/ui/widgets/history_search_bar.dart';
import 'package:refyn/app/features/history/ui/widgets/history_sort_filter_row.dart';
import 'package:refyn/theme/app_spacing.dart';

import '../widgets/history_receipt_list.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const double _loadMoreThreshold = 280;

  final ScrollController _scrollController = ScrollController();
  bool _loadMoreScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || _loadMoreScheduled) {
      return;
    }

    final HistoryController controller = context.read<HistoryController>();
    final bool hasMore = controller.viewMode == HistoryViewMode.items
        ? controller.hasMoreHistoryEntries
        : controller.hasMoreFilteredReceipts;

    if (!hasMore || controller.isLoading || controller.isLoadingMore) {
      return;
    }

    if (_scrollController.position.extentAfter > _loadMoreThreshold) {
      return;
    }

    _loadMoreScheduled = true;
    HistoryActionUtils.onLoadMorePressed(context).whenComplete(() {
      if (mounted) {
        _loadMoreScheduled = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryController>(
      builder: (BuildContext context, HistoryController controller, _) {
        final ThemeData theme = Theme.of(context);
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              context.l10n.history,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          _HistoryViewModeButton(
                            viewMode: controller.viewMode,
                            onPressed: () =>
                                HistoryActionUtils.onViewModeChanged(
                                  context,
                                  controller.viewMode == HistoryViewMode.items
                                      ? HistoryViewMode.receipts
                                      : HistoryViewMode.items,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        context.l10n.historyTotalsLabel(
                          controller.totalItemCount,
                          controller.totalReceiptCount,
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      HistorySearchBar(
                        initialValue: controller.searchQuery,
                        onChanged: (String query) =>
                            HistoryActionUtils.onSearchChanged(context, query),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      HistoryCategoryChips(
                        categories: controller.categoryFilters,
                        selectedCategory: controller.selectedCategory,
                        onCategorySelected: (String category) =>
                            HistoryActionUtils.onCategorySelected(
                              context,
                              category,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      HistorySortFilterRow(
                        sortOption: controller.sortOption,
                        hasDateFilter: controller.dateRange != null,
                        onSortSelected: (HistorySortOption option) =>
                            HistoryActionUtils.onSortSelected(context, option),
                        onDateFilterTapped: () =>
                            HistoryActionUtils.showDateRangePicker(context),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (controller.isLoading)
                        const Center(child: WigglyLoader.indeterminate())
                      else if (controller.viewMode == HistoryViewMode.items &&
                          controller.historyEntries.isEmpty)
                        HistoryEmptyState(
                          selectedCategory: controller.selectedCategory,
                        )
                      else if (controller.viewMode ==
                              HistoryViewMode.receipts &&
                          controller.filteredReceipts.isEmpty)
                        HistoryEmptyState(
                          selectedCategory: controller.selectedCategory,
                        )
                      else
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 360),
                          reverseDuration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                final Animation<Offset> offsetAnimation =
                                    Tween<Offset>(
                                      begin: const Offset(0, 0.035),
                                      end: Offset.zero,
                                    ).animate(animation);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                          child: HistoryReceiptsList(
                            key: ValueKey<HistoryViewMode>(controller.viewMode),
                            viewMode: controller.viewMode,
                            entries: controller.visibleHistoryEntries,
                            receipts: controller.visibleFilteredReceipts,
                            onOpenDetails: (receipt) =>
                                HistoryActionUtils.onOpenDetails(
                                  context,
                                  receipt,
                                ),
                          ),
                        ),
                      if (controller.isLoadingMore) ...<Widget>[
                        const SizedBox(height: AppSpacing.md),
                        const Center(
                          child: SizedBox(
                            width: 42,
                            height: 42,
                            child: WigglyLoader.indeterminate(
                              wiggleAmplitude: 1,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryViewModeButton extends StatelessWidget {
  const _HistoryViewModeButton({
    required this.viewMode,
    required this.onPressed,
  });

  final HistoryViewMode viewMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool showingItems = viewMode == HistoryViewMode.items;

    return Tooltip(
      message: showingItems ? context.l10n.receipts : context.l10n.scanItems,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Ink(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  RotationTransition(
                    turns: Tween<double>(
                      begin: 0.88,
                      end: 1,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
              child: Icon(
                showingItems
                    ? Icons.receipt_long_rounded
                    : Icons.view_stream_rounded,
                key: ValueKey<HistoryViewMode>(viewMode),
                color: theme.colorScheme.onSurface,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
