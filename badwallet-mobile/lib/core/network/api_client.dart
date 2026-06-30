import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import 'api_error_mapper.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? Dio() {
    _dio
      ..options.baseUrl = ApiConfig.baseUrl
      ..options.connectTimeout = ApiConfig.connectTimeout
      ..options.receiveTimeout = ApiConfig.receiveTimeout
      ..options.sendTimeout = ApiConfig.sendTimeout
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
      ..options.validateStatus = (status) => status != null && status < 400;

    _dio.interceptors.add(_loggingAndErrorInterceptor());
  }

  final Dio _dio;

  Dio get raw => _dio;

  InterceptorsWrapper _loggingAndErrorInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          debugPrint(' [BadWallet] ${options.method} ${options.uri}');
          if (options.data != null) {
            debugPrint('    body: ${options.data}');
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint(
            ' [BadWallet] ${response.statusCode} '
            '${response.requestOptions.method} ${response.requestOptions.uri}',
          );
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          final status = error.response?.statusCode;
          final uri = error.requestOptions.uri;
          final msg = error.response?.data is Map
              ? (error.response?.data as Map)['message']
              : error.message;
          debugPrint('[BadWallet] ${status ?? 'NO_RESPONSE'} $uri -> $msg');
        }
        handler.next(error);
      },
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(() => _dio.get(path, queryParameters: queryParameters));
  }

  Future<dynamic> post(String path, {Object? data}) async {
    return _request(() => _dio.post(path, data: data));
  }

  Future<dynamic> put(String path, {Object? data}) async {
    return _request(() => _dio.put(path, data: data));
  }

  Future<dynamic> delete(String path, {Object? data}) async {
    return _request(() => _dio.delete(path, data: data));
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() run) async {
    try {
      final response = await run();
      return response.data;
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDio(e);
    } catch (e) {
      throw ApiException(message: 'Erreur inattendue : $e');
    }
  }
}
