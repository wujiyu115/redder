import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/data/datasources/remote/google_reader_api.dart';

/// Records outgoing requests and answers them from [onRequest].
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.onRequest);

  final Map<String, dynamic> Function(RequestOptions options) onRequest;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(onRequest(options)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _RecordingAdapter adapter;
  late GoogleReaderApi api;

  GoogleReaderApi buildApi(
    Map<String, dynamic> Function(RequestOptions options) onRequest,
  ) {
    adapter = _RecordingAdapter(onRequest);
    final dio = Dio(BaseOptions(baseUrl: 'https://reader.example.com'))
      ..httpClientAdapter = adapter;
    return GoogleReaderApi(baseUrl: 'https://reader.example.com', dio: dio)
      ..setAuthToken('token');
  }

  group('getStreamContents', () {
    test('sends `ot` as unix seconds, not milliseconds', () async {
      api = buildApi((_) => {'id': 'stream', 'items': <dynamic>[]});

      // 2024-01-01T00:00:00Z
      const sinceSeconds = 1704067200;
      await api.getStreamContents(
        'user/-/state/com.google/reading-list',
        count: 1000,
        sinceTimestamp: sinceSeconds,
      );

      final request = adapter.requests.single;
      // Milliseconds here used to push the bound decades into the future,
      // which made the server return nothing.
      expect(request.queryParameters['ot'], '1704067200');
    });

    test('omits `ot` when no lower bound is given', () async {
      api = buildApi((_) => {'id': 'stream', 'items': <dynamic>[]});

      await api.getStreamContents('user/-/state/com.google/reading-list');

      expect(
          adapter.requests.single.queryParameters.containsKey('ot'), isFalse);
    });
  });

  group('getUnreadItemIds', () {
    test('follows the continuation so the id list is complete', () async {
      var page = 0;
      api = buildApi((_) {
        page++;
        if (page == 1) {
          return {
            'itemRefs': [
              {'id': 'a'},
              {'id': 'b'},
            ],
            'continuation': 'next-page',
          };
        }
        return {
          'itemRefs': [
            {'id': 'c'},
          ],
        };
      });

      final ids = await api.getUnreadItemIds();

      expect(ids, ['a', 'b', 'c']);
      expect(adapter.requests, hasLength(2));

      final first = adapter.requests.first;
      expect(
          first.queryParameters['s'], 'user/-/state/com.google/reading-list');
      expect(first.queryParameters['xt'], 'user/-/state/com.google/read');
      expect(first.queryParameters['n'], '1000');
      expect(first.queryParameters.containsKey('c'), isFalse);

      // "id not in the list" is used to mark articles read locally, so the
      // second (and all later) pages must be followed.
      expect(adapter.requests[1].queryParameters['c'], 'next-page');
    });

    test('stops after the first page when a count is given', () async {
      api = buildApi((_) => {
            'itemRefs': [
              {'id': 'a'},
            ],
            'continuation': 'next-page',
          });

      final ids = await api.getUnreadItemIds(count: 10);

      expect(ids, ['a']);
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.queryParameters['n'], '10');
    });
  });

  group('item parsing', () {
    test('uses the `alternate` link when `canonical` is absent', () async {
      api = buildApi((_) => {
            'id': 'stream',
            'items': [
              {
                'id': 'item-1',
                'title': 'No canonical',
                'alternate': [
                  {'href': 'https://example.com/article'}
                ],
                'categories': <String>[],
                'published': 1704067200,
              },
            ],
          });

      final contents =
          await api.getStreamContents('user/-/state/com.google/reading-list');

      expect(contents.items.single.canonical, isNull);
      expect(contents.items.single.alternateUrl, 'https://example.com/article');
    });
  });
}
