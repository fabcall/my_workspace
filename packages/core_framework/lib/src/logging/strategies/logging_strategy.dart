import 'package:core_framework/src/logging/models/log_entry.dart';

abstract class LoggingStrategy {
  String get name;
  Future<void> initialize();
  Future<void> writeLog(LogEntry entry);
  Future<void> dispose();
}

class LoggingConfig {
  final Map<String, dynamic> data;
  const LoggingConfig(this.data);
  T? get<T>(String key) => data[key] as T?;
}
