import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class RouteGuardService {
  String get name;
  String get redirectPath;
  Future<bool> canAccess(BuildContext context, GoRouterState state);
}
