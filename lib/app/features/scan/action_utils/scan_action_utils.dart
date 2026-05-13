import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:refyn/app/features/history/controllers/history_controller.dart';
import 'package:refyn/app/features/scan/controllers/scan_controller.dart';
import 'package:refyn/app/features/scan/repository/scan_failure.dart';
import 'package:refyn/app/features/scan/ui/widgets/low_confidence_confirmation_dialog.dart';
import 'package:refyn/app/features/settings/controllers/settings_controller.dart';
import 'package:refyn/app/features/settings/controllers/settings_spotlight_controller.dart';
import 'package:refyn/app/features/travel_mode/controllers/travel_mode_controller.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/app/widgets/app_snackbar.dart';

class ScanActionUtils {
  const ScanActionUtils._();

  static void handleFailure(BuildContext context, ScanController controller) {
    final ScanFailure? failure = controller.consumeFailure();
    if (failure == null) {
      return;
    }

    // Use a post-frame callback to safely show a dialog during a build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      showErrorPopup(context, failure);
    });
  }

  static Future<void> onOpenGallery(BuildContext context) {
    return context.read<ScanController>().pickFromGallery();
  }

  static Future<void> onOpenCamera(BuildContext context) {
    return context.read<ScanController>().pickFromCamera();
  }

  static void onRemoveImage(BuildContext context, int index) {
    context.read<ScanController>().removeImageAt(index);
  }

  static Future<void> onAddPage(BuildContext context) async {
    final ScanController controller = context.read<ScanController>();
    if (!controller.canAddMoreImages) {
      return;
    }
    final _AddPageSource? choice = await showModalBottomSheet<_AddPageSource>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (BuildContext sheetContext) =>
          _AddPageSourceSheet(parentContext: context),
    );
    if (choice == null || !context.mounted) {
      return;
    }
    switch (choice) {
      case _AddPageSource.gallery:
        await controller.pickFromGallery();
        break;
      case _AddPageSource.camera:
        await controller.pickFromCamera();
        break;
    }
  }

  static Future<void> onScan(BuildContext context) async {
    await context.read<ScanController>().scanSelectedImage();
  }

  static Future<void> onRetryScan(BuildContext context) async {
    await context.read<ScanController>().scanSelectedImage();
  }

  static void onCancelScan(BuildContext context) {
    context.read<ScanController>().cancelScan();
  }

  static Future<void> onSaveDraft(BuildContext context) async {
    final ScanController scanController = context.read<ScanController>();
    final SettingsController settingsController = context
        .read<SettingsController>();
    final DashboardController dashboardController = context
        .read<DashboardController>();
    final HistoryController historyController = context
        .read<HistoryController>();
    final TravelModeController travelModeController = context
        .read<TravelModeController>();
    if (scanController.isLowConfidence) {
      final LowConfidenceDialogAction action =
          await _showLowConfidenceConfirmationDialog(
            context,
            shouldSuggestThinkingMode:
                scanController.shouldSuggestThinkingMode &&
                !settingsController.isThinkingEnabled,
          );
      if (!context.mounted) {
        return;
      }
      if (action == LowConfidenceDialogAction.openThinkingSettings) {
        _openThinkingSettings(context);
        return;
      }
      if (action != LowConfidenceDialogAction.confirm) {
        return;
      }
    }

    await scanController.saveDraftReceipt();
    final bool saved = !scanController.hasPendingReceiptDraft;
    if (saved) {
      await dashboardController.refreshHome();
      await historyController.loadHistory();
      await travelModeController.refresh();
    }
    if (!context.mounted) {
      return;
    }
    if (saved) {
      AppSnackBar.success(context, context.l10n.scanReceiptSaved);
    }
  }

  static void onReset(BuildContext context) {
    context.read<ScanController>().clearSelection();
  }

  static Future<void> onScanAnother(BuildContext context) {
    return context.read<ScanController>().showReadyToScan();
  }

  static Future<void> onEditDraft(BuildContext context) async {
    final ScanController controller = context.read<ScanController>();
    final ReceiptModel? draft = controller.pendingReceiptDraft;
    if (draft == null) {
      return;
    }

    final TextEditingController merchantController = TextEditingController(
      text: draft.merchant.name,
    );
    final TextEditingController paymentController = TextEditingController(
      text: draft.payment.method,
    );
    final TextEditingController totalController = TextEditingController(
      text: draft.totals.total.toStringAsFixed(2),
    );

    try {
      final bool? save = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (BuildContext _, StateSetter setState) {
              return AlertDialog(
                title: Text(context.l10n.scanEditParsedReceipt),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: merchantController,
                        decoration: InputDecoration(
                          labelText: context.l10n.scanEditMerchant,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: paymentController,
                        decoration: InputDecoration(
                          labelText: context.l10n.scanEditPaymentMethod,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: totalController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.l10n.scanEditTotal,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(context.l10n.scanDialogCancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(context.l10n.scanDialogApply),
                  ),
                ],
              );
            },
          );
        },
      );

      if (save != true || !context.mounted) {
        return;
      }

      final String merchantInput = merchantController.text.trim();
      final String paymentInput = paymentController.text.trim();
      final double? total = double.tryParse(totalController.text.trim());
      if (merchantInput.isEmpty) {
        AppSnackBar.error(context, context.l10n.scanMerchantValidationError);
        return;
      }
      if (paymentInput.isEmpty) {
        AppSnackBar.error(context, context.l10n.scanPaymentValidationError);
        return;
      }
      if (total == null || total <= 0) {
        AppSnackBar.error(context, context.l10n.scanTotalValidationError);
        return;
      }

      controller.updateDraftReceipt(
        merchantName: merchantInput,
        paymentMethod: paymentInput,
        total: total,
      );
      AppSnackBar.success(context, context.l10n.scanDraftUpdated);
    } finally {
      merchantController.dispose();
      paymentController.dispose();
      totalController.dispose();
    }
  }

  static Future<void> showErrorPopup(
    BuildContext context,
    ScanFailure failure,
  ) async {
    if (!context.mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.error.withValues(
                        alpha: 0.16,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        failure.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  failure.message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(context.l10n.scanErrorDismiss),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          await onRetryScan(context);
                        },
                        child: Text(context.l10n.scanErrorRetry),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _openThinkingSettings(BuildContext context) {
    context.read<DashboardController>().setCurrentTab(3);
    context.read<SettingsSpotlightController>().spotlightThinkingMode();
  }

  static Future<LowConfidenceDialogAction> _showLowConfidenceConfirmationDialog(
    BuildContext context, {
    required bool shouldSuggestThinkingMode,
  }) async {
    final LowConfidenceDialogAction? action =
        await showDialog<LowConfidenceDialogAction>(
          context: context,
          builder: (BuildContext dialogContext) =>
              LowConfidenceConfirmationDialog(
                shouldSuggestThinkingMode: shouldSuggestThinkingMode,
              ),
        );
    return action ?? LowConfidenceDialogAction.dismiss;
  }
}

enum _AddPageSource { gallery, camera }

class _AddPageSourceSheet extends StatelessWidget {
  const _AddPageSourceSheet({required this.parentContext});

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                height: 4,
                width: 42,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: cs.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              parentContext.l10n.scanAddSourceTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _SourceOptionTile(
              icon: Icons.image_outlined,
              label: parentContext.l10n.scanFromGallery,
              onTap: () => Navigator.of(context).pop(_AddPageSource.gallery),
            ),
            const SizedBox(height: 10),
            _SourceOptionTile(
              icon: Icons.camera_alt_outlined,
              label: parentContext.l10n.scanFromCamera,
              onTap: () => Navigator.of(context).pop(_AddPageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceOptionTile extends StatelessWidget {
  const _SourceOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: <Widget>[
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: cs.secondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
