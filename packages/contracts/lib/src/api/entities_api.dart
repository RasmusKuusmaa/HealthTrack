//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

// ignore: unused_import
import 'dart:convert';
import 'package:healthtrack_api_client/src/deserialize.dart';
import 'package:dio/dio.dart';

import 'package:healthtrack_api_client/src/model/entity_history_response.dart';
import 'package:healthtrack_api_client/src/model/http_validation_error.dart';
import 'package:healthtrack_api_client/src/model/push_op_result.dart';
import 'package:healthtrack_api_client/src/model/revert_request.dart';

class EntitiesApi {

  final Dio _dio;

  const EntitiesApi(this._dio);

  /// Entity History
  /// 
  ///
  /// Parameters:
  /// * [entityType] 
  /// * [entityId] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [EntityHistoryResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<EntityHistoryResponse>> entityHistoryEntitiesEntityTypeEntityIdHistoryGet({ 
    required String entityType,
    required String entityId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/entities/{entity_type}/{entity_id}/history'.replaceAll('{' r'entity_type' '}', entityType.toString()).replaceAll('{' r'entity_id' '}', entityId.toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'HTTPBearer',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    EntityHistoryResponse? _responseData;

    try {
final rawData = _response.data;
_responseData = rawData == null ? null : deserialize<EntityHistoryResponse, EntityHistoryResponse>(rawData, 'EntityHistoryResponse', growable: true);

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<EntityHistoryResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Revert Entity
  /// Restore an entity&#39;s fields to their state as of a prior point in its history. This does not rewrite history — it emits a brand new UPDATE op (through the normal push pipeline) setting the current fields back to those prior values, and shows up as its own entry in future history queries. See docs/sync-protocol.md.
  ///
  /// Parameters:
  /// * [entityType] 
  /// * [entityId] 
  /// * [revertRequest] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PushOpResult] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PushOpResult>> revertEntityEntitiesEntityTypeEntityIdRevertPost({ 
    required String entityType,
    required String entityId,
    required RevertRequest revertRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/entities/{entity_type}/{entity_id}/revert'.replaceAll('{' r'entity_type' '}', entityType.toString()).replaceAll('{' r'entity_id' '}', entityId.toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'HTTPBearer',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      _bodyData = jsonEncode(revertRequest);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PushOpResult? _responseData;

    try {
final rawData = _response.data;
_responseData = rawData == null ? null : deserialize<PushOpResult, PushOpResult>(rawData, 'PushOpResult', growable: true);

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PushOpResult>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

}
