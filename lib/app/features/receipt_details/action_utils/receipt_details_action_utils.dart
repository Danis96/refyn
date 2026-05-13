import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refyn/app/features/budgets/repository/category_budget_catalog.dart';
import 'package:refyn/app/features/export/repository/receipt_export_service.dart';
import 'package:refyn/app/features/receipt_details/controllers/receipt_details_controller.dart';
import 'package:refyn/app/helpers/extensions/build_context_x.dart';
import 'package:refyn/app/models/receipt/fiscal_info_model.dart';
import 'package:refyn/app/models/receipt/merchant_model.dart';
import 'package:refyn/app/models/receipt/payment_info_model.dart';
import 'package:refyn/app/models/receipt/receipt_item_model.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/app/models/receipt/receipt_info_model.dart';
import 'package:refyn/app/models/receipt/receipt_parsing_utils.dart';
import 'package:refyn/app/models/receipt/receipt_totals_model.dart';
import 'package:refyn/app/widgets/app_snackbar.dart';
import 'package:refyn/theme/app_spacing.dart';

class ReceiptDetailsActionUtils {
  const ReceiptDetailsActionUtils._();

  static Future<void> onDeleteConfirmed(BuildContext context) async {
    final ReceiptDetailsController controller = context
        .read<ReceiptDetailsController>();
    await controller.deleteReceipt();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  static Future<void> onExport(
    BuildContext context, {
    required ReceiptExportFormat format,
  }) async {
    final String path = await context
        .read<ReceiptDetailsController>()
        .exportReceipt(format);
    if (!context.mounted) {
      return;
    }
    final String formatLabel = switch (format) {
      ReceiptExportFormat.csv => 'CSV',
      ReceiptExportFormat.json => 'JSON',
      ReceiptExportFormat.pdf => 'PDF',
    };
    AppSnackBar.success(
      context,
      context.l10n.fileSavedLabel(formatLabel, path),
    );
  }

  static Future<void> showDeleteDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final navigator = Navigator.of(dialogContext);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  context.l10n.deleteReceiptQuestion,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.deleteReceiptWarning,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD92D00),
                    ),
                    onPressed: () => navigator.pop(true),
                    child: Text(context.l10n.delete),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => navigator.pop(false),
                    child: Text(context.l10n.cancel),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm != true || !context.mounted) {
      return;
    }
    await onDeleteConfirmed(context);
  }

  static Future<void> showEditDialog(
    BuildContext context,
    ReceiptDetailsController controller,
    ReceiptModel receipt,
  ) async {
    final _ReceiptEditorDraft draft = _ReceiptEditorDraft.fromReceipt(receipt);

    final bool? save = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final ThemeData theme = Theme.of(context);
            final ColorScheme colorScheme = theme.colorScheme;
            final NavigatorState navigator = Navigator.of(dialogContext);

            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                12,
                AppSpacing.md,
                AppSpacing.md + MediaQuery.of(dialogContext).viewInsets.bottom,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        Text(
                          context.l10n.editReceipt,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'IDs, image path, travel link locked.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _EditorSectionTitle('Basics'),
                        _EditorTextField(
                          controller: draft.countryController,
                          label: 'Country',
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.currencyController,
                          label: 'Currency',
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.categoryController,
                          label: 'Category',
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.confidenceController,
                          label: 'Confidence',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _EditorSectionTitle('Merchant'),
                        _EditorTextField(
                          controller: draft.merchantNameController,
                          label: 'Merchant name',
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.storeNameController,
                          label: 'Store name',
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.addressController,
                          label: 'Address',
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.cityController,
                          label: 'City',
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.jibController,
                          label: 'JIB',
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.pibController,
                          label: 'PIB',
                        ),
                        const SizedBox(height: 18),
                        const _EditorSectionTitle('Receipt'),
                        _EditorTextField(
                          controller: draft.receiptTypeController,
                          label: 'Receipt type',
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.receiptNumberController,
                          label: 'Receipt number',
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.receiptDateController,
                          label: 'Date',
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.receiptTimeController,
                          label: 'Time',
                        ),
                        const SizedBox(height: 18),
                        const _EditorSectionTitle('Totals'),
                        _EditorTextField(
                          controller: draft.totalController,
                          label: 'Total',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.subtotalController,
                          label: 'Subtotal',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.discountTotalController,
                          label: 'Discount total',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.taxableAmountController,
                          label: 'Taxable amount',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.vatRateController,
                          label: 'VAT rate',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.vatAmountController,
                          label: 'VAT amount',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _EditorSectionTitle('Payment'),
                        _EditorTextField(
                          controller: draft.paymentMethodController,
                          label: 'Payment method',
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.paymentPaidController,
                          label: 'Paid',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.paymentChangeController,
                          label: 'Change',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _EditorSectionTitle('Fiscal'),
                        _EditorTextField(
                          controller: draft.fiscalIbfmController,
                          label: 'IBFM',
                        ),
                        const SizedBox(height: 12),
                        _EditorTextField(
                          controller: draft.fiscalVerificationCodeController,
                          label: 'Verification code',
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: draft.fiscalQrPresent,
                          title: const Text('QR present'),
                          onChanged: (bool value) {
                            setState(() => draft.fiscalQrPresent = value);
                          },
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: <Widget>[
                            Text(
                              'Items',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  draft.items.add(
                                    _ReceiptItemEditorDraft.empty(),
                                  );
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add item'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (int index = 0; index < draft.items.length; index++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ReceiptItemEditorCard(
                              index: index,
                              draft: draft.items[index],
                              onRemove: () {
                                setState(() {
                                  draft.items[index].dispose();
                                  draft.items.removeAt(index);
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: saving ? null : () => navigator.pop(false),
                          child: Text(context.l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  setState(() => saving = true);
                                  try {
                                    await controller.saveEditedReceipt(
                                      draft.toReceipt(receipt),
                                    );
                                    if (!context.mounted) {
                                      return;
                                    }
                                    navigator.pop(true);
                                  } finally {
                                    if (context.mounted) {
                                      setState(() => saving = false);
                                    }
                                  }
                                },
                          child: Text(
                            saving ? 'Saving...' : context.l10n.saveChanges,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    draft.dispose();

    if (save != true || !context.mounted) return;
    AppSnackBar.success(context, context.l10n.receiptUpdated);
  }

  static Future<void> showItemCategoryPicker(
    BuildContext context,
    ReceiptDetailsController controller,
    ReceiptModel receipt, {
    required int itemIndex,
  }) async {
    if (itemIndex < 0 || itemIndex >= receipt.items.length) {
      return;
    }

    final ReceiptItemModel item = receipt.items[itemIndex];
    String selectedCategory = CategoryBudgetCatalog.normalize(item.category);
    final TextEditingController nameController = TextEditingController(
      text: item.name,
    );

    final ({String category, String name})?
    editedItem = await showModalBottomSheet<({String category, String name})>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        final ThemeData theme = Theme.of(sheetContext);
        final ColorScheme colorScheme = theme.colorScheme;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                12,
                AppSpacing.md,
                AppSpacing.md + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.l10n.changeItemCategory,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name.trim().isEmpty
                        ? context.l10n.unnamedItem
                        : item.name.trim(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: context.l10n.itemName,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: CategoryBudgetCatalog.supportedCategories
                        .map(
                          (String category) => ChoiceChip(
                            label: Text(context.l10n.categoryLabel(category)),
                            selected: selectedCategory == category,
                            onSelected: (_) {
                              setState(() => selectedCategory = category);
                            },
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop((
                        category: selectedCategory,
                        name: nameController.text.trim(),
                      )),
                      child: Text(context.l10n.saveChanges),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    final String? saveCategory = editedItem?.category;
    final String normalizedName = editedItem?.name.trim() ?? '';
    final String nextName = normalizedName.isEmpty ? item.name : normalizedName;

    if (saveCategory == null || !context.mounted) {
      return;
    }

    final bool categoryUnchanged =
        saveCategory == CategoryBudgetCatalog.normalize(item.category);
    final bool nameUnchanged = nextName == item.name;
    if (categoryUnchanged && nameUnchanged) {
      return;
    }

    await controller.updateItem(
      itemIndex: itemIndex,
      name: nextName,
      category: saveCategory,
    );
    if (!context.mounted) {
      return;
    }
    AppSnackBar.success(
      context,
      context.l10n.itemUpdatedLabel(
        nextName.trim().isEmpty ? context.l10n.scanItems : nextName.trim(),
      ),
    );
  }

  static Future<void> openReceiptImage(
    BuildContext context,
    ReceiptModel receipt,
  ) async {
    final String? imagePath = receipt.imagePath;
    if (imagePath == null || imagePath.trim().isEmpty) {
      AppSnackBar.warning(context, context.l10n.noReceiptImageAvailable);
      return;
    }

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (BuildContext dialogContext) {
        return Dialog.fullscreen(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Text(
                      context.l10n.unableToLoadImage,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(dialogContext).padding.top + 12,
                right: 16,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white),
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

class _ReceiptEditorDraft {
  _ReceiptEditorDraft({
    required this.countryController,
    required this.currencyController,
    required this.categoryController,
    required this.confidenceController,
    required this.merchantNameController,
    required this.storeNameController,
    required this.addressController,
    required this.cityController,
    required this.jibController,
    required this.pibController,
    required this.receiptTypeController,
    required this.receiptNumberController,
    required this.receiptDateController,
    required this.receiptTimeController,
    required this.totalController,
    required this.subtotalController,
    required this.discountTotalController,
    required this.taxableAmountController,
    required this.vatRateController,
    required this.vatAmountController,
    required this.paymentMethodController,
    required this.paymentPaidController,
    required this.paymentChangeController,
    required this.fiscalIbfmController,
    required this.fiscalVerificationCodeController,
    required this.items,
    required this.fiscalQrPresent,
  });

  factory _ReceiptEditorDraft.fromReceipt(ReceiptModel receipt) {
    return _ReceiptEditorDraft(
      countryController: TextEditingController(text: receipt.country),
      currencyController: TextEditingController(text: receipt.currency),
      categoryController: TextEditingController(text: receipt.category),
      confidenceController: TextEditingController(
        text: receipt.confidence.toString(),
      ),
      merchantNameController: TextEditingController(
        text: receipt.merchant.name,
      ),
      storeNameController: TextEditingController(
        text: receipt.merchant.storeName ?? '',
      ),
      addressController: TextEditingController(
        text: receipt.merchant.address ?? '',
      ),
      cityController: TextEditingController(text: receipt.merchant.city ?? ''),
      jibController: TextEditingController(text: receipt.merchant.jib ?? ''),
      pibController: TextEditingController(text: receipt.merchant.pib ?? ''),
      receiptTypeController: TextEditingController(
        text: receipt.receiptInfo.type,
      ),
      receiptNumberController: TextEditingController(
        text: receipt.receiptInfo.number ?? '',
      ),
      receiptDateController: TextEditingController(
        text: receipt.receiptInfo.date ?? '',
      ),
      receiptTimeController: TextEditingController(
        text: receipt.receiptInfo.time ?? '',
      ),
      totalController: TextEditingController(
        text: receipt.totals.total.toString(),
      ),
      subtotalController: TextEditingController(
        text: receipt.totals.subtotal?.toString() ?? '',
      ),
      discountTotalController: TextEditingController(
        text: receipt.totals.discountTotal?.toString() ?? '',
      ),
      taxableAmountController: TextEditingController(
        text: receipt.totals.taxableAmount?.toString() ?? '',
      ),
      vatRateController: TextEditingController(
        text: receipt.totals.vatRate?.toString() ?? '',
      ),
      vatAmountController: TextEditingController(
        text: receipt.totals.vatAmount?.toString() ?? '',
      ),
      paymentMethodController: TextEditingController(
        text: receipt.payment.method,
      ),
      paymentPaidController: TextEditingController(
        text: receipt.payment.paid?.toString() ?? '',
      ),
      paymentChangeController: TextEditingController(
        text: receipt.payment.change?.toString() ?? '',
      ),
      fiscalIbfmController: TextEditingController(
        text: receipt.fiscal?.ibfm ?? '',
      ),
      fiscalVerificationCodeController: TextEditingController(
        text: receipt.fiscal?.verificationCode ?? '',
      ),
      items: receipt.items
          .map(_ReceiptItemEditorDraft.fromItem)
          .toList(growable: true),
      fiscalQrPresent: receipt.fiscal?.qrPresent ?? false,
    );
  }

  final TextEditingController countryController;
  final TextEditingController currencyController;
  final TextEditingController categoryController;
  final TextEditingController confidenceController;
  final TextEditingController merchantNameController;
  final TextEditingController storeNameController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController jibController;
  final TextEditingController pibController;
  final TextEditingController receiptTypeController;
  final TextEditingController receiptNumberController;
  final TextEditingController receiptDateController;
  final TextEditingController receiptTimeController;
  final TextEditingController totalController;
  final TextEditingController subtotalController;
  final TextEditingController discountTotalController;
  final TextEditingController taxableAmountController;
  final TextEditingController vatRateController;
  final TextEditingController vatAmountController;
  final TextEditingController paymentMethodController;
  final TextEditingController paymentPaidController;
  final TextEditingController paymentChangeController;
  final TextEditingController fiscalIbfmController;
  final TextEditingController fiscalVerificationCodeController;
  final List<_ReceiptItemEditorDraft> items;
  bool fiscalQrPresent;

  ReceiptModel toReceipt(ReceiptModel receipt) {
    final String normalizedDate = receiptDateController.text.trim();
    final String normalizedTime = receiptTimeController.text.trim();

    return ReceiptModel(
      id: receipt.id,
      country: _requiredText(countryController, receipt.country),
      currency: _requiredText(currencyController, receipt.currency),
      merchant: MerchantModel(
        name: _requiredText(merchantNameController, receipt.merchant.name),
        storeName: _nullableText(storeNameController),
        address: _nullableText(addressController),
        city: _nullableText(cityController),
        jib: _nullableText(jibController),
        pib: _nullableText(pibController),
      ),
      receiptInfo: ReceiptInfoModel(
        type: _requiredText(receiptTypeController, receipt.receiptInfo.type),
        number: _nullableText(receiptNumberController),
        date: normalizedDate.isEmpty ? null : normalizedDate,
        time: normalizedTime.isEmpty ? null : normalizedTime,
        dateTime: _resolveDateTime(
          existing: receipt.receiptInfo.dateTime,
          date: normalizedDate,
          time: normalizedTime,
        ),
      ),
      items: items.map((draft) => draft.toItem()).toList(growable: false),
      totals: ReceiptTotalsModel(
        total: _requiredDouble(totalController, receipt.totals.total),
        subtotal: _nullableDouble(subtotalController),
        discountTotal: _nullableDouble(discountTotalController),
        taxableAmount: _nullableDouble(taxableAmountController),
        vatRate: _nullableDouble(vatRateController),
        vatAmount: _nullableDouble(vatAmountController),
      ),
      payment: PaymentInfoModel(
        method: _requiredText(paymentMethodController, receipt.payment.method),
        paid: _nullableDouble(paymentPaidController),
        change: _nullableDouble(paymentChangeController),
      ),
      fiscal:
          fiscalQrPresent ||
              fiscalIbfmController.text.trim().isNotEmpty ||
              fiscalVerificationCodeController.text.trim().isNotEmpty
          ? FiscalInfoModel(
              ibfm: _nullableText(fiscalIbfmController),
              qrPresent: fiscalQrPresent,
              verificationCode: _nullableText(fiscalVerificationCodeController),
            )
          : null,
      category: _requiredText(categoryController, receipt.category),
      confidence: _requiredDouble(confidenceController, receipt.confidence),
      rawText: receipt.rawText,
      rawJson: receipt.rawJson,
      imagePath: receipt.imagePath,
      createdAt: receipt.createdAt,
      travelSessionId: receipt.travelSessionId,
    );
  }

  void dispose() {
    countryController.dispose();
    currencyController.dispose();
    categoryController.dispose();
    confidenceController.dispose();
    merchantNameController.dispose();
    storeNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    jibController.dispose();
    pibController.dispose();
    receiptTypeController.dispose();
    receiptNumberController.dispose();
    receiptDateController.dispose();
    receiptTimeController.dispose();
    totalController.dispose();
    subtotalController.dispose();
    discountTotalController.dispose();
    taxableAmountController.dispose();
    vatRateController.dispose();
    vatAmountController.dispose();
    paymentMethodController.dispose();
    paymentPaidController.dispose();
    paymentChangeController.dispose();
    fiscalIbfmController.dispose();
    fiscalVerificationCodeController.dispose();
    for (final _ReceiptItemEditorDraft item in items) {
      item.dispose();
    }
  }
}

class _ReceiptItemEditorDraft {
  _ReceiptItemEditorDraft({
    required this.nameController,
    required this.categoryController,
    required this.unitController,
    required this.quantityController,
    required this.unitPriceController,
    required this.discountPercentController,
    required this.discountAmountController,
    required this.finalPriceController,
  });

  factory _ReceiptItemEditorDraft.fromItem(ReceiptItemModel item) {
    return _ReceiptItemEditorDraft(
      nameController: TextEditingController(text: item.name),
      categoryController: TextEditingController(text: item.category),
      unitController: TextEditingController(text: item.unit ?? ''),
      quantityController: TextEditingController(text: item.quantity.toString()),
      unitPriceController: TextEditingController(
        text: item.unitPrice?.toString() ?? '',
      ),
      discountPercentController: TextEditingController(
        text: item.discountPercent?.toString() ?? '',
      ),
      discountAmountController: TextEditingController(
        text: item.discountAmount?.toString() ?? '',
      ),
      finalPriceController: TextEditingController(
        text: item.finalPrice.toString(),
      ),
    );
  }

  factory _ReceiptItemEditorDraft.empty() {
    return _ReceiptItemEditorDraft(
      nameController: TextEditingController(),
      categoryController: TextEditingController(text: 'miscellaneous'),
      unitController: TextEditingController(),
      quantityController: TextEditingController(text: '1'),
      unitPriceController: TextEditingController(),
      discountPercentController: TextEditingController(),
      discountAmountController: TextEditingController(),
      finalPriceController: TextEditingController(text: '0'),
    );
  }

  final TextEditingController nameController;
  final TextEditingController categoryController;
  final TextEditingController unitController;
  final TextEditingController quantityController;
  final TextEditingController unitPriceController;
  final TextEditingController discountPercentController;
  final TextEditingController discountAmountController;
  final TextEditingController finalPriceController;

  ReceiptItemModel toItem() {
    return ReceiptItemModel(
      name: _requiredText(nameController, ''),
      category: _requiredText(categoryController, 'miscellaneous'),
      unit: _nullableText(unitController),
      quantity: _requiredDouble(quantityController, 1),
      unitPrice: _nullableDouble(unitPriceController),
      discountPercent: _nullableDouble(discountPercentController),
      discountAmount: _nullableDouble(discountAmountController),
      finalPrice: _requiredDouble(finalPriceController, 0),
    );
  }

  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    unitController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    discountPercentController.dispose();
    discountAmountController.dispose();
    finalPriceController.dispose();
  }
}

class _EditorSectionTitle extends StatelessWidget {
  const _EditorSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _EditorTextField extends StatelessWidget {
  const _EditorTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _ReceiptItemEditorCard extends StatelessWidget {
  const _ReceiptItemEditorCard({
    required this.index,
    required this.draft,
    required this.onRemove,
  });

  final int index;
  final _ReceiptItemEditorDraft draft;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Item ${index + 1}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
              ),
            ],
          ),
          _EditorTextField(controller: draft.nameController, label: 'Name'),
          const SizedBox(height: 12),
          _EditorTextField(
            controller: draft.categoryController,
            label: 'Category',
          ),
          const SizedBox(height: 12),
          _EditorTextField(controller: draft.unitController, label: 'Unit'),
          const SizedBox(height: 12),
          _EditorTextField(
            controller: draft.quantityController,
            label: 'Quantity',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          _EditorTextField(
            controller: draft.unitPriceController,
            label: 'Unit price',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          _EditorTextField(
            controller: draft.discountPercentController,
            label: 'Discount %',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          _EditorTextField(
            controller: draft.discountAmountController,
            label: 'Discount amount',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          _EditorTextField(
            controller: draft.finalPriceController,
            label: 'Final price',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }
}

String _requiredText(TextEditingController controller, String fallback) {
  final String value = controller.text.trim();
  return value.isEmpty ? fallback : value;
}

String? _nullableText(TextEditingController controller) {
  final String value = controller.text.trim();
  return value.isEmpty ? null : value;
}

double _requiredDouble(TextEditingController controller, double fallback) {
  final String value = controller.text.trim();
  return value.isEmpty ? fallback : toDoubleValue(value, fallback: fallback);
}

double? _nullableDouble(TextEditingController controller) {
  final String value = controller.text.trim();
  return value.isEmpty ? null : toDoubleValue(value);
}

DateTime? _resolveDateTime({
  required DateTime? existing,
  required String date,
  required String time,
}) {
  if (date.isEmpty && time.isEmpty) {
    return null;
  }

  final String normalizedDateTime = time.isEmpty ? date : '$date $time';
  return DateTime.tryParse(normalizedDateTime) ?? existing;
}
