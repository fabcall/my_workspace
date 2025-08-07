import 'dart:async';
import 'dart:collection';
import 'package:core_framework/core_framework.dart';

/// Implementação padrão do barramento de eventos
class EventBusImpl implements EventBus {
  // Mapa de controllers por tipo de evento
  final Map<Type, StreamController<dynamic>> _controllers =
      HashMap<Type, StreamController<dynamic>>();

  // Mapa de subscribers por tipo (para debugging/metrics)
  final Map<Type, int> _subscriberCounts = HashMap<Type, int>();

  bool _isDisposed = false;

  @override
  bool get isDisposed => _isDisposed;

  @override
  void publish<T>(T event) {
    _checkDisposed();

    if (event == null) {
      throw ArgumentError('Event cannot be null');
    }

    final eventType = T == dynamic ? event.runtimeType : T;
    final controller = _controllers[eventType];

    if (controller != null && !controller.isClosed) {
      try {
        controller.add(event);

        // Log para debugging (pode ser removido em produção)
        _logEvent('Published', eventType, event);
      } catch (e) {
        _logError('Error publishing event', eventType, e);
      }
    }
  }

  @override
  Stream<T> subscribe<T>() {
    _checkDisposed();

    final eventType = T;

    // Cria um novo controller se não existir
    if (!_controllers.containsKey(eventType)) {
      _controllers[eventType] = StreamController<T>.broadcast(
        onListen: () => _onSubscribe<T>(),
        onCancel: () => _onUnsubscribe<T>(),
      );
      _subscriberCounts[eventType] = 0;
    }

    final controller = _controllers[eventType] as StreamController<T>;
    return controller.stream;
  }

  void _onSubscribe<T>() {
    final eventType = T;
    _subscriberCounts[eventType] = (_subscriberCounts[eventType] ?? 0) + 1;
    _logEvent('Subscribed', eventType, null);
  }

  void _onUnsubscribe<T>() {
    final eventType = T;
    final currentCount = _subscriberCounts[eventType] ?? 0;
    if (currentCount > 0) {
      _subscriberCounts[eventType] = currentCount - 1;
      _logEvent('Unsubscribed', eventType, null);
    }
  }

  @override
  bool hasSubscribers<T>() {
    _checkDisposed();
    final eventType = T;
    return (_subscriberCounts[eventType] ?? 0) > 0;
  }

  @override
  int getSubscriberCount<T>() {
    _checkDisposed();
    final eventType = T;
    return _subscriberCounts[eventType] ?? 0;
  }

  @override
  void clearSubscribers<T>() {
    _checkDisposed();
    final eventType = T;

    final controller = _controllers[eventType];
    if (controller != null) {
      controller.close();
      _controllers.remove(eventType);
      _subscriberCounts.remove(eventType);
      _logEvent('Cleared subscribers', eventType, null);
    }
  }

  @override
  void clearAllSubscribers() {
    _checkDisposed();

    // Fecha todos os controllers
    for (final controller in _controllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }

    _controllers.clear();
    _subscriberCounts.clear();
    _logEvent('Cleared all subscribers', null, null);
  }

  @override
  void dispose() {
    if (_isDisposed) return;

    clearAllSubscribers();
    _isDisposed = true;
    _logEvent('EventBus disposed', null, null);
  }

  void _checkDisposed() {
    if (_isDisposed) {
      throw StateError('EventBus has been disposed');
    }
  }

  // Métodos auxiliares para logging (podem usar um logger real)
  void _logEvent(String action, Type? eventType, dynamic event) {
    // Em desenvolvimento, você pode habilitar logs detalhados
    print(
      'EventBus: $action ${eventType?.toString() ?? 'ALL'} - ${event?.toString() ?? ''}',
    );
  }

  void _logError(String message, Type eventType, dynamic error) {
    print('EventBus ERROR: $message for $eventType - $error');
  }

  // Método para debugging - lista todos os tipos registrados
  Map<Type, int> getDebugInfo() {
    _checkDisposed();
    return Map.unmodifiable(_subscriberCounts);
  }
}
