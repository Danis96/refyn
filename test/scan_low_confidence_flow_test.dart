import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:refyn/app/features/ai/domain/ai_configuration.dart';
import 'package:refyn/app/features/ai/domain/ai_model_option.dart';
import 'package:refyn/app/features/ai/domain/repositories/ai_configuration_repository.dart';
import 'package:refyn/app/features/budgets/repository/category_budget_repository.dart';
import 'package:refyn/app/features/budgets/repository/monthly_budget_sync_repository.dart';
import 'package:refyn/app/features/scan/controllers/scan_controller.dart';
import 'package:refyn/app/features/scan/repository/gemma_receipt_scan_service.dart';
import 'package:refyn/app/features/scan/repository/receipt_image_compression_service.dart';
import 'package:refyn/app/features/scan/repository/scan_repository.dart';
import 'package:refyn/app/features/scan/ui/widgets/low_confidence_confirmation_dialog.dart';
import 'package:refyn/app/features/settings/controllers/settings_spotlight_controller.dart';
import 'package:refyn/app/features/travel_mode/repository/travel_mode_repository.dart';
import 'package:refyn/app/models/receipt/merchant_model.dart';
import 'package:refyn/app/models/receipt/payment_info_model.dart';
import 'package:refyn/app/models/receipt/receipt_info_model.dart';
import 'package:refyn/app/models/receipt/receipt_item_model.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/app/models/receipt/receipt_totals_model.dart';
import 'package:refyn/app/shared/services/currency_conversion_service.dart';
import 'package:refyn/database/app_database.dart';
import 'package:refyn/l10n/app_localizations.dart';

void main() {
  group('ScanController low confidence', () {
    late AppDatabase database;
    late ScanController controller;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      controller = ScanController(
        repository: ScanRepository(
          receiptDao: ReceiptDao(database),
          settingsDao: AppSettingsDao(database),
          gemmaService: GemmaReceiptScanService(
            configurationRepository: _FakeAiConfigurationRepository(),
            imageCompressionService: const ReceiptImageCompressionService(),
          ),
          monthlyBudgetSyncRepository: MonthlyBudgetSyncRepository(
            receiptDao: ReceiptDao(database),
            categoryBudgetRepository: CategoryBudgetRepository(
              dao: CategoryBudgetDao(database),
              settingsDao: AppSettingsDao(database),
            ),
          ),
          currencyConversionService: CurrencyConversionService(),
          travelModeRepository: TravelModeRepository(
            settingsDao: AppSettingsDao(database),
          ),
        ),
      );
    });

    tearDown(() async {
      controller.dispose();
      await database.close();
    });

    test('flags receipts below 90 percent confidence', () {
      controller.debugSetDraftReceipt(_receiptWithConfidence(0.89));
      expect(controller.isLowConfidence, isTrue);

      controller.debugSetDraftReceipt(_receiptWithConfidence(0.90));
      expect(controller.isLowConfidence, isFalse);
    });

    test('escalates thinking suggestion after repeated low confidence scans', () {
      controller.debugSetLowConfidenceScanCount(
        ScanController.thinkingModeSuggestionTriggerCount,
      );

      expect(controller.shouldSuggestThinkingMode, isTrue);
      expect(
        controller.lowConfidenceScanCount,
        ScanController.thinkingModeSuggestionTriggerCount,
      );
    });
  });

  group('LowConfidenceConfirmationDialog', () {
    setUp(() {
      _TestDialogLauncher.lastResult = null;
    });

    testWidgets('shows stronger suggestion after repeated low-confidence scans', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _TestDialogLauncher(shouldSuggestThinkingMode: true),
      );
      await tester.pumpAndSettle();

      expect(find.text('Check low-confidence scan'), findsOneWidget);
      expect(
        find.textContaining(
          'Low-confidence scans keep happening. Consider turning this on by default.',
        ),
        findsOneWidget,
      );
      expect(find.text('Open Thinking AI'), findsOneWidget);
      expect(find.text('Confirm receipt'), findsOneWidget);
    });

    testWidgets('returns open settings action from CTA button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _TestDialogLauncher(shouldSuggestThinkingMode: false),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Thinking AI'));
      await tester.pumpAndSettle();

      expect(
        _TestDialogLauncher.lastResult,
        LowConfidenceDialogAction.openThinkingSettings,
      );
    });
  });

  test('SettingsSpotlightController increments request id', () {
    final SettingsSpotlightController controller =
        SettingsSpotlightController();

    controller.spotlightThinkingMode();

    expect(controller.target, SettingsSpotlightTarget.thinkingMode);
    expect(controller.requestId, 1);
  });
}

ReceiptModel _receiptWithConfidence(double confidence) {
  return ReceiptModel(
    id: 'receipt-1',
    country: 'BA',
    currency: 'BAM',
    merchant: const MerchantModel(name: 'Shop'),
    receiptInfo: const ReceiptInfoModel(type: 'fiscal'),
    items: const <ReceiptItemModel>[],
    totals: const ReceiptTotalsModel(total: 42),
    payment: const PaymentInfoModel(method: 'cash'),
    category: 'miscellaneous',
    confidence: confidence,
    createdAt: DateTime(2026, 5, 10),
  );
}

class _TestDialogLauncher extends StatefulWidget {
  const _TestDialogLauncher({required this.shouldSuggestThinkingMode});

  final bool shouldSuggestThinkingMode;
  static LowConfidenceDialogAction? lastResult;

  @override
  State<_TestDialogLauncher> createState() => _TestDialogLauncherState();
}

class _TestDialogLauncherState extends State<_TestDialogLauncher> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: _AutoOpenDialogHost(
          shouldSuggestThinkingMode: widget.shouldSuggestThinkingMode,
        ),
      ),
    );
  }
}

class _AutoOpenDialogHost extends StatefulWidget {
  const _AutoOpenDialogHost({required this.shouldSuggestThinkingMode});

  final bool shouldSuggestThinkingMode;

  @override
  State<_AutoOpenDialogHost> createState() => _AutoOpenDialogHostState();
}

class _AutoOpenDialogHostState extends State<_AutoOpenDialogHost> {
  bool _opened = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_opened) {
      return;
    }
    _opened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _TestDialogLauncher.lastResult =
          await showDialog<LowConfidenceDialogAction>(
            context: context,
            builder: (_) => LowConfidenceConfirmationDialog(
              shouldSuggestThinkingMode: widget.shouldSuggestThinkingMode,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _FakeAiConfigurationRepository implements AiConfigurationRepository {
  @override
  Future<void> clearConfiguration() async {}

  @override
  Future<List<AiModelOption>> fetchAvailableModels({String? apiKey}) async {
    return const <AiModelOption>[];
  }

  @override
  Future<AiConfiguration> getConfiguration() async {
    return const AiConfiguration(apiKey: '', selectedModel: '');
  }

  @override
  Future<void> saveApiKey(String apiKey) async {}

  @override
  Future<void> saveSelectedModel(String modelId) async {}

  @override
  Future<void> saveThinkingLevel(String thinkingLevel) async {}
}
