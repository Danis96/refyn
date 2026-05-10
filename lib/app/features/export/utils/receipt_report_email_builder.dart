import 'package:intl/intl.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/l10n/app_localizations.dart';

class ReceiptReportEmailDraft {
  const ReceiptReportEmailDraft({
    required this.subject,
    required this.htmlBody,
    required this.plainTextBody,
    required this.attachmentPaths,
  });

  final String subject;
  final String htmlBody;
  final String plainTextBody;
  final List<String> attachmentPaths;
}

class ReceiptReportEmailBuilder {
  const ReceiptReportEmailBuilder._();

  static ReceiptReportEmailDraft build(List<ReceiptModel> receipts) {
    final AppLocalizations l10n = AppLocalizations.current;
    final DateTime now = DateTime.now();
    final List<String> attachmentPaths = <String>{
      for (final ReceiptModel receipt in receipts)
        if (_hasText(receipt.imagePath)) receipt.imagePath!,
    }.toList(growable: false);

    final String subject =
        '${l10n.exportReportTitle} - ${DateFormat('dd.MM.yyyy').format(now)}';

    final String htmlBody =
        '''
<html>
  <body style="margin:0;padding:24px;background:#f5f7fb;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;color:#101828;">
    <div style="max-width:720px;margin:0 auto;background:#ffffff;border-radius:24px;padding:28px;border:1px solid #d0d5dd;">
      <div style="padding:18px 20px;border-radius:18px;background:linear-gradient(135deg,#ecfdf3 0%,#f0f9ff 100%);">
        <div style="font-size:12px;letter-spacing:0.08em;text-transform:uppercase;color:#0f766e;font-weight:700;">${l10n.export}</div>
        <div style="margin-top:8px;font-size:22px;font-weight:800;color:#101828;">${receipts.length} ${l10n.savedReceipts}</div>
      </div>
      <div style="height:18px;"></div>
      ${receipts.map(_buildReceiptSection).join('<div style="height:14px;"></div>')}
    </div>
  </body>
</html>
''';

    final String plainTextBody = _buildPlainTextBody(receipts, now);

    return ReceiptReportEmailDraft(
      subject: subject,
      htmlBody: htmlBody,
      plainTextBody: plainTextBody,
      attachmentPaths: attachmentPaths,
    );
  }

  static String _buildPlainTextBody(
    List<ReceiptModel> receipts,
    DateTime generatedAt,
  ) {
    final StringBuffer buffer = StringBuffer()
      ..writeln(AppLocalizations.current.exportReportTitle)
      ..writeln(
        '${AppLocalizations.current.generatedOn}: ${DateFormat('dd.MM.yyyy HH:mm').format(generatedAt)}',
      )
      ..writeln('${AppLocalizations.current.receipts}: ${receipts.length}')
      ..writeln();

    for (int index = 0; index < receipts.length; index++) {
      final ReceiptModel receipt = receipts[index];
      buffer
        ..writeln(receipt.merchant.name)
        ..writeln(
          '${AppLocalizations.current.scanTotal}: ${receipt.totals.total.toStringAsFixed(2)} ${receipt.currency}',
        )
        ..writeln(
          '${AppLocalizations.current.created}: ${DateFormat('dd.MM.yyyy HH:mm').format(receipt.createdAt)}',
        )
        ..writeln(
          '${AppLocalizations.current.receiptNumber}: ${_readValue(receipt.receiptInfo.number)}',
        )
        ..writeln(
          '${AppLocalizations.current.payment}: ${_readValue(receipt.payment.method)}',
        )
        ..writeln(
          '${AppLocalizations.current.scanItems}: ${receipt.items.length}',
        );

      if (index != receipts.length - 1) {
        buffer
          ..writeln()
          ..writeln('----------------------------------------')
          ..writeln();
      }
    }

    return buffer.toString().trimRight();
  }

  static String _buildReceiptSection(ReceiptModel receipt) {
    return '''
<table width="100%" cellpadding="0" cellspacing="0" style="border:1px solid #d0d5dd;border-radius:18px;background:#fcfcfd;">
  <tr>
    <td style="padding:18px;">
      <div style="font-size:20px;font-weight:700;color:#101828;">${_escapeHtml(receipt.merchant.name)}</div>
      <div style="margin-top:6px;font-size:14px;color:#475467;">${AppLocalizations.current.scanTotal}: ${receipt.totals.total.toStringAsFixed(2)} ${_escapeHtml(receipt.currency)}</div>
      <div style="margin-top:10px;font-size:14px;color:#344054;">${AppLocalizations.current.created}: ${_escapeHtml(DateFormat('dd.MM.yyyy HH:mm').format(receipt.createdAt))}</div>
      <div style="margin-top:4px;font-size:14px;color:#344054;">${AppLocalizations.current.receiptNumber}: ${_escapeHtml(_readValue(receipt.receiptInfo.number))}</div>
      <div style="margin-top:4px;font-size:14px;color:#344054;">${AppLocalizations.current.payment}: ${_escapeHtml(_readValue(receipt.payment.method))}</div>
      <div style="margin-top:4px;font-size:14px;color:#344054;">${AppLocalizations.current.scanItems}: ${receipt.items.length}</div>
    </td>
  </tr>
</table>
''';
  }

  static String _readValue(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? AppLocalizations.current.notAvailable : trimmed;
  }

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;

  static String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
