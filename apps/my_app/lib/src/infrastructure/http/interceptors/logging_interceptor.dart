import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  final bool enableLogging;

  LoggingInterceptor({this.enableLogging = false});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enableLogging) {
      print('┌── 🌐 Request: ${options.method} ${options.path}');
      print('│ Headers: ${options.headers}');
      print('│ Query Parameters: ${options.queryParameters}');
      if (options.data != null) {
        print('│ Body: ${options.data}');
      }
      print('└── End Request');
    }
    return handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (enableLogging) {
      print(
          '┌── 🌐 Response: ${response.statusCode} ${response.requestOptions.path}');
      print('│ Headers: ${response.headers}');
      print('│ Body: ${response.data}');
      print('└── End Response');
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enableLogging) {
      print(
          '┌── ❌ Error: ${err.response?.statusCode} ${err.requestOptions.path}');
      print('│ Message: ${err.message}');
      print('│ Response: ${err.response?.data}');
      print('└── End Error');
    }
    return handler.next(err);
  }
}
