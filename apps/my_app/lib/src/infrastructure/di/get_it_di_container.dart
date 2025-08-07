import 'package:core_framework/core_framework.dart';
import 'package:get_it/get_it.dart';

/// Implementação unificada do DIContainer usando GetIt
class GetItDIContainer implements DIContainer {
  /// Construtor
  GetItDIContainer({GetIt? instance}) : _getIt = instance ?? GetIt.instance;

  final GetIt _getIt;

  // Set para rastrear tipos registrados
  final Set<Type> _registeredTypes = <Type>{};

  // Lista para rastrear escopos ativos manualmente
  final List<String> _activeScopeNames = <String>[];

  // =================== DIContainer Methods ===================

  @override
  T get<T extends Object>({String? instanceName}) =>
      _getIt.get<T>(instanceName: instanceName);

  @override
  bool isRegistered<T extends Object>({String? instanceName}) =>
      _getIt.isRegistered<T>(instanceName: instanceName);

  @override
  void registerSingleton<T extends Object>(T instance, {String? instanceName}) {
    if (isRegistered<T>(instanceName: instanceName)) {
      unregister<T>(instanceName: instanceName);
    }
    _getIt.registerSingleton<T>(instance, instanceName: instanceName);
    _trackRegisteredType<T>();
  }

  @override
  void registerFactory<T extends Object>(
    T Function() factory, {
    String? instanceName,
  }) {
    if (isRegistered<T>(instanceName: instanceName)) {
      unregister<T>(instanceName: instanceName);
    }
    _getIt.registerFactory<T>(factory, instanceName: instanceName);
    _trackRegisteredType<T>();
  }

  @override
  void registerLazySingleton<T extends Object>(
    T Function() factory, {
    String? instanceName,
  }) {
    if (isRegistered<T>(instanceName: instanceName)) {
      unregister<T>(instanceName: instanceName);
    }
    _getIt.registerLazySingleton<T>(factory, instanceName: instanceName);
    _trackRegisteredType<T>();
  }

  @override
  void unregister<T extends Object>({String? instanceName}) {
    if (isRegistered<T>(instanceName: instanceName)) {
      _getIt.unregister<T>(instanceName: instanceName);
      _untrackRegisteredType<T>();
    }
  }

  @override
  void reset() {
    _getIt.reset();
    _registeredTypes.clear();
    _activeScopeNames.clear();
  }

  @override
  List<Type> get registeredTypes => _registeredTypes.toList();

  void _trackRegisteredType<T>() {
    _registeredTypes.add(T);
  }

  void _untrackRegisteredType<T>() {
    _registeredTypes.remove(T);
  }

  // =================== ScopeManager Methods ===================

  @override
  void createScope(String scopeName) {
    if (isScopeActive(scopeName)) {
      return; // Escopo já existe
    }

    // Usa a funcionalidade nativa de escopo do GetIt
    _getIt.pushNewScope(scopeName: scopeName);

    // Adiciona à nossa lista de controle
    _activeScopeNames.add(scopeName);
  }

  @override
  bool isScopeActive(String scopeName) {
    // Verifica na nossa lista de controle
    return _activeScopeNames.contains(scopeName);
  }

  @override
  void closeScope(String scopeName) {
    if (!isScopeActive(scopeName)) {
      return;
    }

    // Usa a funcionalidade nativa do GetIt para fechar o escopo
    try {
      _getIt.dropScope(scopeName);
    } catch (e) {
      // Se não conseguir dropar por nome, tenta pop se for o escopo atual
      if (_getIt.currentScopeName == scopeName) {
        _getIt.popScope();
      }
    }

    // Remove da nossa lista de controle
    _activeScopeNames.remove(scopeName);
  }

  @override
  T getScopedDependency<T extends Object>(String scopeName) {
    if (!isScopeActive(scopeName)) {
      throw Exception('Escopo "$scopeName" não está ativo.');
    }

    // O GetIt automaticamente busca na hierarquia de escopos
    try {
      return get<T>();
    } catch (e) {
      throw Exception(
        'Dependência $T não está registrada no escopo "$scopeName" ou em escopos superiores.',
      );
    }
  }

  @override
  void registerScopedSingleton<T extends Object>(
    String scopeName,
    T instance,
  ) {
    if (!isScopeActive(scopeName)) {
      createScope(scopeName);
    }

    // Muda para o escopo específico antes de registrar
    final currentScope = _getIt.currentScopeName;
    if (currentScope != scopeName) {
      _pushToScope(scopeName);
    }

    try {
      registerSingleton<T>(instance);
    } finally {
      // Volta para o escopo anterior se necessário
      if (currentScope != scopeName && currentScope != null) {
        _pushToScope(currentScope);
      }
    }
  }

  @override
  void registerScopedFactory<T extends Object>(
    String scopeName,
    T Function() factory,
  ) {
    if (!isScopeActive(scopeName)) {
      createScope(scopeName);
    }

    final currentScope = _getIt.currentScopeName;
    if (currentScope != scopeName) {
      _pushToScope(scopeName);
    }

    try {
      registerFactory<T>(factory);
    } finally {
      if (currentScope != scopeName && currentScope != null) {
        _pushToScope(currentScope);
      }
    }
  }

  @override
  void registerScopedLazySingleton<T extends Object>(
    String scopeName,
    T Function() factory,
  ) {
    if (!isScopeActive(scopeName)) {
      createScope(scopeName);
    }

    final currentScope = _getIt.currentScopeName;
    if (currentScope != scopeName) {
      _pushToScope(scopeName);
    }

    try {
      registerLazySingleton<T>(factory);
    } finally {
      if (currentScope != scopeName && currentScope != null) {
        _pushToScope(currentScope);
      }
    }
  }

  @override
  bool isScopedDependencyRegistered<T extends Object>(String scopeName) {
    if (!isScopeActive(scopeName)) {
      return false;
    }

    // O GetIt verifica automaticamente na hierarquia de escopos
    return isRegistered<T>();
  }

  @override
  List<String> get activeScopes => List.unmodifiable(_activeScopeNames);

  // =================== Helper Methods ===================

  /// Navega para um escopo específico
  void _pushToScope(String scopeName) {
    if (_getIt.currentScopeName != scopeName) {
      // Se o escopo não existir na nossa lista, cria
      if (!_activeScopeNames.contains(scopeName)) {
        createScope(scopeName);
      } else {
        // Se existir, navega até ele
        // Nota: Esta navegação pode ser complexa com GetIt
        // Para simplificar, vamos assumir que o escopo já está acessível
        // ou criar um novo escopo temporário
        try {
          _getIt.pushNewScope(scopeName: scopeName);
        } catch (e) {
          // Se não conseguir navegar, pelo menos tenta garantir que o escopo existe
          if (!_activeScopeNames.contains(scopeName)) {
            _activeScopeNames.add(scopeName);
          }
        }
      }
    }
  }

  /// Método para fins de teste que permite obter a instância do GetIt
  GetIt get instance => _getIt;

  /// Obtém o nome do escopo atual
  String? get currentScopeName => _getIt.currentScopeName;

  /// Obtém todos os nomes de escopos ativos
  Iterable<String> get scopeNames => List.unmodifiable(_activeScopeNames);
}
