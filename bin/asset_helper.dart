import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:asset_helper/asset_helper.dart';

Future<void> main(List<String> args) async {
  // Define command line arguments
  final parser = ArgParser()
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Output directory for the generated file',
      defaultsTo: 'lib/generated',
    )
    ..addOption(
      'class-name',
      abbr: 'c',
      help: 'Name for the generated asset class',
      defaultsTo: 'Assets',
    )
    ..addOption(
      'assets-dir',
      abbr: 'a',
      help: 'Directory to scan for assets (relative to project root)',
      defaultsTo: 'assets',
    )
    ..addFlag(
      'use-new-naming',
      abbr: 'n',
      help: 'Use new naming convention (FolderNameFileNameFileType)',
      defaultsTo: true,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information',
    );

  try {
    final results = parser.parse(args);

    if (results['help'] == true) {
      _printUsage(parser);
      exit(0);
    }

    final projectRoot = Directory.current.path;
    print('Scanning assets in: $projectRoot');

    // Create a custom config from the command line arguments
    final config = Config(
      outputDir: results['output'],
      assetClassName: results['class-name'],
      assetDirs: [results['assets-dir']],
      useNewNamingConvention: results['use-new-naming'],
    );

    // Generate the assets
    final generator = AssetGenerator(
      projectRoot: projectRoot,
      config: config,
    );

    final outputFile = await generator.generateAssets();
    print('✅ Generated asset references at: $outputFile');

    if (config.useNewNamingConvention) {
      print('Assets are now accessible using the format: Assets.IconsHomeSVG');
    } else {
      print('Assets are now accessible using the format: Assets.icons.home');
    }
  } catch (e) {
    print('Error: $e');
    _printUsage(parser);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('Usage: dart run asset_helper [options]');
  print(parser.usage);
  print('\nConfiguration can also be specified in your pubspec.yaml:');
  print('''
flutter:
  assets:
    - assets/icons/
    - assets/images/
    
asset_helper:
  output_dir: lib/generated
  asset_class_name: Assets
  include_comments: true
  use_new_naming_convention: true
''');
}
