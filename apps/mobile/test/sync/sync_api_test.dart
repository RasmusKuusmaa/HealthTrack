import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/sync/sync_api.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final ResponseBody Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _handler(options);
  }
}

ResponseBody _jsonResponse(int statusCode, Map<String, dynamic> body) {
  final bytes = utf8.encode(jsonEncode(body));
  return ResponseBody.fromBytes(
    bytes,
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  test('push posts the batch and returns the assigned server_seq values', () async {
    late RequestOptions capturedOptions;
    late Map<String, dynamic> capturedBody;

    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = _FakeAdapter((options) {
        capturedOptions = options;
        capturedBody = options.data as Map<String, dynamic>;
        return _jsonResponse(200, {
          'results': [
            {'client_op_id': 'op-1', 'server_seq': 7},
          ],
        });
      });

    final api = DioSyncApi(dio);
    final results = await api.push([
      PushOpRequest(
        clientOpId: 'op-1',
        entityType: 'weight_entry',
        entityId: 'e1',
        opType: 'create',
        payload: const {'weight_kg': 80},
        deviceId: 'device-1',
        clientTs: DateTime.utc(2026, 1, 1),
      ),
    ]);

    expect(capturedOptions.method, 'POST');
    expect(capturedOptions.path, '/sync/push');
    expect(capturedBody['ops'], hasLength(1));
    expect(capturedBody['ops'][0]['client_op_id'], 'op-1');
    expect(results, [isA<PushOpResult>()]);
    expect(results.single.clientOpId, 'op-1');
    expect(results.single.serverSeq, 7);
  });

  test('push wraps a failed request in a SyncApiException', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = _FakeAdapter((options) => _jsonResponse(500, {'detail': 'boom'}));

    final api = DioSyncApi(dio);

    await expectLater(
      api.push([
        PushOpRequest(
          clientOpId: 'op-1',
          entityType: 'weight_entry',
          entityId: 'e1',
          opType: 'create',
          payload: const {},
          deviceId: 'device-1',
          clientTs: DateTime.utc(2026, 1, 1),
        ),
      ]),
      throwsA(isA<SyncApiException>()),
    );
  });

  test('pull sends the since cursor and parses the returned page', () async {
    late RequestOptions capturedOptions;

    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = _FakeAdapter((options) {
        capturedOptions = options;
        return _jsonResponse(200, {
          'ops': [
            {
              'server_seq': 3,
              'client_op_id': 'op-9',
              'entity_type': 'weight_entry',
              'entity_id': 'e1',
              'op_type': 'update',
              'payload': {'weight_kg': 79},
              'device_id': 'device-2',
              'client_ts': '2026-01-01T00:00:00Z',
            },
          ],
          'next_cursor': 3,
        });
      });

    final api = DioSyncApi(dio);
    final page = await api.pull(since: 1, limit: 50);

    expect(capturedOptions.path, '/sync/pull');
    expect(capturedOptions.queryParameters['since'], 1);
    expect(capturedOptions.queryParameters['limit'], 50);
    expect(page.nextCursor, 3);
    expect(page.ops, hasLength(1));
    expect(page.ops.single.clientOpId, 'op-9');
    expect(page.ops.single.payload, {'weight_kg': 79});
  });

  test('pull wraps a failed request in a SyncApiException', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = _FakeAdapter((options) => _jsonResponse(500, {'detail': 'boom'}));

    final api = DioSyncApi(dio);

    await expectLater(
      api.pull(since: 0),
      throwsA(isA<SyncApiException>()),
    );
  });
}
