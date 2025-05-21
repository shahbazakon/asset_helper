import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:asset_helper/asset_helper.dart';
import 'package:path/path.dart' as path;

void main() {
  group('Asset File Tests', () {
    test('AssetFile correctly parses paths and extensions', () {
      final assetFile = AssetFile(
        absolutePath: '/path/to/assets/images/logo.png',
        relativePath: 'assets/images/logo.png',
        type: AssetType.image,
        extension: 'png',
      );

      expect(assetFile.extension, equals('png'));
      expect(assetFile.type, equals(AssetType.image));
      expect(assetFile.referenceString, equals('assets/images/logo.png'));
      expect(assetFile.variableName, isA<String>());
    });

    test('AssetFile generates correct variable name', () {
      final assetFile = AssetFile(
        absolutePath: '/path/to/assets/images/background-image.png',
        relativePath: 'assets/images/background-image.png',
        type: AssetType.image,
        extension: 'png',
      );

      expect(assetFile.variableName, equals('assets_images_background_image'));
    });
  });

  group('Asset Type Tests', () {
    test('String extension correctly identifies asset types', () {
      expect('png'.toAssetType(), equals(AssetType.image));
      expect('jpg'.toAssetType(), equals(AssetType.image));
      expect('svg'.toAssetType(), equals(AssetType.svg));
      expect('ttf'.toAssetType(), equals(AssetType.font));
      expect('json'.toAssetType(), equals(AssetType.json));
      expect('txt'.toAssetType(), equals(AssetType.text));
      expect('mp4'.toAssetType(), equals(AssetType.video));
      expect('mp3'.toAssetType(), equals(AssetType.audio));
      expect('xyz'.toAssetType(), equals(AssetType.other));
    });
  });

  group('Config Tests', () {
    test('Default config has correct values', () {
      final config = Config();

      expect(config.outputDir, equals('lib/generated'));
      expect(config.assetClassName, equals('Assets'));
      expect(config.includeComments, isTrue);
      expect(config.assetDirs, contains('assets'));
    });
  });
}
