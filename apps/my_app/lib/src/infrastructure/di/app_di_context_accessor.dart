import 'package:core_framework/core_framework.dart';
import 'package:flutter/material.dart';
import 'package:my_app/src/ui/widgets/di_container_provider.dart';

/// Implementação concreta do DIContextAccessor para o App Shell
class AppDIContextAccessor implements DIContextAccessor {
  @override
  ScopedServiceLocator getDIContainer(BuildContext context) {
    return DIContainerProvider.of(context);
  }
}
