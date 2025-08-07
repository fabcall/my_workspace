import 'package:core_framework/core_framework.dart';

abstract class AppInitializer {
  Future<AppBootResult> initialize(AppConfig config);
}
