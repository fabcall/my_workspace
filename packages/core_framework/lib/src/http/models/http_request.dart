class HttpRequest {
  final String path;
  final String method;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;

  HttpRequest({
    required this.path,
    required this.method,
    this.data,
    this.queryParameters,
  });
}
