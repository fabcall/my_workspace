import 'package:core_framework/src/logging/models/log_entry.dart';
import 'package:core_framework/src/logging/models/log_level.dart';
import 'package:core_framework/src/logging/strategies/strategies.dart';

class Logger {
  final LoggingStrategy strategy;
  final LogLevel minLevel;

  // Singleton instance
  static Logger _instance = Logger._createDefault();

  // Private constructor
  Logger._(this.strategy, {this.minLevel = LogLevel.info});

  // Factory constructor for custom instances
  factory Logger(
    LoggingStrategy strategy, {
    LogLevel minLevel = LogLevel.info,
  }) {
    return Logger._(strategy, minLevel: minLevel);
  }

  // Creates default logger with console strategy (without initializing it)
  static Logger _createDefault() {
    final strategy = ConsoleStrategy();
    return Logger._(strategy, minLevel: LogLevel.info);
  }

  // Configure the global logger instance
  static Future<void> configure(
    LoggingStrategy strategy, {
    LogLevel minLevel = LogLevel.info,
  }) async {
    await strategy.initialize();
    _instance = Logger._(strategy, minLevel: minLevel);
  }

  // Get current logger instance
  static Logger get instance => _instance;

  // Reset to default logger (useful for testing)
  static void reset() {
    _instance = _createDefault();
  }

  // Private logging method (não é assíncrono)
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    Map<String, dynamic>? data,
  }) {
    if (level < minLevel) return;

    final entry = LogEntry(
      level: level,
      message: message,
      timestamp: DateTime.now(),
      tag: tag,
      error: error,
      data: data,
    );

    strategy.writeLog(entry);
  }

  // Future<void> flush() async {
  //   // Exemplo de flush assíncrono, se a estratégia suportar
  //   await strategy.flush();
  // }

  // Static convenience methods
  static void debug(
    String message, {
    String? tag,
    Object? error,
    Map<String, dynamic>? data,
  }) {
    _instance._log(LogLevel.debug, message, tag: tag, error: error, data: data);
  }

  static void info(
    String message, {
    String? tag,
    Object? error,
    Map<String, dynamic>? data,
  }) {
    _instance._log(LogLevel.info, message, tag: tag, error: error, data: data);
  }

  static void warning(
    String message, {
    String? tag,
    Object? error,
    Map<String, dynamic>? data,
  }) {
    _instance._log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      data: data,
    );
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    Map<String, dynamic>? data,
  }) {
    _instance._log(LogLevel.error, message, tag: tag, error: error, data: data);
  }

  // Static utility methods
  // static Future<void> flushLogs() async {
  //   await _instance.flush();
  // }

  static LogLevel get currentLevel => _instance.minLevel;
  static String get strategyName => _instance.strategy.name;
  static bool isLevelEnabled(LogLevel level) => level >= _instance.minLevel;
}
