import 'package:core_framework/src/http/models/http_request_config.dart';
import 'package:core_framework/src/http/models/http_response.dart';
import 'package:core_framework/src/http/models/multipart_file.dart';

/// Interface para clientes HTTP
abstract class HttpClient {
  /// Configura a URL base para todas as requisições
  String get baseUrl;

  /// Define o timeout padrão para requisições em milissegundos
  int get defaultTimeout;

  /// Configura o cliente HTTP
  void configure({
    Map<String, String>? defaultHeaders,
    String? baseUrl,
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
    bool enableLogging = false,
    bool Function()? shouldRetry,
  });

  /// Configura o token de autenticação
  void setAuthToken(String token);

  /// Remove o token de autenticação
  void clearAuthToken();

  /// Requisição GET
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    HttpRequestConfig? config,
    T Function(dynamic data)? converter,
  });

  /// Requisição POST
  Future<HttpResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    HttpRequestConfig? config,
    T Function(dynamic data)? converter,
  });

  /// Requisição PUT
  Future<HttpResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    HttpRequestConfig? config,
    T Function(dynamic data)? converter,
  });

  /// Requisição PATCH
  Future<HttpResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    HttpRequestConfig? config,
    T Function(dynamic data)? converter,
  });

  /// Requisição DELETE
  Future<HttpResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    HttpRequestConfig? config,
    T Function(dynamic data)? converter,
  });

  /// Requisição genérica
  Future<HttpResponse<T>> request<T>(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    HttpRequestConfig? config,
    T Function(dynamic data)? converter,
  });

  /// Upload de arquivos
  Future<HttpResponse<T>> upload<T>(
    String path, {
    required List<MultipartFile> files,
    Map<String, dynamic>? data,
    String method = 'POST',
    HttpRequestConfig? config,
    T Function(dynamic data)? converter,
  });

  /// Download de arquivos
  Future<HttpResponse<List<int>>> download(
    String path, {
    String? savePath,
    Map<String, dynamic>? queryParameters,
    void Function(int received, int total)? onReceiveProgress,
    HttpRequestConfig? config,
  });

  /// Cancela todas as requisições em andamento
  void cancelRequests({String? reason});
}

// packages/core_framework/lib/src/storage/storage_client.dart
/// Interface para clientes de armazenamento
