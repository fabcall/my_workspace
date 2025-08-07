/// Base exception for storage operations
class StorageException implements Exception {
  final String message;
  final String? key;
  final String? operation;
  final dynamic originalError;

  StorageException({
    required this.message,
    this.key,
    this.operation,
    this.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('StorageException: $message');

    if (key != null) {
      buffer.write(' (key: $key)');
    }

    if (operation != null) {
      buffer.write(' (operation: $operation)');
    }

    if (originalError != null) {
      buffer.write(' - Original error: $originalError');
    }

    return buffer.toString();
  }
}
