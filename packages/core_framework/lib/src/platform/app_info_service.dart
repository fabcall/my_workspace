class AppInfo {
  final String name;
  final String version;
  final String buildNumber;
  final String packageName;

  const AppInfo({
    required this.name,
    required this.version,
    required this.buildNumber,
    required this.packageName,
  });

  @override
  String toString() => 'AppInfo($name v$version+$buildNumber)';
}

abstract class AppInfoService {
  /// Initializes the service (must be called at app initialization)
  Future<void> initialize();

  /// Gets application name
  String getAppName();

  /// Gets application version
  String getAppVersion();

  /// Gets build number
  String getBuildNumber();

  /// Gets package name
  String getPackageName();
}
