import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

class CurrencyConversionException implements Exception {
  CurrencyConversionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ConversionResult {
  const ConversionResult({
    required this.rate,
    required this.fetchedAt,
    required this.fromCurrency,
    required this.toCurrency,
  });

  final double rate;
  final DateTime fetchedAt;
  final String fromCurrency;
  final String toCurrency;

  double convert(double amount) =>
      double.parse((amount * rate).toStringAsFixed(2));
}

class _CachedRate {
  const _CachedRate({required this.rate, required this.fetchedAt});

  final double rate;
  final DateTime fetchedAt;

  bool get isStale =>
      DateTime.now().difference(fetchedAt) > const Duration(hours: 24);
}

/// Fetches FX rates from Frankfurter (https://frankfurter.dev) on demand.
/// Rates are cached in memory for 24h.
///
/// Throws [CurrencyConversionException] on network/parse failure so the
/// caller can decide how to surface the error to the user.
class CurrencyConversionService {
  CurrencyConversionService({
    String baseUrl = 'https://api.frankfurter.dev/v2',
    Duration timeout = const Duration(seconds: 10),
    HttpClient? httpClient,
  }) : _baseUrl = baseUrl,
       _timeout = timeout,
       _httpClient = httpClient ?? HttpClient();

  final String _baseUrl;
  final Duration _timeout;
  final HttpClient _httpClient;
  final Map<String, _CachedRate> _cache = {};
  // Historical rates are immutable — cache them forever (in-memory).
  final Map<String, double> _historicalCache = {};

  bool needsConversion(String currency, String defaultCurrency) {
    return _normalize(currency) != _normalize(defaultCurrency);
  }

  /// Returns the rate to multiply [from] amounts by to get [to] amounts.
  /// Throws [CurrencyConversionException] on failure.
  Future<ConversionResult> getRate({
    required String from,
    required String to,
  }) async {
    final String fromCode = _normalize(from);
    final String toCode = _normalize(to);

    if (fromCode == toCode) {
      return ConversionResult(
        rate: 1,
        fetchedAt: DateTime.now(),
        fromCurrency: fromCode,
        toCurrency: toCode,
      );
    }

    final String cacheKey = '${fromCode}_$toCode';
    final _CachedRate? cached = _cache[cacheKey];
    if (cached != null && !cached.isStale) {
      return ConversionResult(
        rate: cached.rate,
        fetchedAt: cached.fetchedAt,
        fromCurrency: fromCode,
        toCurrency: toCode,
      );
    }

    final _CachedRate fetched = await _fetch(from: fromCode, to: toCode);
    _cache[cacheKey] = fetched;
    return ConversionResult(
      rate: fetched.rate,
      fetchedAt: fetched.fetchedAt,
      fromCurrency: fromCode,
      toCurrency: toCode,
    );
  }

  /// Returns the FX rate that was in effect on [date] for converting [from]
  /// amounts to [to] amounts. Frankfurter returns the previous business day
  /// for weekends/holidays automatically. Throws on failure.
  Future<double> getHistoricalRate({
    required DateTime date,
    required String from,
    required String to,
  }) async {
    final String fromCode = _normalize(from);
    final String toCode = _normalize(to);
    if (fromCode == toCode) return 1;

    final String dateKey = _formatDate(date);
    final String cacheKey = '${fromCode}_${toCode}_$dateKey';
    final double? cached = _historicalCache[cacheKey];
    if (cached != null) return cached;

    final Uri uri = Uri.parse(
      '$_baseUrl/rates?date=$dateKey&base=$fromCode&quotes=$toCode',
    );
    try {
      final HttpClientRequest request = await _httpClient.getUrl(uri);
      final HttpClientResponse response = await request.close().timeout(
        _timeout,
      );
      final String body = await utf8.decodeStream(response);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CurrencyConversionException(
          'Frankfurter historical API error ${response.statusCode}.',
        );
      }
      final double rate = _extractHistoricalRate(body, toCode);
      _historicalCache[cacheKey] = rate;
      return rate;
    } on TimeoutException {
      throw CurrencyConversionException(
        'Currency conversion timed out. Check your connection.',
      );
    } on SocketException catch (error) {
      throw CurrencyConversionException(
        'Currency conversion network error: ${error.message}',
      );
    } on FormatException {
      throw CurrencyConversionException(
        'Currency conversion returned invalid JSON.',
      );
    }
  }

  void clearCache() {
    _cache.clear();
    _historicalCache.clear();
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  Future<_CachedRate> _fetch({required String from, required String to}) async {
    final Uri uri = Uri.parse('$_baseUrl/rate/$from/$to');
    try {
      final HttpClientRequest request = await _httpClient.getUrl(uri);
      final HttpClientResponse response = await request.close().timeout(
        _timeout,
      );
      final String body = await utf8.decodeStream(response);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _logDebug(
          'Frankfurter error. status=${response.statusCode} body=${_preview(body)}',
        );
        throw CurrencyConversionException(
          'Frankfurter API error ${response.statusCode}.',
        );
      }

      final double rate = _extractLatestRate(body, to);
      return _CachedRate(rate: rate, fetchedAt: DateTime.now());
    } on TimeoutException {
      throw CurrencyConversionException(
        'Currency conversion timed out. Check your connection.',
      );
    } on SocketException catch (error) {
      throw CurrencyConversionException(
        'Currency conversion network error: ${error.message}',
      );
    } on FormatException {
      throw CurrencyConversionException(
        'Currency conversion returned invalid JSON.',
      );
    }
  }

  static String _normalize(String value) => value.trim().toUpperCase();

  static String _formatDate(DateTime date) {
    final DateTime utc = DateTime.utc(date.year, date.month, date.day);
    return utc.toIso8601String().substring(0, 10);
  }

  double _extractLatestRate(String body, String toCode) {
    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw CurrencyConversionException(
        'Frankfurter response is not a JSON object.',
      );
    }

    final dynamic quote = decoded['quote'];
    final dynamic rate = decoded['rate'];
    if (quote != toCode || rate is! num) {
      throw CurrencyConversionException(
        'Frankfurter response missing rate for $toCode.',
      );
    }
    return rate.toDouble();
  }

  double _extractHistoricalRate(String body, String toCode) {
    final dynamic decoded = jsonDecode(body);
    if (decoded is! List || decoded.isEmpty) {
      throw CurrencyConversionException(
        'Frankfurter historical response is not a non-empty JSON array.',
      );
    }

    final dynamic first = decoded.first;
    if (first is! Map) {
      throw CurrencyConversionException(
        'Frankfurter historical response item is not a JSON object.',
      );
    }

    final dynamic quote = first['quote'];
    final dynamic rate = first['rate'];
    if (quote != toCode || rate is! num) {
      throw CurrencyConversionException(
        'Frankfurter historical response missing rate for $toCode.',
      );
    }
    return rate.toDouble();
  }

  String _preview(String value, {int max = 200}) {
    final String clean = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    return clean.length <= max ? clean : '${clean.substring(0, max)}...';
  }

  void _logDebug(String message) {
    developer.log(message, name: 'CurrencyConversionService');
  }
}
