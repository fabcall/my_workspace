import 'dart:io';
import 'package:path/path.dart' as path;

void main(List<String> args) async {
  print('🚀 Starting version bump process...\n');

  // Parse command line arguments
  final bumpType = _parseBumpType(args);
  final specificVersion = _parseSpecificVersion(args);
  final dryRun = args.contains('--dry-run');

  if (dryRun) {
    print('🔍 Running in dry-run mode - no files will be modified\n');
  }

  try {
    // Find all pubspec.yaml files in the workspace
    final pubspecFiles = await _findPubspecFiles();

    if (pubspecFiles.isEmpty) {
      print('❌ No pubspec.yaml files found in workspace');
      exit(1);
    }

    print('📦 Found ${pubspecFiles.length} packages:\n');

    // Process each package
    final results = <String, String>{};

    for (final pubspecPath in pubspecFiles) {
      final result = await _processPackage(
        pubspecPath,
        bumpType,
        specificVersion,
        dryRun,
      );

      if (result != null) {
        final packageName = path.basename(path.dirname(pubspecPath));
        results[packageName] = result;
      }
    }

    // Summary
    print('\n✅ Version bump completed successfully!\n');
    print('📋 Summary:');
    results.forEach((package, version) {
      print('   $package: $version');
    });

    if (dryRun) {
      print('\n💡 This was a dry run. Use without --dry-run to apply changes.');
    }
  } catch (e) {
    print('❌ Error during version bump: $e');
    exit(1);
  }
}

BumpType _parseBumpType(List<String> args) {
  if (args.contains('--major')) return BumpType.major;
  if (args.contains('--minor')) return BumpType.minor;
  if (args.contains('--patch')) return BumpType.patch;
  if (args.contains('--build')) return BumpType.build;

  // Default to patch if no specific type is provided
  return BumpType.patch;
}

String? _parseSpecificVersion(List<String> args) {
  final versionIndex = args.indexOf('--version');
  if (versionIndex != -1 && versionIndex + 1 < args.length) {
    return args[versionIndex + 1];
  }
  return null;
}

Future<List<String>> _findPubspecFiles() async {
  final pubspecFiles = <String>[];
  final currentDir = Directory.current;

  await for (final entity
      in currentDir.list(recursive: true, followLinks: false)) {
    if (entity is File && path.basename(entity.path) == 'pubspec.yaml') {
      // Skip if it's in .dart_tool, build, or other generated directories
      final relativePath = path.relative(entity.path);
      if (!relativePath.contains('.dart_tool') &&
          !relativePath.contains('build/') &&
          !relativePath.contains('.pub-cache')) {
        pubspecFiles.add(entity.path);
      }
    }
  }

  return pubspecFiles;
}

Future<String?> _processPackage(
  String pubspecPath,
  BumpType bumpType,
  String? specificVersion,
  bool dryRun,
) async {
  try {
    final file = File(pubspecPath);
    final content = await file.readAsString();
    final lines = content.split('\n');

    // Find the version line
    int versionLineIndex = -1;
    String? currentVersion;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('version:')) {
        versionLineIndex = i;
        currentVersion = line.split(':')[1].trim();
        break;
      }
    }

    if (versionLineIndex == -1 || currentVersion == null) {
      final packageName = path.basename(path.dirname(pubspecPath));
      print('⚠️  No version found in $packageName/pubspec.yaml - skipping');
      return null;
    }

    // Calculate new version
    final newVersion =
        specificVersion ?? _calculateNewVersion(currentVersion, bumpType);

    if (newVersion == currentVersion) {
      final packageName = path.basename(path.dirname(pubspecPath));
      print('ℹ️  $packageName: Version unchanged ($currentVersion)');
      return currentVersion;
    }

    // Update the version line
    final packageName = path.basename(path.dirname(pubspecPath));
    print('📝 $packageName: $currentVersion → $newVersion');

    if (!dryRun) {
      lines[versionLineIndex] =
          lines[versionLineIndex].replaceFirst(currentVersion, newVersion);
      await file.writeAsString(lines.join('\n'));
    }

    return newVersion;
  } catch (e) {
    final packageName = path.basename(path.dirname(pubspecPath));
    print('❌ Error processing $packageName: $e');
    return null;
  }
}

String _calculateNewVersion(String currentVersion, BumpType bumpType) {
  // Remove any build number or pre-release suffix for parsing
  final versionParts = currentVersion.split('+');
  final mainVersion = versionParts[0];
  final buildNumber = versionParts.length > 1 ? versionParts[1] : null;

  // Parse semantic version
  final semanticParts = mainVersion.split('-');
  final versionNumbers = semanticParts[0].split('.');
  final preRelease =
      semanticParts.length > 1 ? semanticParts.sublist(1).join('-') : null;

  if (versionNumbers.length < 3) {
    throw ArgumentError('Invalid version format: $currentVersion');
  }

  int major = int.parse(versionNumbers[0]);
  int minor = int.parse(versionNumbers[1]);
  int patch = int.parse(versionNumbers[2]);
  int? build = buildNumber != null ? int.tryParse(buildNumber) : null;

  switch (bumpType) {
    case BumpType.major:
      major++;
      minor = 0;
      patch = 0;
      break;
    case BumpType.minor:
      minor++;
      patch = 0;
      break;
    case BumpType.patch:
      patch++;
      break;
    case BumpType.build:
      if (build != null) {
        build++;
      } else {
        build = 1;
      }
      break;
  }

  // Reconstruct version string
  String newVersion = '$major.$minor.$patch';

  if (preRelease != null && bumpType != BumpType.major) {
    newVersion += '-$preRelease';
  }

  if (build != null) {
    newVersion += '+$build';
  }

  return newVersion;
}

enum BumpType {
  major,
  minor,
  patch,
  build,
}
