import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;
  final bool Function()? shouldRetry;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.shouldRetry,
  });

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (shouldRetry == null || !shouldRetry!()) {
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;

    if (_shouldRetry(err) && requestOptions.retryAttempts < maxRetries) {
      requestOptions.retryAttempts++;

      // Aguarda antes de tentar novamente
      await Future<void>.delayed(retryDelay * requestOptions.retryAttempts);

      // Tenta novamente com as mesmas opções
      try {
        final response = await dio.fetch<dynamic>(requestOptions);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500 &&
            error.response!.statusCode! < 600);
  }
}

// Extensão para adicionar o contador de tentativas
extension RequestOptionsExtension on RequestOptions {
  int get retryAttempts => int.tryParse(extra['retryAttempts'].toString()) ?? 0;

  set retryAttempts(int attempts) {
    extra['retryAttempts'] = attempts;
  }
}
