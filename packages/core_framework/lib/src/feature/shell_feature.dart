import 'package:core_framework/core_framework.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Feature that represents a navigation shell (BottomNavigationBar, etc).
/// Automatically discovers its tabs via `parentShellName` and generates StatefulShellRoute.
abstract class ShellFeature extends BaseFeature {
  /// Shell route module that manages automatic branch discovery.
  /// The system automatically finds child features and creates branches.
  ShellRouteModule get shellRouteModule;

  /// Builder that defines the shell UI (BottomNavigationBar, NavigationRail, etc).
  /// Receives context, router state, and current tab content as child.
  Widget Function(BuildContext context, GoRouterState state, Widget child)
  get shellBuilder;
}
