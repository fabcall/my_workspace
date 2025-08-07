import 'dart:async';
import 'dart:io';
import 'package:core_framework/src/logging/models/log_entry.dart';
import 'package:core_framework/src/logging/strategies/logging_strategy.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileStrategy implements LoggingStrategy {
  final LoggingConfig config;
  File? _currentFile;
  final List<LogEntry> _buffer = [];
  Timer? _flushTimer;

  FileStrategy({LoggingConfig? config})
    : config =
          config ??
          const LoggingConfig({
            'directory': 'logs',
            'maxFileSize': 10 * 1024 * 1024,
            'maxFiles': 7,
          });

  @override
  String get name => 'file';

  @override
  Future<void> initialize() async {
    await _setupFile();
    _startFlushTimer();
  }

  Future<void> _setupFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    final logDir = Directory(
      path.join(appDir.path, config.get<String>('directory')),
    );

    if (!logDir.existsSync()) {
      await logDir.create(recursive: true);
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);
    _currentFile = File(path.join(logDir.path, 'app_$today.log'));

    await _rotateIfNeeded();
    _cleanOldFiles(logDir);
  }

  void _startFlushTimer() {
    _flushTimer = Timer.periodic(const Duration(seconds: 5), (_) => _flush());
  }

  @override
  Future<void> writeLog(LogEntry entry) async {
    _buffer.add(entry);

    if (_buffer.length >= 50) {
      await _flush();
    }
  }

  Future<void> _flush() async {
    if (_buffer.isEmpty || _currentFile == null) return;

    final entries = List<LogEntry>.from(_buffer);
    _buffer.clear();

    final content = '${entries.map(_format).join('\n')}\n';
    await _currentFile!.writeAsString(content, mode: FileMode.append);
    await _rotateIfNeeded();
  }

  String _format(LogEntry entry) {
    final timestamp = entry.timestamp.toIso8601String();
    final tag = entry.tag != null ? '[${entry.tag}]' : '';

    var result =
        '[$timestamp][${entry.level.emoji} ${entry.level.name}]$tag ${entry.message}';

    if (entry.error != null) {
      result += '\n  Error: ${entry.error}';
    }

    if (entry.data != null) {
      result += '\n  Data: ${entry.data}';
    }

    return result;
  }

  Future<void> _rotateIfNeeded() async {
    if (_currentFile == null || !_currentFile!.existsSync()) return;

    final size = _currentFile!.lengthSync();
    final maxSize = config.get<int>('maxFileSize')!;

    if (size >= maxSize) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final currentPath = _currentFile!.path;
      final newPath = currentPath.replaceAll('.log', '_$timestamp.log');

      _currentFile!.renameSync(newPath);
      _currentFile = File(currentPath);
    }
  }

  void _cleanOldFiles(Directory logDir) {
    final files = <File>[];

    // Usar listSync para operação síncrona
    for (final entity in logDir.listSync()) {
      if (entity is File && entity.path.endsWith('.log')) {
        files.add(entity);
      }
    }

    files.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

    final maxFiles = config.get<int>('maxFiles')!;
    if (files.length > maxFiles) {
      final toDelete = files.take(files.length - maxFiles);
      for (final file in toDelete) {
        file.deleteSync();
      }
    }
  }

  @override
  Future<void> dispose() async {
    _flushTimer?.cancel();
    await _flush();
  }
}
