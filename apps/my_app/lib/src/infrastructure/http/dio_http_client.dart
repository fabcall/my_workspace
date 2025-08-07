import 'dart:io';

import 'package:core_framework/core_framework.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_parser/http_parser.dart';
import 'package:meta/meta.dart';
import 'package:my_app/src/infrastructure/http/interceptors/auth_interceptor.dart';
import 'package:my_app/src/infrastructure/http/interceptors/logging_interceptor.dart';
import 'package:my_app/src/infrastructure/http/interceptors/retry_interceptor.dart';

class DioHttpClient implements HttpClient {
  final dio.Dio _dio = dio.Dio();
  final AuthInterceptor _authInterceptor = AuthInterceptor();
  late LoggingInterceptor _loggingInterceptor;
  late final CacheOptions _cacheOptions;

  final Map<String, dio.CancelToken> _cancelTokens = {};

  @override
  final String baseUrl;

  @override
  final int defaultTimeout;

  DioHttpClient({
    required this.baseUrl,
    this.defaultTimeout = 30000,
    bool enableLogging = false,
    bool Function()? shouldRetry,
    Map<String, String>? defaultHeaders,
  }) {
    _loggingInterceptor = LoggingInterceptor(enableLogging: enableLogging);

    _cacheOptions = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.noCache,
      hitCacheOnErrorCodes: [
        401,
        403,
      ],
      maxStale: const Duration(days: 1),
    );

    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = Duration(milliseconds: defaultTimeout)
      ..receiveTimeout = Duration(milliseconds: defaultTimeout)
      ..sendTimeout = Duration(milliseconds: defaultTimeout)
      ..validateStatus = (status) => true;

    if (defaultHeaders != null) {
      _dio.options.headers.addAll(defaultHeaders);
    }

    _dio.interceptors.addAll([
      _authInterceptor,
      _loggingInterceptor,
      DioCacheInterceptor(options: _cacheOptions),
      RetryInterceptor(dio: _dio, shouldRetry: shouldRetry),
    ]);
  }

  @override
  void configure({
    Map<String, String>? defaultHeaders,
    String? baseUrl,
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
    bool enableLogging = false, // Default matches constructor's typical use
    bool Function()? shouldRetry,
  }) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
    if (connectTimeout != null) {
      _dio.options.connectTimeout = Duration(milliseconds: connectTimeout);
    }
    if (receiveTimeout != null) {
      _dio.options.receiveTimeout = Duration(milliseconds: receiveTimeout);
    }
    if (sendTimeout != null) {
      _dio.options.sendTimeout = Duration(milliseconds: sendTimeout);
    }
    if (defaultHeaders != null) _dio.options.headers.addAll(defaultHeaders);

    // Update logging interceptor
    _dio.interceptors.removeWhere((i) => i is LoggingInterceptor);
    _loggingInterceptor = LoggingInterceptor(enableLogging: enableLogging);
    _dio.interceptors.insert(1, _loggingInterceptor); // Insert after auth

    // Update retry interceptor
    if (shouldRetry != null) {
      _dio.interceptors.removeWhere((i) => i is RetryInterceptor);
      _dio.interceptors.add(
        RetryInterceptor(
          dio: _dio,
          shouldRetry: shouldRetry,
        ),
      ); // Add at the end
    }
  }

  @override
  void setAuthToken(String token) => _authInterceptor.setToken(token);

  @override
  void clearAuthToken() => _authInterceptor.clearToken();

  @override
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    HttpRequestConfig? config,
    T Function(dynamic data)? converter,
  }) => request<T>(
    path,
    queryParameters: queryParameters,
    config: config,
    converter: converter,
  );

  @override
  Future<HttpResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    HttpRequestConfig? config,
    T Function(dynamic data)? converter,
  }) => request<T>(
    path,
    method: 'POST',
    data: data,
    queryParameters: queryParameters,
    config: config,
    converter: converter,
  );

  @override
  Future<HttpResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    HttpRequestConfig? config,
    T Function(dynamic data)? converter,
  }) => request<T>(
    path,
    method: 'PUT',
    data: data,
    queryParameters: queryParameters,
    config: config,
    converter: converter,
  );

  @override
  Future<HttpResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    HttpRequestConfig? config,
    T Function(dynamic data)? converter,
  }) => request<T>(
    path,
    method: 'PATCH',
    data: data,
    queryParameters: queryParameters,
    config: config,
    converter: converter,
  );

  @override
  Future<HttpResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    HttpRequestConfig? config,
    T Function(dynamic data)? converter,
  }) => request<T>(
    path,
    method: 'DELETE',
    data: data,
    queryParameters: queryParameters,
    config: config,
    converter: converter,
  );

  @override
  Future<HttpResponse<T>> request<T>(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    HttpRequestConfig? config,
    T Function(dynamic data)? converter,
  }) async {
    final currentConfig = config ?? const HttpRequestConfig();

    final options = dio.Options(
      method: method,
      headers: currentConfig.headers,
      sendTimeout: currentConfig.timeout != null
          ? Duration(milliseconds: currentConfig.timeout!)
          : null,
      receiveTimeout: currentConfig.timeout != null
          ? Duration(milliseconds: currentConfig.timeout!)
          : null,
      extra: {'ignoreAuthToken': currentConfig.ignoreAuthToken},
    );

    if (currentConfig.useCache) {
      options.extra!.addAll(
        _cacheOptions
            .copyWith(
              policy: CachePolicy.forceCache,
              maxStale: currentConfig.cacheDuration,
              keyBuilder: ({required url, headers}) =>
                  currentConfig.cacheKey ??
                  _cacheOptions.keyBuilder(
                    url: url,
                    headers: headers,
                  ),
            )
            .toExtra(),
      );
    }

    dio.CancelToken? cancelToken;
    if (currentConfig.cancelable) {
      final tokenKey = currentConfig.cancelToken ?? path;
      cancelToken = _cancelTokens.putIfAbsent(tokenKey, dio.CancelToken.new);
    }

    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: currentConfig.onSendProgress,
        onReceiveProgress: currentConfig.onReceiveProgress,
      );

      final T convertedData;
      try {
        convertedData = converter != null
            ? converter(response.data)
            : response.data as T;
      } catch (e) {
        if (response.statusCode! >= 200 && response.statusCode! < 300) {
          throw ServerException(
            message: 'Failed to convert successful response data: $e',
            path: path,
            method: method,
            statusCode: response.statusCode,
            data: response.data,
          );
        }
        rethrow;
      }

      final httpResponse = HttpResponse<T>(
        data: convertedData,
        statusCode: response.statusCode,
        headers: response.headers.map,
        request: HttpRequest(
          path: path,
          method: method,
          data: data,
          queryParameters: queryParameters,
        ),
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return httpResponse;
      }

      if (!currentConfig.throwOnError) {
        return httpResponse;
      }

      _handleErrorResponse(response, path, method);

      throw ServerException(
        message: 'Unhandled error after response processing.',
        statusCode: response.statusCode,
        path: path,
        method: method,
        data: response.data,
      );
    } on dio.DioException catch (e) {
      throw _handleDioException(e, path, method);
    } on HttpException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'An unexpected error occurred: $e',
        path: path,
        method: method,
      );
    } finally {
      if (currentConfig.cancelable && currentConfig.cancelToken != null) {
        _cancelTokens.remove(currentConfig.cancelToken);
      }
    }
  }

  @override
  Future<HttpResponse<T>> upload<T>(
    String path, {
    required List<MultipartFile> files,
    Map<String, dynamic>? data,
    String method = 'POST',
    HttpRequestConfig? config,
    T Function(dynamic data)? converter,
  }) async {
    final formData = dio.FormData();
    for (final file in files) {
      formData.files.add(
        MapEntry(
          file.fieldName,
          dio.MultipartFile.fromBytes(
            file.bytes,
            filename: file.fileName,
            contentType: MediaType.parse(file.contentType),
          ),
        ),
      );
    }
    data?.forEach((key, value) {
      if (value != null) formData.fields.add(MapEntry(key, value.toString()));
    });

    return request<T>(
      path,
      method: method,
      data: formData,
      config: config,
      converter: converter,
    );
  }

  @override
  Future<HttpResponse<List<int>>> download(
    String path, {
    String? savePath,
    Map<String, dynamic>? queryParameters,
    void Function(int received, int total)? onReceiveProgress,
    HttpRequestConfig? config,
  }) async {
    final currentConfig = config ?? const HttpRequestConfig();
    final options = dio.Options(
      method: 'GET',
      headers: currentConfig.headers,
      sendTimeout: currentConfig.timeout != null
          ? Duration(milliseconds: currentConfig.timeout!)
          : null,
      receiveTimeout: currentConfig.timeout != null
          ? Duration(milliseconds: currentConfig.timeout!)
          : null,
      responseType: savePath == null ? dio.ResponseType.bytes : null,
      extra: {'ignoreAuthToken': currentConfig.ignoreAuthToken},
    );

    dio.CancelToken? cancelToken;
    if (currentConfig.cancelable) {
      final tokenKey = currentConfig.cancelToken ?? path;
      cancelToken = _cancelTokens.putIfAbsent(tokenKey, dio.CancelToken.new);
    }

    try {
      if (savePath != null) {
        await _dio.download(
          path,
          savePath,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
        final bytes = await File(savePath).readAsBytes();
        return HttpResponse<List<int>>(
          data: bytes,
          statusCode: 200,
          headers: {},
          request: HttpRequest(
            path: path,
            method: 'GET',
            queryParameters: queryParameters,
          ),
        );
      } else {
        final response = await _dio.get<List<int>>(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
        return HttpResponse<List<int>>(
          data: response.data ?? [],
          statusCode: response.statusCode,
          headers: response.headers.map,
          request: HttpRequest(
            path: path,
            method: 'GET',
            queryParameters: queryParameters,
          ),
        );
      }
    } on dio.DioException catch (e) {
      throw _handleDioException(e, path, 'GET');
    } catch (e) {
      throw ServerException(
        message: 'File download error: $e',
        path: path,
        method: 'GET',
      );
    } finally {
      if (currentConfig.cancelable && currentConfig.cancelToken != null) {
        _cancelTokens.remove(currentConfig.cancelToken);
      }
    }
  }

  @override
  void cancelRequests({String? reason}) {
    final cancelReason = reason ?? 'Requests cancelled by user';
    _cancelTokens
      ..forEach((key, token) {
        if (!token.isCancelled) token.cancel(cancelReason);
      })
      ..clear();
  }

  @protected
  void _handleErrorResponse(
    dio.Response<dynamic> response,
    String path,
    String method,
  ) {
    final statusCode = response.statusCode;
    if (statusCode == null || statusCode < 400) {
      return;
    }

    if (statusCode == 401) {
      throw UnauthorizedException(path: path, method: method);
    }
    if (statusCode == 403) {
      throw UnauthorizedException(
        message:
            'Access denied. You do not have permission to access this resource.',
        path: path,
        method: method,
      );
    }
    if (statusCode == 404) {
      throw ServerException(
        message: 'Resource not found.',
        statusCode: statusCode,
        path: path,
        method: method,
      );
    }

    if (statusCode == 422) {
      final errors = <String, List<String>>{};
      var errorMessage = 'The provided data is invalid.';

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        errorMessage = responseData['message'] as String? ?? errorMessage;

        if (responseData['errors'] is Map) {
          (responseData['errors'] as Map).forEach((key, value) {
            if (key is String) {
              errors[key] = value is List
                  ? value.map((e) => e.toString()).toList()
                  : [value.toString()];
            }
          });
        }
      }
      throw ValidationException(
        message: errorMessage,
        errors: errors.isNotEmpty ? errors : null,
        path: path,
        method: method,
        data: response.data,
      );
    }

    if (statusCode >= 500 && statusCode < 600) {
      throw ServerException(
        statusCode: statusCode,
        path: path,
        method: method,
        data: response.data,
      );
    }

    var errorMessage = 'An error occurred with the request.';
    if (response.data is Map<String, dynamic> &&
        response.data['message'] is String) {
      errorMessage = response.data['message'] as String;
    } else if (response.statusMessage != null &&
        response.statusMessage!.isNotEmpty) {
      errorMessage = response.statusMessage!;
    }

    throw ServerException(
      message: errorMessage,
      statusCode: statusCode,
      path: path,
      method: method,
      data: response.data,
    );
  }

  @protected
  HttpException _handleDioException(
    dio.DioException e,
    String path,
    String method,
  ) {
    switch (e.type) {
      case dio.DioExceptionType.connectionTimeout:
      case dio.DioExceptionType.sendTimeout:
      case dio.DioExceptionType.receiveTimeout:
        return TimeoutException(path: path, method: method);
      case dio.DioExceptionType.connectionError:
      case dio.DioExceptionType.badCertificate:
        return ConnectionException(
          message: e.message ?? 'Connection error',
          path: path,
          method: method,
        );
      case dio.DioExceptionType.badResponse:
        if (e.response != null) {
          try {
            _handleErrorResponse(e.response!, path, method);
            return ServerException(
              message:
                  'Bad response from server, but not handled as a specific error.',
              statusCode: e.response?.statusCode,
              path: path,
              method: method,
              data: e.response?.data,
            );
          } on HttpException catch (he) {
            return he;
          }
        }
        return ServerException(
          message: 'Invalid response from server.',
          statusCode: e.response?.statusCode,
          path: path,
          method: method,
          data: e.response?.data,
        );
      case dio.DioExceptionType.cancel:
        return CancellationException(path: path, method: method);
      case dio.DioExceptionType.unknown:
        if (e.error is SocketException || e.error is HandshakeException) {
          return ConnectionException(
            message: e.message ?? 'Network error',
            path: path,
            method: method,
          );
        }
        return ServerException(
          message: e.message ?? 'An unknown error occurred.',
          path: path,
          method: method,
          data: e.error,
        );
    }
  }
}
