import 'fiscal_info_model.dart';
import 'merchant_model.dart';
import 'payment_info_model.dart';
import 'receipt_info_model.dart';
import 'receipt_item_model.dart';
import 'receipt_parsing_utils.dart';
import 'receipt_totals_model.dart';

class ReceiptModel {
  final String id;
  final String country;
  final String currency;
  final MerchantModel merchant;
  final ReceiptInfoModel receiptInfo;
  final List<ReceiptItemModel> items;
  final ReceiptTotalsModel totals;
  final PaymentInfoModel payment;
  final FiscalInfoModel? fiscal;
  final String category;
  final double confidence;
  final String? rawText;
  final String? rawJson;
  final String? imagePath;
  final DateTime createdAt;
  final int? travelSessionId;

  const ReceiptModel({
    required this.id,
    required this.country,
    required this.currency,
    required this.merchant,
    required this.receiptInfo,
    required this.items,
    required this.totals,
    required this.payment,
    required this.category,
    required this.confidence,
    required this.createdAt,
    this.fiscal,
    this.rawText,
    this.rawJson,
    this.imagePath,
    this.travelSessionId,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      id: json['id']?.toString() ?? '',
      country: json['country']?.toString() ?? 'BA',
      currency: json['currency']?.toString() ?? 'BAM',
      merchant: MerchantModel.fromJson(
        (json['merchant'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      receiptInfo: ReceiptInfoModel.fromJson(
        (json['receipt'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      items: (json['items'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic item) =>
                ReceiptItemModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      totals: ReceiptTotalsModel.fromJson(
        (json['totals'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      payment: PaymentInfoModel.fromJson(
        (json['payment'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      fiscal: json['fiscal'] != null
          ? FiscalInfoModel.fromJson(json['fiscal'] as Map<String, dynamic>)
          : null,
      category: json['category']?.toString() ?? 'miscellaneous',
      confidence: toDoubleValue(json['confidence']),
      rawText: json['raw_text']?.toString(),
      rawJson: json['raw_json']?.toString(),
      imagePath: json['image_path']?.toString(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      travelSessionId: json['travel_session_id'] is int
          ? json['travel_session_id'] as int
          : int.tryParse(json['travel_session_id']?.toString() ?? ''),
    );
  }

  /// Returns a new [ReceiptModel] with every monetary field multiplied by
  /// [rate] and the currency replaced with [currency]. Used after a foreign
  /// currency receipt is converted to the user's default currency so that
  /// budget aggregation stays consistent.
  ReceiptModel convertedTo({
    required double rate,
    required String currency,
  }) {
    double scale(double v) => double.parse((v * rate).toStringAsFixed(2));
    double? scaleN(double? v) => v == null ? null : scale(v);

    return ReceiptModel(
      id: id,
      country: country,
      currency: currency,
      merchant: merchant,
      receiptInfo: receiptInfo,
      items: items
          .map(
            (ReceiptItemModel item) => item.copyWith(
              unitPrice: scaleN(item.unitPrice),
              discountAmount: scaleN(item.discountAmount),
              finalPrice: scale(item.finalPrice),
            ),
          )
          .toList(growable: false),
      totals: ReceiptTotalsModel(
        total: scale(totals.total),
        subtotal: scaleN(totals.subtotal),
        discountTotal: scaleN(totals.discountTotal),
        taxableAmount: scaleN(totals.taxableAmount),
        vatRate: totals.vatRate,
        vatAmount: scaleN(totals.vatAmount),
      ),
      payment: PaymentInfoModel(
        method: payment.method,
        paid: scaleN(payment.paid),
        change: scaleN(payment.change),
      ),
      fiscal: fiscal,
      category: category,
      confidence: confidence,
      rawText: rawText,
      rawJson: rawJson,
      imagePath: imagePath,
      createdAt: createdAt,
      travelSessionId: travelSessionId,
    );
  }

  /// Returns a copy with [travelSessionId] replaced (use with `null` to clear).
  ReceiptModel copyWithTravelSessionId(int? sessionId) {
    return ReceiptModel(
      id: id,
      country: country,
      currency: currency,
      merchant: merchant,
      receiptInfo: receiptInfo,
      items: items,
      totals: totals,
      payment: payment,
      fiscal: fiscal,
      category: category,
      confidence: confidence,
      rawText: rawText,
      rawJson: rawJson,
      imagePath: imagePath,
      createdAt: createdAt,
      travelSessionId: sessionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'currency': currency,
      'merchant': merchant.toJson(),
      'receipt': receiptInfo.toJson(),
      'items': items.map((ReceiptItemModel item) => item.toJson()).toList(),
      'totals': totals.toJson(),
      'payment': payment.toJson(),
      'fiscal': fiscal?.toJson(),
      'category': category,
      'confidence': confidence,
      'raw_text': rawText,
      'raw_json': rawJson,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'travel_session_id': travelSessionId,
    };
  }
}
