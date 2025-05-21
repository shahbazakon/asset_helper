import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// Configuration for the asset generator
class Config {
  /// Directory where the generated file will be placed
  final String outputDir;

  /// Name of the generated asset class
  final String assetClassName;

  /// Whether to include comments in the generated file
  final bool includeComments;

  /// Directory paths to scan for assets (relative to project root)
  final List<String> assetDirs;

  /// File extensions to include in the scan
  final List<String> includeExtensions;

  /// File extensions to exclude from the scan
  final List<String> excludeExtensions;

  /// Whether to use folder-name-file-type naming convention
  final bool useNewNamingConvention;

  /// Default constructor
  Config({
    this.outputDir = 'lib/generated',
    this.assetClassName = 'Assets',
    this.includeComments = true,
    this.assetDirs = const ['assets'],
    this.includeExtensions = const [],
    this.excludeExtensions = const [],
    this.useNewNamingConvention = true,
  });

  /// Creates a config from pubspec.yaml file
  static Config fromPubspec(String projectRoot) {
    final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));

    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found at $projectRoot');
    }

    final pubspecContent = pubspecFile.readAsStringSync();
    final yaml = loadYaml(pubspecContent);

    // First check if there's any declared assets in the pubspec
    final List<String> assetDirs = [];

    if (yaml is Map && yaml.containsKey('flutter')) {
      final flutter = yaml['flutter'];
      if (flutter is Map && flutter.containsKey('assets')) {
        final assets = flutter['assets'];
        if (assets is List) {
          for (final asset in assets) {
            if (asset is String) {
              assetDirs.add(asset);
            }
          }
        }
      }
    }

    // If no assets are declared in flutter section, use default
    if (assetDirs.isEmpty) {
      assetDirs.add('assets');
    }

    // Check if there's an asset_helper configuration in the pubspec
    String outputDir = 'lib/generated';
    String assetClassName = 'Assets';
    bool includeComments = true;
    List<String> includeExtensions = [];
    List<String> excludeExtensions = [];
    bool useNewNamingConvention = true;

    if (yaml is Map && yaml.containsKey('asset_helper')) {
      final config = yaml['asset_helper'];
      if (config is Map) {
        outputDir = _getString(config, 'output_dir') ?? outputDir;
        assetClassName =
            _getString(config, 'asset_class_name') ?? assetClassName;
        includeComments =
            _getBool(config, 'include_comments') ?? includeComments;
        includeExtensions =
            _getStringList(config, 'include_extensions') ?? includeExtensions;
        excludeExtensions =
            _getStringList(config, 'exclude_extensions') ?? excludeExtensions;
        useNewNamingConvention =
            _getBool(config, 'use_new_naming_convention') ??
                useNewNamingConvention;
      }
    }

    return Config(
      outputDir: outputDir,
      assetClassName: assetClassName,
      includeComments: includeComments,
      assetDirs: assetDirs,
      includeExtensions: includeExtensions,
      excludeExtensions: excludeExtensions,
      useNewNamingConvention: useNewNamingConvention,
    );
  }

  /// Creates a config from a YAML file or falls back to pubspec if file doesn't exist
  static Config fromFile(String projectRoot) {
    final configFile = File(path.join(projectRoot, 'asset_helper.yaml'));

    if (!configFile.existsSync()) {
      return fromPubspec(projectRoot);
    }

    final configContent = configFile.readAsStringSync();
    final yaml = loadYaml(configContent);

    // Get asset directories from pubspec
    final pubspecAssetDirs = _getPubspecAssetDirs(projectRoot);

    return Config(
      outputDir: _getString(yaml, 'output_dir') ?? 'lib/generated',
      assetClassName: _getString(yaml, 'asset_class_name') ?? 'Assets',
      includeComments: _getBool(yaml, 'include_comments') ?? true,
      assetDirs: _getStringList(yaml, 'asset_dirs') ?? pubspecAssetDirs,
      includeExtensions: _getStringList(yaml, 'include_extensions') ?? [],
      excludeExtensions: _getStringList(yaml, 'exclude_extensions') ?? [],
      useNewNamingConvention:
          _getBool(yaml, 'use_new_naming_convention') ?? true,
    );
  }

  /// Gets asset directories from pubspec.yaml
  static List<String> _getPubspecAssetDirs(String projectRoot) {
    try {
      final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
      if (!pubspecFile.existsSync()) {
        return ['assets'];
      }

      final pubspecContent = pubspecFile.readAsStringSync();
      final yaml = loadYaml(pubspecContent);

      final List<String> assetDirs = [];

      if (yaml is Map && yaml.containsKey('flutter')) {
        final flutter = yaml['flutter'];
        if (flutter is Map && flutter.containsKey('assets')) {
          final assets = flutter['assets'];
          if (assets is List) {
            for (final asset in assets) {
              if (asset is String) {
                assetDirs.add(asset);
              }
            }
          }
        }
      }

      return assetDirs.isEmpty ? ['assets'] : assetDirs;
    } catch (e) {
      return ['assets'];
    }
  }

  /// Helper to get a string from YAML
  static String? _getString(dynamic yaml, String key) {
    if (yaml is Map && yaml.containsKey(key)) {
      final value = yaml[key];
      if (value is String) {
        return value;
      }
    }
    return null;
  }

  /// Helper to get a boolean from YAML
  static bool? _getBool(dynamic yaml, String key) {
    if (yaml is Map && yaml.containsKey(key)) {
      final value = yaml[key];
      if (value is bool) {
        return value;
      }
    }
    return null;
  }

  /// Helper to get a string list from YAML
  static List<String>? _getStringList(dynamic yaml, String key) {
    if (yaml is Map && yaml.containsKey(key)) {
      final value = yaml[key];
      if (value is List) {
        return value.whereType<String>().toList();
      }
    }
    return null;
  }
}
