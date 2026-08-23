import 'package:dio/dio.dart';

/// One op in a `POST /sync/push` request body — mirrors
/// `services/api/src/app/schemas/sync.py::PushOpRequest`.
class PushOpRequest {
  const PushOpRequest({
    required this.clientOpId,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.payload,
    required this.deviceId,
    required this.clientTs,
  });

  final String clientOpId;
  final String entityType;
  final String entityId;
  final String opType;
  final Map<String, dynamic> payload;
  final String deviceId;
  final DateTime clientTs;

  Map<String, dynamic> toJson() => {
    'client_op_id': clientOpId,
    'entity_type': entityType,
    'entity_id': entityId,
    'op_type': opType,
    'payload': payload,
    'device_id': deviceId,
    'client_ts': clientTs.toUtc().toIso8601String(),
  };
}

/// Mirrors `PushOpResult`: the server_seq the server assigned to one pushed op.
class PushOpResult {
  const PushOpResult({required this.clientOpId, required this.serverSeq});

  factory PushOpResult.fromJson(Map<String, dynamic> json) {
    return PushOpResult(
      clientOpId: json['client_op_id'] as String,
      serverSeq: json['server_seq'] as int,
    );
  }

  final String clientOpId;
  final int serverSeq;
}

/// Mirrors `PulledOp`, one op returned by `GET /sync/pull`.
class PulledOp {
  const PulledOp({
    required this.serverSeq,
    required this.clientOpId,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.payload,
    required this.deviceId,
    required this.clientTs,
  });

  factory PulledOp.fromJson(Map<String, dynamic> json) {
    return PulledOp(
      serverSeq: json['server_seq'] as int,
      clientOpId: json['client_op_id'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      opType: json['op_type'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      deviceId: json['device_id'] as String,
      clientTs: DateTime.parse(json['client_ts'] as String),
    );
  }

  final int serverSeq;
  final String clientOpId;
  final String entityType;
  final String entityId;
  final String opType;
  final Map<String, dynamic> payload;
  final String deviceId;
  final DateTime clientTs;
}

/// Mirrors `PullResponse`.
class PullPage {
  const PullPage({required this.ops, required this.nextCursor});

  factory PullPage.fromJson(Map<String, dynamic> json) {
    return PullPage(
      ops: (json['ops'] as List<dynamic>)
          .map((e) => PulledOp.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as int,
    );
  }

  final List<PulledOp> ops;
  final int nextCursor;
}

/// Mirrors `BootstrapResponse`: a full compacted snapshot of every entity
/// the caller owns, plus the cursor to resume incremental pulls from.
class BootstrapSnapshot {
  const BootstrapSnapshot({required this.entities, required this.cursor});

  factory BootstrapSnapshot.fromJson(Map<String, dynamic> json) {
    final rawEntities = json['entities'] as Map<String, dynamic>;
    return BootstrapSnapshot(
      entities: rawEntities.map(
        (entityType, rows) => MapEntry(
          entityType,
          (rows as List<dynamic>).cast<Map<String, dynamic>>(),
        ),
      ),
      cursor: json['cursor'] as int,
    );
  }

  /// entity_type -> that type's live rows, each a plain field-name/value
  /// map including `id`.
  final Map<String, List<Map<String, dynamic>>> entities;
  final int cursor;
}

/// Wraps a failed call to the sync HTTP endpoints.
class SyncApiException implements Exception {
  SyncApiException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'SyncApiException: $message';
}

abstract class SyncApi {
  Future<List<PushOpResult>> push(List<PushOpRequest> ops);

  Future<PullPage> pull({required int since, int? limit});

  Future<BootstrapSnapshot> bootstrap();
}

class DioSyncApi implements SyncApi {
  DioSyncApi(this._dio);

  final Dio _dio;

  @override
  Future<List<PushOpResult>> push(List<PushOpRequest> ops) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/sync/push',
        data: {'ops': ops.map((op) => op.toJson()).toList()},
      );
      final results = response.data!['results'] as List<dynamic>;
      return results
          .map((e) => PushOpResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw SyncApiException('Failed to push operations.', cause: e);
    }
  }

  @override
  Future<PullPage> pull({required int since, int? limit}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/sync/pull',
        queryParameters: {'since': since, 'limit': ?limit},
      );
      return PullPage.fromJson(response.data!);
    } on DioException catch (e) {
      throw SyncApiException('Failed to pull operations.', cause: e);
    }
  }

  @override
  Future<BootstrapSnapshot> bootstrap() async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/sync/bootstrap');
      return BootstrapSnapshot.fromJson(response.data!);
    } on DioException catch (e) {
      throw SyncApiException('Failed to bootstrap.', cause: e);
    }
  }
}
