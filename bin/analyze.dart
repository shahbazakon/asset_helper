import 'dart:io';
import 'package:asset_helper/asset_helper.dart';
import 'package:path/path.dart' as path;

Future<void> main(List<String> args) async {
  final projectRoot = Directory.current.path;
  print('Analyzing assets in project: $projectRoot');

  // Load config from pubspec.yaml
  final config = Config.fromPubspec(projectRoot);

  try {
    // Create a temporary asset generator to use its scanning methods
    final generator = AssetGenerator(
      projectRoot: projectRoot,
      config: config,
    );

    // Scan assets using the private method (we're exposing it for analysis)
    final assetFiles = _scanAssets(generator, projectRoot, config);

    // Count assets by type
    final assetCounts = <AssetType, int>{};
    for (final asset in assetFiles) {
      assetCounts.update(
        asset.type,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    // Print summary
    print('\n📊 Asset Analysis Summary:');
    print('------------------------');
    print('Total assets: ${assetFiles.length}');

    // Print counts by type
    if (assetCounts.isNotEmpty) {
      print('\nAssets by type:');
      assetCounts.forEach((type, count) {
        print('- ${_formatAssetType(type)}: $count');
      });
    }

    // Print assets by directory
    final assetDirCounts = <String, int>{};
    for (final asset in assetFiles) {
      final dir = path.dirname(asset.relativePath);
      assetDirCounts.update(
        dir,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    if (assetDirCounts.isNotEmpty) {
      print('\nAssets by directory:');
      assetDirCounts.forEach((dir, count) {
        print('- ${dir.isEmpty ? '(root)' : dir}: $count');
      });
    }

    print('\n✅ Analysis complete!');
  } catch (e) {
    print('❌ Error analyzing assets: $e');
    exit(1);
  }
}

/// Helper method to access the scan assets functionality
List<AssetFile> _scanAssets(
    AssetGenerator generator, String projectRoot, Config config) {
  final allAssets = <AssetFile>[];

  // Scan each asset directory
  for (final assetDir in config.assetDirs) {
    final dirPath = path.join(projectRoot, assetDir);
    if (!Directory(dirPath).existsSync()) {
      continue;
    }

    final assets = FileUtils.scanAssetDirectory(dirPath, baseDir: projectRoot);

    // Filter assets based on extension if needed
    final filteredAssets = assets.where((asset) {
      // If include extensions is provided, only include those
      if (config.includeExtensions.isNotEmpty) {
        return config.includeExtensions.contains(asset.extension);
      }

      // Otherwise, exclude specified extensions
      if (config.excludeExtensions.isNotEmpty) {
        return !config.excludeExtensions.contains(asset.extension);
      }

      return true;
    }).toList();

    allAssets.addAll(filteredAssets);
  }

  return allAssets;
}

/// Format asset type for display
/// Returns a human-readable label for the given [AssetType].
/// Returns a human-readable label for the given [AssetType].
String _formatAssetType(AssetType type) {
  const labels = {
    AssetType.image: 'Images',
    AssetType.svg: 'SVG Files',
    AssetType.font: 'Fonts',
    AssetType.json: 'JSON Files',
    AssetType.yaml: 'YAML Files',
    AssetType.text: 'Text Files',
    AssetType.video: 'Videos',
    AssetType.audio: 'Audio Files',
    AssetType.other: 'Other Files',
  };

  return labels[type] ?? 'Unknown';
}


