import 'dart:io';
import 'package:asset_helper/asset_helper.dart';
import 'package:path/path.dart' as path;
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

Future<void> main(List<String> args) async {
  final projectRoot = Directory.current.path;
  print('Analyzing for unused assets in project: $projectRoot');

  // Load config from pubspec.yaml
  final config = Config.fromPubspec(projectRoot);

  try {
    // Scan the assets
    final allAssets = <AssetFile>[];

    // Scan each asset directory
    for (final assetDir in config.assetDirs) {
      final dirPath = path.join(projectRoot, assetDir);
      if (!Directory(dirPath).existsSync()) {
        continue;
      }

      final assets =
          FileUtils.scanAssetDirectory(dirPath, baseDir: projectRoot);
      allAssets.addAll(assets);
    }

    // Find all Dart files in the lib directory
    final libDir = Directory(path.join(projectRoot, 'lib'));
    if (!libDir.existsSync()) {
      print('❌ Lib directory not found. Cannot analyze code usage.');
      exit(1);
    }

    // Create a set of referenced asset paths
    final referencedAssets = await _findReferencedAssets(projectRoot);

    // Find unused assets
    final unusedAssets = allAssets.where((asset) {
      return !referencedAssets.contains(asset.relativePath);
    }).toList();

    // Print results
    print('\n📊 Unused Assets Analysis:');
    print('------------------------');
    print('Total assets: ${allAssets.length}');
    print('Referenced assets: ${referencedAssets.length}');
    print('Unused assets: ${unusedAssets.length}');

    if (unusedAssets.isNotEmpty) {
      print('\nUnused assets:');
      for (final asset in unusedAssets) {
        print('- ${asset.relativePath}');
      }

      print(
          '\n💡 Consider removing these assets or updating your code to use them.');
    } else {
      print('\n✅ Great job! All assets are being used in your code.');
    }
  } catch (e) {
    print('❌ Error analyzing unused assets: $e');
    exit(1);
  }
}

/// Find all string literals in Dart code that might reference assets
Future<Set<String>> _findReferencedAssets(String projectRoot) async {
  final referencedAssets = <String>{};

  try {
    // Create an analysis context collection for the project
    final collection = AnalysisContextCollection(
      includedPaths: [path.join(projectRoot, 'lib')],
    );

    // For each context (usually just one for a Flutter project)
    for (final context in collection.contexts) {
      // Get all .dart files in the context
      final dartFiles = context.contextRoot
          .analyzedFiles()
          .where((file) => file.endsWith('.dart'));

      // For each Dart file
      for (final filePath in dartFiles) {
        try {
          // Get the resolved AST for the file
          final result = await context.currentSession.getResolvedUnit(filePath);
          if (result is ResolvedUnitResult) {
            // Visit all string literals in the file
            result.unit.accept(
              _AssetReferenceVisitor(referencedAssets),
            );
          }
        } catch (e) {
          print('Warning: Error analyzing file $filePath: $e');
        }
      }
    }
  } catch (e) {
    print('Warning: Error during code analysis: $e');
  }

  return referencedAssets;
}

/// AST visitor that looks for string literals that might be asset references
class _AssetReferenceVisitor extends SimpleAstVisitor<void> {
  final Set<String> referencedAssets;

  _AssetReferenceVisitor(this.referencedAssets);

  @override
  void visitStringLiteral(StringLiteral node) {
    final value = node.stringValue;
    if (value != null) {
      // Check if this string looks like an asset path
      if (_looksLikeAssetPath(value)) {
        referencedAssets.add(value);
      }

      // Also check for file names without the path
      final fileName = path.basename(value);
      if (fileName != value) {
        referencedAssets.add(fileName);
      }
    }
  }

  /// Heuristic to determine if a string might be an asset path
  bool _looksLikeAssetPath(String value) {
    // Check for common asset file extensions
    final ext = path.extension(value).toLowerCase();
    if (['.png', '.jpg', '.jpeg', '.gif', '.svg', '.json', '.ttf', '.otf']
        .contains(ext)) {
      return true;
    }

    // Check for common asset path patterns
    if (value.contains('assets/') ||
        value.contains('images/') ||
        value.contains('fonts/')) {
      return true;
    }

    return false;
  }
}
