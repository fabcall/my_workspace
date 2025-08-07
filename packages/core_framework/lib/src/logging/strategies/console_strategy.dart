import 'dart:developer' as developer;

import 'package:core_framework/src/logging/models/log_entry.dart';
import 'package:core_framework/src/logging/models/log_level.dart';
import 'package:core_framework/src/logging/strategies/logging_strategy.dart';

class ConsoleStrategy implements LoggingStrategy {
  final LoggingConfig config;
  bool _enableColors = true;

  ConsoleStrategy({LoggingConfig? config})
    : config = config ?? const LoggingConfig({});

  @override
  String get name => 'console';

  @override
  Future<void> initialize() async {
    _enableColors = config.get<bool>('enableColors') ?? true;
  }

  @override
  Future<void> writeLog(LogEntry entry) async {
    final formatted = _format(entry);

    developer.log(formatted, name: 'Logger', level: entry.level.value);
  }

  String _format(LogEntry entry) {
    final timestamp = entry.timestamp.toString().substring(11, 23);
    final level = _enableColors
        ? _colorize(entry.level)
        : '${entry.level.emoji} ${entry.level.name}';
    final tag = entry.tag != null ? '[${entry.tag}]' : '';

    var result = '[$timestamp][$level]$tag ${entry.message}';

    if (entry.error != null) {
      result += '\n  💥 ${entry.error}';
    }

    return result;
  }

  String _colorize(LogLevel level) {
    const reset = '\x1B[0m';
    const colors = {
      LogLevel.debug: '\x1B[36m',
      LogLevel.info: '\x1B[32m',
      LogLevel.warning: '\x1B[33m',
      LogLevel.error: '\x1B[31m',
    };

    final color = colors[level] ?? '';
    return '$color${level.emoji} ${level.name}$reset';
  }

  @override
  Future<void> dispose() async {}
}
