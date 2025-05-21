import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import '../models/asset_file.dart';

/// Utility class for file operations related to asset generation
class FileUtils {
  /// Reads the pubspec.yaml file and extracts the declared assets
  static Set<String> getAssetsFromPubspec(String projectRoot) {
    final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found at $projectRoot');
    }

    final pubspecContent = pubspecFile.readAsStringSync();
    final yaml = loadYaml(pubspecContent);

    final Set<String> declaredAssets = {};

    // Check if flutter and assets sections exist
    if (yaml is Map && yaml.containsKey('flutter')) {
      final flutter = yaml['flutter'];
      if (flutter is Map && flutter.containsKey('assets')) {
        final assets = flutter['assets'];
        if (assets is List) {
          for (final asset in assets) {
            if (asset is String) {
              declaredAssets.add(asset);
            }
          }
        }
      }
    }

    return declaredAssets;
  }

  /// Scans directory recursively to find all asset files
  static List<AssetFile> scanAssetDirectory(String assetsDir,
      {String? baseDir}) {
    final directory = Directory(assetsDir);
    if (!directory.existsSync()) {
      return [];
    }

    final assetFiles = <AssetFile>[];
    final entities = directory.listSync(recursive: true);

    baseDir ??= assetsDir;

    for (final entity in entities) {
      if (entity is File) {
        final extension = path.extension(entity.path).replaceFirst('.', '');
        if (extension.isEmpty) continue;

        final relativePath = path.relative(entity.path, from: baseDir);

        assetFiles.add(AssetFile(
          absolutePath: entity.path,
          relativePath: relativePath,
          type: extension.toAssetType(),
          extension: extension,
        ));
      }
    }

    return assetFiles;
  }

  /// Ensures a directory exists, creating it if necessary
  static Directory ensureDirectoryExists(String dirPath) {
    final directory = Directory(dirPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return directory;
  }

  /// Writes content to a file, creating parent directories if needed
  static void writeToFile(String filePath, String content) {
    final file = File(filePath);
    ensureDirectoryExists(path.dirname(file.path));
    file.writeAsStringSync(content);
  }
}
