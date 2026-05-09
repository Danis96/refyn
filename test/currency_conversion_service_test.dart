import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:refyn/app/shared/services/currency_conversion_service.dart';

void main() {
  group('CurrencyConversionService', () {
    test('uses Frankfurter v2 rate endpoint for latest conversion', () async {
      final _FakeHttpClient httpClient = _FakeHttpClient(
        routes: <String, _FakeRoute>{
          'https://api.frankfurter.dev/v2/rate/BAM/DKK': _FakeRoute(
            statusCode: 200,
            body: jsonEncode(<String, Object>{
              'date': '2026-05-08',
              'base': 'BAM',
              'quote': 'DKK',
              'rate': 3.8184,
            }),
          ),
        },
      );

      final CurrencyConversionService service = CurrencyConversionService(
        httpClient: httpClient,
      );

      final ConversionResult result = await service.getRate(
        from: 'BAM',
        to: 'DKK',
      );

      expect(result.rate, closeTo(3.8184, 0.00001));
      expect(httpClient.requestedUrls, <String>[
        'https://api.frankfurter.dev/v2/rate/BAM/DKK',
      ]);
    });

    test('uses Frankfurter v2 rates endpoint for historical conversion', () async {
      final _FakeHttpClient httpClient = _FakeHttpClient(
        routes: <String, _FakeRoute>{
          'https://api.frankfurter.dev/v2/rates?date=2026-05-01&base=BAM&quotes=DKK':
              _FakeRoute(
                statusCode: 200,
                body: jsonEncode(<Map<String, Object>>[
                  <String, Object>{
                    'date': '2026-05-01',
                    'base': 'BAM',
                    'quote': 'DKK',
                    'rate': 3.8178,
                  },
                ]),
              ),
        },
      );

      final CurrencyConversionService service = CurrencyConversionService(
        httpClient: httpClient,
      );

      final double result = await service.getHistoricalRate(
        date: DateTime(2026, 5, 1),
        from: 'BAM',
        to: 'DKK',
      );

      expect(result, closeTo(3.8178, 0.00001));
      expect(httpClient.requestedUrls, <String>[
        'https://api.frankfurter.dev/v2/rates?date=2026-05-01&base=BAM&quotes=DKK',
      ]);
    });
  });
}

class _FakeRoute {
  const _FakeRoute({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient({required this.routes});

  final Map<String, _FakeRoute> routes;
  final List<String> requestedUrls = <String>[];

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    final String key = url.toString();
    requestedUrls.add(key);
    final _FakeRoute? route = routes[key];
    if (route == null) {
      throw StateError('Missing fake route for $key');
    }
    return _FakeHttpClientRequest(route);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(this.route);

  final _FakeRoute route;

  @override
  Future<HttpClientResponse> close() async {
    return _FakeHttpClientResponse(route);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _FakeHttpClientResponse(this.route);

  final _FakeRoute route;

  @override
  int get statusCode => route.statusCode;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(<List<int>>[
      utf8.encode(route.body),
    ]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
