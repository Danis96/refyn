import 'package:flutter/material.dart';
import 'package:refyn/app/features/budgets/repository/category_budget_catalog.dart';
import 'package:refyn/app/features/dashboard/repository/dashboard_budget_progress_model.dart';
import 'package:refyn/app/features/history/controllers/history_receipt_list_entry.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';

import '../repository/history_repository.dart';

enum HistorySortOption { newest, oldest, highestAmount, lowestAmount }

enum HistoryViewMode { items, receipts }

class HistoryController extends ChangeNotifier {
  HistoryController({required HistoryRepository repository})
    : _repository = repository;

  static const int pageSize = 10;

  final HistoryRepository _repository;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<ReceiptModel> _allReceipts = const <ReceiptModel>[];
  Map<String, BudgetUsageState> _budgetStateByCategory =
      const <String, BudgetUsageState>{};
  String _searchQuery = '';
  String _selectedCategory = 'all';
  HistorySortOption _sortOption = HistorySortOption.newest;
  HistoryViewMode _viewMode = HistoryViewMode.items;
  DateTimeRange? _dateRange;
  int _visibleItemCount = pageSize;
  int _visibleReceiptCount = pageSize;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  List<ReceiptModel> get allReceipts => _allReceipts;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  HistorySortOption get sortOption => _sortOption;
  HistoryViewMode get viewMode => _viewMode;
  DateTimeRange? get dateRange => _dateRange;
  Map<String, BudgetUsageState> get budgetStateByCategory =>
      _budgetStateByCategory;

  int get totalReceiptCount => _allReceipts.length;
  int get totalItemCount => _allReceipts.fold<int>(
    0,
    (int sum, ReceiptModel receipt) => sum + receipt.items.length,
  );

  List<String> get categoryFilters => <String>[
    'all',
    ...CategoryBudgetCatalog.supportedCategories,
  ];

  List<HistoryReceiptListEntry> get historyEntries {
    final List<HistoryReceiptListEntry> result = _filteredHistoryEntries.toList(
      growable: false,
    );
    result.sort(_sortComparator);
    return result;
  }

  List<HistoryReceiptListEntry> get visibleHistoryEntries =>
      historyEntries.take(_visibleItemCount).toList(growable: false);

  List<ReceiptModel> get filteredReceipts {
    final List<ReceiptModel> result = _filteredReceipts.toList(growable: false);
    result.sort(_receiptSortComparator);
    return result;
  }

  List<ReceiptModel> get visibleFilteredReceipts =>
      filteredReceipts.take(_visibleReceiptCount).toList(growable: false);

  bool get hasMoreHistoryEntries => historyEntries.length > _visibleItemCount;
  bool get hasMoreFilteredReceipts =>
      filteredReceipts.length > _visibleReceiptCount;

  Iterable<HistoryReceiptListEntry> get _filteredHistoryEntries {
    Iterable<HistoryReceiptListEntry> current = _allReceipts.expand(
      (ReceiptModel receipt) => receipt.items.asMap().entries.map(
        (MapEntry<int, dynamic> entry) => HistoryReceiptListEntry(
          receipt: receipt,
          item: entry.value,
          itemIndex: entry.key,
        ),
      ),
    );

    final String query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      current = current.where((HistoryReceiptListEntry entry) {
        final String merchant = entry.merchantName.toLowerCase();
        final String itemName = entry.itemName.toLowerCase();
        final String category = CategoryBudgetCatalog.normalize(entry.category);
        return merchant.contains(query) ||
            itemName.contains(query) ||
            category.contains(query);
      });
    }

    if (_selectedCategory != 'all') {
      current = current.where(
        (HistoryReceiptListEntry entry) =>
            CategoryBudgetCatalog.normalize(entry.category) ==
            _selectedCategory,
      );
    }

    if (_dateRange != null) {
      final DateTime start = DateTime(
        _dateRange!.start.year,
        _dateRange!.start.month,
        _dateRange!.start.day,
      );
      final DateTime end = DateTime(
        _dateRange!.end.year,
        _dateRange!.end.month,
        _dateRange!.end.day,
        23,
        59,
        59,
      );
      current = current.where((HistoryReceiptListEntry entry) {
        final DateTime date = entry.createdAt;
        return !date.isBefore(start) && !date.isAfter(end);
      });
    }

    return current;
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    _allReceipts = await _repository.getReceipts();
    _budgetStateByCategory = await _repository.getBudgetStateByCategory();
    _resetPagination(notify: false);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveReceipt(ReceiptModel receipt) async {
    await _repository.saveReceipt(receipt);
    await loadHistory();
  }

  BudgetUsageState? budgetStateForCategory(String category) {
    final String key = CategoryBudgetCatalog.normalize(category);
    return _budgetStateByCategory[key];
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _resetPagination(notify: false);
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    _resetPagination(notify: false);
    notifyListeners();
  }

  void setSortOption(HistorySortOption option) {
    _sortOption = option;
    _resetPagination(notify: false);
    notifyListeners();
  }

  void setViewMode(HistoryViewMode mode) {
    if (_viewMode == mode) {
      return;
    }
    _viewMode = mode;
    _resetPagination(notify: false);
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    _resetPagination(notify: false);
    notifyListeners();
  }

  Future<void> loadMoreForCurrentView() async {
    if (_isLoadingMore) {
      return;
    }

    final bool canLoadMore = _viewMode == HistoryViewMode.items
        ? hasMoreHistoryEntries
        : hasMoreFilteredReceipts;
    if (!canLoadMore) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (_viewMode == HistoryViewMode.items) {
      if (hasMoreHistoryEntries) {
        _visibleItemCount += pageSize;
      }
    } else {
      if (hasMoreFilteredReceipts) {
        _visibleReceiptCount += pageSize;
      }
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Iterable<ReceiptModel> get _filteredReceipts {
    Iterable<ReceiptModel> current = _allReceipts;

    final String query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      current = current.where((ReceiptModel receipt) {
        final String merchant = receipt.merchant.name.toLowerCase();
        final String receiptCategory = CategoryBudgetCatalog.normalize(
          receipt.category,
        );
        final bool matchesItem = receipt.items.any((item) {
          final String itemName = item.name.toLowerCase();
          final String itemCategory = CategoryBudgetCatalog.normalize(
            item.category,
          );
          return itemName.contains(query) || itemCategory.contains(query);
        });
        return merchant.contains(query) ||
            receiptCategory.contains(query) ||
            matchesItem;
      });
    }

    if (_selectedCategory != 'all') {
      current = current.where((ReceiptModel receipt) {
        final String receiptCategory = CategoryBudgetCatalog.normalize(
          receipt.category,
        );
        return receiptCategory == _selectedCategory ||
            receipt.items.any(
              (item) =>
                  CategoryBudgetCatalog.normalize(item.category) ==
                  _selectedCategory,
            );
      });
    }

    if (_dateRange != null) {
      final DateTime start = DateTime(
        _dateRange!.start.year,
        _dateRange!.start.month,
        _dateRange!.start.day,
      );
      final DateTime end = DateTime(
        _dateRange!.end.year,
        _dateRange!.end.month,
        _dateRange!.end.day,
        23,
        59,
        59,
      );
      current = current.where((ReceiptModel receipt) {
        final DateTime date = receipt.createdAt;
        return !date.isBefore(start) && !date.isAfter(end);
      });
    }

    return current;
  }

  int _sortComparator(HistoryReceiptListEntry a, HistoryReceiptListEntry b) {
    switch (_sortOption) {
      case HistorySortOption.newest:
        return b.createdAt.compareTo(a.createdAt);
      case HistorySortOption.oldest:
        return a.createdAt.compareTo(b.createdAt);
      case HistorySortOption.highestAmount:
        return b.amount.compareTo(a.amount);
      case HistorySortOption.lowestAmount:
        return a.amount.compareTo(b.amount);
    }
  }

  int _receiptSortComparator(ReceiptModel a, ReceiptModel b) {
    switch (_sortOption) {
      case HistorySortOption.newest:
        return b.createdAt.compareTo(a.createdAt);
      case HistorySortOption.oldest:
        return a.createdAt.compareTo(b.createdAt);
      case HistorySortOption.highestAmount:
        return b.totals.total.compareTo(a.totals.total);
      case HistorySortOption.lowestAmount:
        return a.totals.total.compareTo(b.totals.total);
    }
  }

  void _resetPagination({bool notify = true}) {
    _visibleItemCount = pageSize;
    _visibleReceiptCount = pageSize;
    if (notify) {
      notifyListeners();
    }
  }
}
