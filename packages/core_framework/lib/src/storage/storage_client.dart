abstract class StorageClient {
  /// Inicializa o cliente de armazenamento
  Future<void> initialize();

  /// Armazena um valor string
  Future<bool> setString(String key, String value);

  /// Obtém um valor string
  Future<String?> getString(String key);

  /// Armazena um valor int
  Future<bool> setInt(String key, int value);

  /// Obtém um valor int
  Future<int?> getInt(String key);

  /// Armazena um valor double
  Future<bool> setDouble(String key, double value);

  /// Obtém um valor double
  Future<double?> getDouble(String key);

  /// Armazena um valor bool
  Future<bool> setBool(String key, bool value);

  /// Obtém um valor bool
  Future<bool?> getBool(String key);

  /// Armazena uma lista de strings
  Future<bool> setStringList(String key, List<String> value);

  /// Obtém uma lista de strings
  Future<List<String>?> getStringList(String key);

  /// Verifica se uma chave existe
  Future<bool> containsKey(String key);

  /// Remove uma chave específica
  Future<bool> remove(String key);

  /// Remove todas as chaves
  Future<bool> clear();

  /// Obtém todas as chaves
  Future<Set<String>> getKeys();

  /// Recarrega dados do armazenamento
  Future<void> reload();
}
