import 'package:core_framework/src/http/models/http_request.dart';

class HttpResponse<T> {
  final T data;
  final int? statusCode;
  final Map<String, dynamic>? headers;
  final HttpRequest? request;

  HttpResponse({
    required this.data,
    this.statusCode,
    this.headers,
    this.request,
  });

  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;
}
