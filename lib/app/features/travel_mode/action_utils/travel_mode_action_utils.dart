import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:refyn/app/features/history/controllers/history_controller.dart';
import 'package:refyn/app/features/scan/controllers/scan_controller.dart';
import 'package:refyn/app/features/travel_mode/controllers/travel_mode_controller.dart';
import 'package:refyn/app/features/travel_mode/repository/travel_mode_service.dart';
import 'package:refyn/app/features/travel_mode/ui/widgets/end_trip_confirm_dialog.dart';
import 'package:refyn/app/features/travel_mode/ui/widgets/end_trip_loading_dialog.dart';
import 'package:refyn/app/features/travel_mode/ui/widgets/start_trip_sheet.dart';
import 'package:refyn/app/features/travel_mode/ui/widgets/travel_mode_receipts_sheet.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/app/shared/services/currency_conversion_service.dart';
import 'package:refyn/app/widgets/app_snackbar.dart';
import 'package:refyn/routing/route_arguments.dart';
import 'package:refyn/routing/routes.dart';

import '../ui/widgets/travel_mode_settings_card/widgets/travel_mode_info_sheet.dart';

class TravelModeActionUtils {
  const TravelModeActionUtils._();

  static Future<void> showTravelModeInfoSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return const TravelModeInfoSheet();
      },
    );
  }

  static Future<void> startTrip(BuildContext context) async {
    final TravelModeController controller = context.read<TravelModeController>();
    final String? code = await showStartTripSheet(
      context,
      homeCurrency: controller.homeCurrency,
    );
    if (code == null || !context.mounted) {
      return;
    }
    await controller.startTrip(code);
    if (!context.mounted) {
      return;
    }
    AppSnackBar.success(
      context,
      context.l10n.travelModeStartedSnackbar(code),
    );
  }

  static Future<void> endTrip(BuildContext context) async {
    final TravelModeController controller = context.read<TravelModeController>();
    if (!controller.isActive || controller.tripCurrency == null) {
      return;
    }

    final String tripCurrency = controller.tripCurrency!;
    final String homeCurrency = controller.homeCurrency;
    final int receiptCount = controller.tripReceiptCount;

    final TripEndStrategy? strategy = await showEndTripConfirmDialog(
      context,
      tripCurrency: tripCurrency,
      homeCurrency: homeCurrency,
      receiptCount: receiptCount,
    );
    if (strategy == null || !context.mounted) {
      return;
    }

    final NavigatorState rootNavigator = Navigator.of(
      context,
      rootNavigator: true,
    );
    final Future<void> loadingFuture = showEndTripLoadingDialog(
      context,
      tripCurrency: tripCurrency,
      homeCurrency: homeCurrency,
    );

    try {
      final TripEndResult result = await controller.endTrip(strategy: strategy);
      if (rootNavigator.canPop()) {
        rootNavigator.pop();
      }
      await loadingFuture;
      if (!context.mounted) {
        return;
      }
      await _reloadAppState(context);
      if (!context.mounted) {
        return;
      }
      AppSnackBar.success(
        context,
        context.l10n.travelModeEndedSnackbar(
          result.fromCurrency,
          result.toCurrency,
        ),
      );
    } on CurrencyConversionException {
      if (rootNavigator.canPop()) {
        rootNavigator.pop();
      }
      await loadingFuture;
      if (!context.mounted) {
        return;
      }
      AppSnackBar.error(
        context,
        context.l10n.currencyConversionFailedMessage(
          tripCurrency,
          homeCurrency,
        ),
      );
    } catch (_) {
      if (rootNavigator.canPop()) {
        rootNavigator.pop();
      }
      await loadingFuture;
      if (!context.mounted) {
        return;
      }
      AppSnackBar.error(
        context,
        context.l10n.currencyConversionFailedMessage(
          tripCurrency,
          homeCurrency,
        ),
      );
    }
  }

  static Future<void> showTripReceipts(BuildContext context) async {
    final TravelModeController controller = context.read<TravelModeController>();
    final String? tripCurrency = controller.tripCurrency;
    if (!controller.isActive || tripCurrency == null) {
      return;
    }

    final List<ReceiptModel> receipts = await controller.loadActiveTripReceipts();
    if (!context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return TravelModeReceiptsSheet(
          receipts: receipts,
          tripCurrency: tripCurrency,
          onOpenReceipt: (ReceiptModel receipt) async {
            Navigator.of(sheetContext).pop();
            await _openTripReceipt(context, receipt);
          },
        );
      },
    );
  }

  static Future<void> _reloadAppState(BuildContext context) async {
    final DashboardController dashboardController = context.read<DashboardController>();
    final HistoryController historyController = context.read<HistoryController>();
    final ScanController scanController = context.read<ScanController>();

    await dashboardController.refreshHome();
    await historyController.loadHistory();
    await scanController.initialize();
  }

  static Future<void> _openTripReceipt(
      BuildContext context,
      ReceiptModel receipt,
      ) async {
    final TravelModeController travelModeController = context.read<TravelModeController>();
    final DashboardController dashboardController = context.read<DashboardController>();
    final HistoryController historyController = context.read<HistoryController>();
    final ScanController scanController = context.read<ScanController>();

    final Object? result = await Navigator.of(context).pushNamed(
      receiptDetails,
      arguments: ReceiptDetailsPageArguments(
        receiptId: receipt.id,
        heroTag: receiptHeroTag('travel', receipt.id),
      ),
    );
    if (result == true && context.mounted) {
      await travelModeController.refresh();
      await dashboardController.refreshHome();
      await historyController.loadHistory();
      await scanController.initialize();
    }
  }
}
