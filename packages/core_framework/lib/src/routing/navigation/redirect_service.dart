/// Service for managing redirects after authentication or other flows
class RedirectService {
  final String _defaultDestination;
  final List<String> _excludedRoutes;
  String? _intendedDestination;

  RedirectService({
    String defaultDestination = '/home',
    List<String> excludedRoutes = const ['/', '/login', '/register'],
  }) : _defaultDestination = defaultDestination,
       _excludedRoutes = excludedRoutes;

  /// Default destination when there is no specific destination
  String get defaultDestinationAfterLogin => _defaultDestination;

  /// Sets the intended destination by the user
  void setIntendedDestination(String destination) {
    if (_isAuthRoute(destination)) return;
    _intendedDestination = destination;
  }

  /// Gets and clears the intended destination (single operation)
  String? getAndClearIntendedDestination() {
    final destination = _intendedDestination;
    _intendedDestination = null;
    return destination;
  }

  /// Clears any saved destination
  void clearIntendedDestination() => _intendedDestination = null;

  /// Checks if there is a saved destination
  bool get hasIntendedDestination => _intendedDestination != null;

  /// Checks if it's an authentication route that should not be saved
  bool _isAuthRoute(String route) {
    return _excludedRoutes.any((authRoute) => route.startsWith(authRoute));
  }
}
