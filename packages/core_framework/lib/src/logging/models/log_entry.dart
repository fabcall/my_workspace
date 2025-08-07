import 'package:core_framework/src/logging/models/log_level.dart';

class LogEntry {
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String? tag;
  final Object? error;
  final Map<String, dynamic>? data;

  const LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    this.tag,
    this.error,
    this.data,
  });

  Map<String, dynamic> toJson() => {
        'level': level.name,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'tag': tag,
        'error': error?.toString(),
        'data': data,
      };
}
