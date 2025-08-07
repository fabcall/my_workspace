class HttpRequestConfig {
  final Map<String, String>? headers;
  final int? timeout;
  final bool ignoreAuthToken;
  final bool throwOnError;
  final bool useCache;
  final Duration? cacheDuration;
  final String? cacheKey;
  final bool cancelable;
  final String? cancelToken;
  final void Function(int, int)? onSendProgress;
  final void Function(int, int)? onReceiveProgress;

  const HttpRequestConfig({
    this.headers,
    this.timeout,
    this.ignoreAuthToken = false,
    this.throwOnError = true,
    this.useCache = false,
    this.cacheDuration,
    this.cacheKey,
    this.cancelable = true,
    this.cancelToken,
    this.onSendProgress,
    this.onReceiveProgress,
  });
}
