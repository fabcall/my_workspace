abstract class HttpException implements Exception {
  final String message;
  final int? statusCode;
  final String? path;
  final String? method;
  final dynamic data;

  HttpException(
    this.message, {
    this.statusCode,
    this.path,
    this.method,
    this.data,
  });

  @override
  String toString() => 'HttpException: $message';
}

class ConnectionException extends HttpException {
  ConnectionException({
    String message =
        'Unable to connect to the server. Please check your internet connection.',
    String? path,
    String? method,
  }) : super(message, path: path, method: method);
}

class TimeoutException extends HttpException {
  TimeoutException({
    String message = 'The request timed out. Please try again later.',
    String? path,
    String? method,
  }) : super(message, path: path, method: method);
}

class ServerException extends HttpException {
  ServerException({
    String message = 'A server error occurred. Please try again later.',
    int? statusCode,
    String? path,
    String? method,
    dynamic data,
  }) : super(
         message,
         statusCode: statusCode,
         path: path,
         method: method,
         data: data,
       );
}

class UnauthorizedException extends HttpException {
  UnauthorizedException({
    String message = 'Unauthorized access. Please log in again.',
    String? path,
    String? method,
  }) : super(message, statusCode: 401, path: path, method: method);
}

class ValidationException extends HttpException {
  final Map<String, List<String>>? errors;

  ValidationException({
    String message = 'The provided data is invalid.',
    this.errors,
    String? path,
    String? method,
    dynamic data,
  }) : super(message, statusCode: 422, path: path, method: method, data: data);
}

class CancellationException extends HttpException {
  CancellationException({
    String message = 'The request was canceled.',
    String? path,
    String? method,
  }) : super(message, path: path, method: method);
}
