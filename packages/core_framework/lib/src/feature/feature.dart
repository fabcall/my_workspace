import 'package:core_framework/core_framework.dart';
import 'package:flutter/widgets.dart';

/// Traditional feature that can have routes, DI, i18n and be part of a shell.
/// Use for features with screens, dependency injection, or as shell tabs.
abstract class Feature extends BaseFeature {
  /// Feature-specific dependency injection module.
  /// Return null if feature has no specific services.
  InjectionModule? get injectionModule => null;

  /// Localization delegate for feature-specific i18n.
  /// Return null if feature uses only global texts.
  LocalizationsDelegate<dynamic>? get localizationsDelegate => null;

  /// Feature-specific route module.
  /// Return null if feature is logic-only or has no routes.
  RouteModule? get routeModule => null;

  /// Name of the parent shell if this feature is a shell tab.
  /// Leave null for standalone features.
  String? get parentShellName => null;
}
