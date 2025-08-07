import 'package:core_framework/src/logging/models/log_entry.dart';
import 'package:core_framework/src/logging/strategies/logging_strategy.dart';

class CompositeStrategy implements LoggingStrategy {
  final List<LoggingStrategy> strategies;

  CompositeStrategy(this.strategies);

  @override
  String get name => 'composite[${strategies.map((s) => s.name).join(',')}]';

  @override
  Future<void> initialize() async {
    await Future.wait(strategies.map((s) => s.initialize()));
  }

  @override
  Future<void> writeLog(LogEntry entry) async {
    await Future.wait(strategies.map((s) => s.writeLog(entry)));
  }

  @override
  Future<void> dispose() async {
    await Future.wait(strategies.map((s) => s.dispose()));
  }
}
