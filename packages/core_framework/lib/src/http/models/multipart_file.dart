import 'dart:io';

class MultipartFile {
  /// Nome do campo no formulário
  final String fieldName;

  /// Nome do arquivo
  final String fileName;

  /// Bytes do arquivo
  final List<int> bytes;

  /// Tipo de conteúdo
  final String contentType;

  MultipartFile({
    required this.fieldName,
    required this.fileName,
    required this.bytes,
    this.contentType = 'application/octet-stream',
  });

  /// Cria um MultipartFile a partir de um arquivo
  static Future<MultipartFile> fromFile(
    String path, {
    required String fieldName,
    String? fileName,
    String contentType = 'application/octet-stream',
  }) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    return MultipartFile(
      fieldName: fieldName,
      fileName: fileName ?? path.split('/').last,
      bytes: bytes,
      contentType: contentType,
    );
  }
}
