import 'package:core_framework/src/logging/logger.dart';
import 'package:core_framework/src/logging/models/log_level.dart';
import 'package:core_framework/src/logging/strategies/strategies.dart';

/// Factory for configuring the global Logger with different strategies
class LoggerFactory {
  /// Configures global logger with console strategy
  static Future<void> configureConsole({
    LogLevel minLevel = LogLevel.info,
    bool enableColors = true,
  }) async {
    final strategy = ConsoleStrategy(
      config: LoggingConfig({'enableColors': enableColors}),
    );
    await Logger.configure(strategy, minLevel: minLevel);
  }

  static Future<void> configureFile({
    LogLevel minLevel = LogLevel.info,
    String directory = 'logs',
    int maxFileSize = 10 * 1024 * 1024, // 10MB
    int maxFiles = 7,
  }) async {
    final strategy = FileStrategy(
      config: LoggingConfig({
        'directory': directory,
        'maxFileSize': maxFileSize,
        'maxFiles': maxFiles,
      }),
    );
    await Logger.configure(strategy, minLevel: minLevel);
  }

  /// Configures global logger with composite strategy
  static Future<void> configureComposite(
    List<LoggingStrategy> strategies, {
    LogLevel minLevel = LogLevel.info,
  }) async {
    final strategy = CompositeStrategy(strategies);
    await Logger.configure(strategy, minLevel: minLevel);
  }

  // Add more convenience methods as needed for other strategies
}
