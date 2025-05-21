import 'dart:io';
import 'package:asset_helper/asset_helper.dart';

Future<void> main(List<String> args) async {
  final projectRoot = Directory.current.path;
  print('Scanning project at: $projectRoot');

  // Load config from pubspec.yaml
  final config = Config.fromPubspec(projectRoot);

  // Generate the assets
  final generator = AssetGenerator(
    projectRoot: projectRoot,
    config: config,
  );

  try {
    final outputFile = await generator.generateAssets();
    print('✅ Asset references generated at: $outputFile');
    print(
        'Assets are now accessible using the format: Assets.IconsFolderHomeSVG');
  } catch (e) {
    print('❌ Error generating assets: $e');
    exit(1);
  }
}
