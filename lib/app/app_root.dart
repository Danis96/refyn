import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/core/config/app_config.dart';
import 'package:refyn/app/features/ai/domain/repositories/ai_configuration_repository.dart';
import 'package:refyn/app/features/ai/infrastructure/app_settings_ai_configuration_repository.dart';
import 'package:refyn/app/features/budgets/repository/monthly_budget_sync_repository.dart';
import 'package:refyn/app/features/budgets/repository/category_budget_repository.dart';
import 'package:refyn/app/features/export/repository/receipt_export_service.dart';
import 'package:refyn/app/features/receipt_details/repository/receipt_details_repository.dart';
import 'package:refyn/app/features/scan/repository/gemma_receipt_scan_service.dart';
import 'package:refyn/app/features/scan/repository/receipt_image_compression_service.dart';
import 'package:refyn/app/features/settings/application/local_backup_service.dart';
import 'package:refyn/app/features/travel_mode/controllers/travel_mode_controller.dart';
import 'package:refyn/app/features/travel_mode/repository/travel_mode_repository.dart';
import 'package:refyn/app/features/travel_mode/repository/travel_mode_service.dart';
import 'package:refyn/app/shared/services/currency_conversion_service.dart';

import '../database/app_database.dart';
import 'features/dashboard/controllers/dashboard_controller.dart';
import 'features/dashboard/repository/dashboard_repository.dart';
import 'features/history/controllers/history_controller.dart';
import 'features/history/repository/history_repository.dart';
import 'features/scan/controllers/scan_controller.dart';
import 'features/scan/repository/scan_repository.dart';
import 'features/settings/controllers/settings_controller.dart';
import 'features/settings/controllers/settings_spotlight_controller.dart';
import 'features/settings/repository/settings_repository.dart';
import 'my_app.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key, this.database, AppConfig? appConfig})
      : _appConfig = appConfig;

  final AppDatabase? database;
  final AppConfig? _appConfig;

  AppConfig get _config => _appConfig ?? AppConfig.fromEnvironment();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>(
          create: (_) => database ?? AppDatabase(),
          dispose: (_, createdDatabase) => createdDatabase.close(),
        ),
        Provider<ReceiptDao>(
          create: (context) => ReceiptDao(context.read<AppDatabase>()),
        ),
        Provider<CategoryBudgetDao>(
          create: (context) => CategoryBudgetDao(context.read<AppDatabase>()),
        ),
        Provider<AppSettingsDao>(
          create: (context) => AppSettingsDao(context.read<AppDatabase>()),
        ),
        Provider<ReceiptExportService>(create: (_) => ReceiptExportService()),
        Provider<CategoryBudgetRepository>(
          create: (context) => CategoryBudgetRepository(
            dao: context.read<CategoryBudgetDao>(),
            settingsDao: context.read<AppSettingsDao>(),
          ),
        ),
        Provider<DashboardRepository>(
          create: (context) => DashboardRepository(
            receiptDao: context.read<ReceiptDao>(),
            categoryBudgetRepository: context.read<CategoryBudgetRepository>(),
            settingsDao: context.read<AppSettingsDao>(),
          ),
        ),
        Provider<MonthlyBudgetSyncRepository>(
          create: (context) => MonthlyBudgetSyncRepository(
            receiptDao: context.read<ReceiptDao>(),
            categoryBudgetRepository: context.read<CategoryBudgetRepository>(),
          ),
        ),
        ChangeNotifierProvider<DashboardController>(
          create: (context) => DashboardController(
            repository: context.read<DashboardRepository>(),
            categoryBudgetRepository: context.read<CategoryBudgetRepository>(),
            monthlyBudgetSyncRepository: context
                .read<MonthlyBudgetSyncRepository>(),
          )..refreshHome(),
        ),
        Provider<ReceiptImageCompressionService>(
          create: (_) => const ReceiptImageCompressionService(),
        ),
        Provider<AiConfigurationRepository>(
          create: (context) => AppSettingsAiConfigurationRepository(
            settingsDao: context.read<AppSettingsDao>(),
            defaultApiKey: _gemmaApiKey,
            defaultModel: _gemmaModel,
            apiBaseUrl: _gemmaBaseUrl,
          ),
        ),
        Provider<GemmaReceiptScanService>(
          create: (context) {
            final GemmaReceiptScanService service = GemmaReceiptScanService(
              configurationRepository: context.read<AiConfigurationRepository>(),
              baseUrl: _gemmaBaseUrl,
              imageCompressionService: context
                  .read<ReceiptImageCompressionService>(),
            );
            unawaited(service.warmUp());
            return service;
          },
        ),
        Provider<CurrencyConversionService>(
          create: (_) => CurrencyConversionService(),
        ),
        Provider<TravelModeRepository>(
          create: (context) => TravelModeRepository(
            settingsDao: context.read<AppSettingsDao>(),
          ),
        ),
        Provider<TravelModeService>(
          create: (context) => TravelModeService(
            database: context.read<AppDatabase>(),
            receiptDao: context.read<ReceiptDao>(),
            settingsDao: context.read<AppSettingsDao>(),
            travelModeRepository: context.read<TravelModeRepository>(),
            conversionService: context.read<CurrencyConversionService>(),
            monthlyBudgetSyncRepository: context
                .read<MonthlyBudgetSyncRepository>(),
          ),
        ),
        ChangeNotifierProvider<TravelModeController>(
          create: (context) => TravelModeController(
            service: context.read<TravelModeService>(),
            receiptDao: context.read<ReceiptDao>(),
          )..initialize(),
        ),
        Provider<ScanRepository>(
          create: (context) => ScanRepository(
            receiptDao: context.read<ReceiptDao>(),
            settingsDao: context.read<AppSettingsDao>(),
            gemmaService: context.read<GemmaReceiptScanService>(),
            monthlyBudgetSyncRepository: context
                .read<MonthlyBudgetSyncRepository>(),
            currencyConversionService: context
                .read<CurrencyConversionService>(),
            travelModeRepository: context.read<TravelModeRepository>(),
          ),
        ),
        Provider<HistoryRepository>(
          create: (context) => HistoryRepository(
            dao: context.read<ReceiptDao>(),
            monthlyBudgetSyncRepository: context
                .read<MonthlyBudgetSyncRepository>(),
            categoryBudgetRepository: context.read<CategoryBudgetRepository>(),
          ),
        ),
        Provider<ReceiptDetailsRepository>(
          create: (context) => ReceiptDetailsRepository(
            receiptDao: context.read<ReceiptDao>(),
            monthlyBudgetSyncRepository: context
                .read<MonthlyBudgetSyncRepository>(),
            receiptExportService: context.read<ReceiptExportService>(),
          ),
        ),
        ChangeNotifierProvider<HistoryController>(
          create: (context) =>
              HistoryController(repository: context.read<HistoryRepository>())
                ..loadHistory(),
        ),
        ChangeNotifierProvider<ScanController>(
          create: (context) =>
              ScanController(repository: context.read<ScanRepository>())
                ..initialize(),
        ),
        Provider<SettingsRepository>(
          create: (context) => SettingsRepository(
            settingsDao: context.read<AppSettingsDao>(),
            receiptDao: context.read<ReceiptDao>(),
            receiptExportService: context.read<ReceiptExportService>(),
            categoryBudgetRepository: context.read<CategoryBudgetRepository>(),
            monthlyBudgetSyncRepository: context
                .read<MonthlyBudgetSyncRepository>(),
            localBackupService: LocalBackupService(
              database: context.read<AppDatabase>(),
              receiptDao: context.read<ReceiptDao>(),
              appSettingsDao: context.read<AppSettingsDao>(),
              categoryBudgetRepository: context
                  .read<CategoryBudgetRepository>(),
            ),
          ),
        ),
        ChangeNotifierProvider<SettingsController>(
          create: (context) => SettingsController(
            repository: context.read<SettingsRepository>(),
            aiConfigurationRepository:
                context.read<AiConfigurationRepository>(),
          )..loadSettings(),
        ),
        ChangeNotifierProvider<SettingsSpotlightController>(
          create: (_) => SettingsSpotlightController(),
        ),
      ],
      child: const MyApp(),
    );
  }

  String get _gemmaApiKey {
    final fromConfig = _config.gemmaApiKey.trim();
    if (fromConfig.isNotEmpty) {
      return fromConfig;
    }
    return const String.fromEnvironment('GEMMA_API_KEY');
  }

  String get _gemmaModel => _config.gemmaModel;

  String get _gemmaBaseUrl => _config.gemmaApiBaseUrl;
}
