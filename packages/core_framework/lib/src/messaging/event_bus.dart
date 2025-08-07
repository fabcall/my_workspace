import 'dart:async';

/// Abstract interface for the application messaging/event system
abstract class EventBus {
  /// Publishes an event to all interested subscribers
  void publish<T>(T event);

  /// Subscribes to receive events of a specific type
  Stream<T> subscribe<T>();

  /// Checks if there are subscribers for an event type
  bool hasSubscribers<T>();

  /// Gets the number of subscribers for a specific type
  int getSubscriberCount<T>();

  /// Removes all subscribers of a specific type
  void clearSubscribers<T>();

  /// Removes all subscribers of all types
  void clearAllSubscribers();

  /// Releases all EventBus resources
  void dispose();

  /// Checks if the EventBus has been disposed
  bool get isDisposed;
}
