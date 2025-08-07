import 'package:core_framework/core_framework.dart';
import 'package:my_app/src/app/app_bootstrap.dart';

class Application extends AppBootstrap {
  Application() : super(AppConfig.fromEnvironment());

  @override
  List<BaseFeature> get features => [];
}
