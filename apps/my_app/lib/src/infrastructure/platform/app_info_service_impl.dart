import 'package:core_framework/core_framework.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoServiceImpl implements AppInfoService {
  AppInfo? _cachedAppInfo;

  @override
  Future<void> initialize() async {
    if (_cachedAppInfo != null) return;

    // ✅ Um await apenas na inicialização
    final packageInfo = await PackageInfo.fromPlatform();

    _cachedAppInfo = AppInfo(
      name: packageInfo.appName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      packageName: packageInfo.packageName,
    );
  }

  @override
  String getAppName() {
    _ensureInitialized();
    return _cachedAppInfo!.name;
  }

  @override
  String getAppVersion() {
    _ensureInitialized();
    return _cachedAppInfo!.version;
  }

  @override
  String getBuildNumber() {
    _ensureInitialized();
    return _cachedAppInfo!.buildNumber;
  }

  @override
  String getPackageName() {
    _ensureInitialized();
    return _cachedAppInfo!.packageName;
  }

  void _ensureInitialized() {
    if (_cachedAppInfo == null) {
      throw StateError(
        'AppInfoService must be initialized before use. '
        'Call initialize() during app startup.',
      );
    }
  }
}
