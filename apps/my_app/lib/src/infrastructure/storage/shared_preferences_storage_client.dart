import 'package:core_framework/core_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesStorageClient implements StorageClient {
  SharedPreferences? _prefs;
  final String? _prefix;

  SharedPreferencesStorageClient({String? prefix}) : _prefix = prefix;

  String _getKey(String key) => _prefix != null ? '${_prefix}_$key' : key;

  @override
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      throw StorageException(
        message: 'Failed to initialize storage: $e',
      );
    }
  }

  void _ensureInitialized() {
    if (_prefs == null) {
      throw StorageException(
        message: 'Storage client not initialized. Call initialize() first.',
      );
    }
  }

  @override
  Future<bool> setString(String key, String value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setString(_getKey(key), value);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Error saving string: $e',
        key: key,
        operation: 'setString',
      );
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      _ensureInitialized();
      return _prefs!.getString(_getKey(key));
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Error retrieving string: $e',
        key: key,
        operation: 'getString',
      );
    }
  }

  @override
  Future<bool> setInt(String key, int value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setInt(_getKey(key), value);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Error saving int: $e',
        key: key,
        operation: 'setInt',
      );
    }
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      _ensureInitialized();
      return _prefs!.getInt(_getKey(key));
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Error retrieving int: $e',
        key: key,
        operation: 'getInt',
      );
    }
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setDouble(_getKey(key), value);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Error saving double: $e',
        key: key,
        operation: 'setDouble',
      );
    }
  }

  @override
  Future<double?> getDouble(String key) async {
    try {
      _ensureInitialized();
      return _prefs!.getDouble(_getKey(key));
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Error retrieving double: $e',
        key: key,
        operation: 'getDouble',
      );
    }
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setBool(_getKey(key), value);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Error saving bool: $e',
        key: key,
        operation: 'setBool',
      );
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      _ensureInitialized();
      return _prefs!.getBool(_getKey(key));
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Error retrieving bool: $e',
        key: key,
        operation: 'getBool',
      );
    }
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setStringList(_getKey(key), value);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Error saving string list: $e',
        key: key,
        operation: 'setStringList',
      );
    }
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    try {
      _ensureInitialized();
      return _prefs!.getStringList(_getKey(key));
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Error retrieving string list: $e',
        key: key,
        operation: 'getStringList',
      );
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      _ensureInitialized();
      return _prefs!.containsKey(_getKey(key));
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Error checking if key exists: $e',
        key: key,
        operation: 'containsKey',
      );
    }
  }

  @override
  Future<bool> remove(String key) async {
    try {
      _ensureInitialized();
      return await _prefs!.remove(_getKey(key));
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Error removing key: $e',
        key: key,
        operation: 'remove',
      );
    }
  }

  @override
  Future<bool> clear() async {
    try {
      _ensureInitialized();
      if (_prefix != null) {
        // If there's a prefix, remove only keys with that prefix
        final keys = _prefs!
            .getKeys()
            .where((key) => key.startsWith('${_prefix}_'))
            .toList();
        bool success = true;
        for (final key in keys) {
          final result = await _prefs!.remove(key);
          success = success && result;
        }
        return success;
      } else {
        return await _prefs!.clear();
      }
    } catch (e) {
      throw StorageException(
        message: 'Error clearing storage: $e',
        operation: 'clear',
      );
    }
  }

  @override
  Future<Set<String>> getKeys() async {
    try {
      _ensureInitialized();
      final allKeys = _prefs!.getKeys();
      if (_prefix != null) {
        // Remove the prefix from returned keys
        return allKeys
            .where((key) => key.startsWith('${_prefix}_'))
            .map((key) => key.substring(_prefix.length + 1))
            .toSet();
      }
      return allKeys;
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'Error retrieving keys: $e',
        operation: 'getKeys',
      );
    }
  }

  @override
  Future<void> reload() async {
    try {
      _ensureInitialized();
      await _prefs!.reload();
    } catch (e) {
      throw StorageException(
        message: 'Error reloading storage: $e',
        operation: 'reload',
      );
    }
  }
}
