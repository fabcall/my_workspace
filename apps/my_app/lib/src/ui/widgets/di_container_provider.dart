import 'package:core_framework/core_framework.dart';
import 'package:flutter/material.dart';

/// InheritedWidget que fornece acesso ao DIContainer na árvore de widgets
class DIContainerProvider extends InheritedWidget {
  const DIContainerProvider({
    required this.container,
    required super.child,
    super.key,
  });

  final DIContainer container;

  /// Obtém o DIContainer mais próximo na árvore de widgets
  static DIContainer of(BuildContext context) {
    final DIContainerProvider? result =
        context.dependOnInheritedWidgetOfExactType<DIContainerProvider>();

    if (result == null) {
      throw Exception(
          'DIContainerProvider não encontrado na árvore de widgets');
    }

    return result.container;
  }

  /// Obtém o DIContainer mais próximo na árvore de widgets (pode retornar null)
  static DIContainer? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DIContainerProvider>()
        ?.container;
  }

  @override
  bool updateShouldNotify(DIContainerProvider oldWidget) =>
      container != oldWidget.container;
}
