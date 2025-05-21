/// Represents an asset file in the Flutter project.
class AssetFile {
  /// The absolute path to the asset file
  final String absolutePath;

  /// The relative path from the assets directory
  final String relativePath;

  /// The asset type (e.g., image, font, json)
  final AssetType type;

  /// The file extension (e.g., png, jpg, json)
  final String extension;

  /// Constructor for an asset file
  AssetFile({
    required this.absolutePath,
    required this.relativePath,
    required this.type,
    required this.extension,
  });

  /// Creates a reference string for use in the generated Dart file
  String get referenceString => relativePath;

  /// Creates a variable name using the original camelCase format
  String get variableName {
    // Remove extension and convert to camelCase
    final nameWithoutExt =
        relativePath.substring(0, relativePath.length - extension.length - 1);
    final parts = nameWithoutExt.split('/');

    // Convert to camelCase
    String result = parts[0];
    for (int i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        result += parts[i][0].toUpperCase() + parts[i].substring(1);
      }
    }

    // Replace special characters with underscores
    result = result.replaceAll(RegExp(r'[^\w]'), '_');

    // Ensure it starts with a lowercase letter
    if (result.isNotEmpty) {
      result = result[0].toLowerCase() + result.substring(1);
    }

    return result;
  }

  /// Creates a variable name in the format: FolderNameFileNameFileType
  String get newVariableName {
    // Extract folder, filename, and extension
    final parts = relativePath.split('/');
    final fileName = parts.last;
    final fileNameWithoutExt =
        fileName.substring(0, fileName.length - extension.length - 1);

    // Capitalize each segment
    final folders = parts.sublist(0, parts.length - 1);
    final folderNames = folders.map((folder) {
      if (folder.isEmpty) return '';
      return folder[0].toUpperCase() + folder.substring(1);
    }).join('');

    // Format filename with first letter capitalized
    final capitalizedFileName = fileNameWithoutExt.isNotEmpty
        ? fileNameWithoutExt[0].toUpperCase() + fileNameWithoutExt.substring(1)
        : '';

    // Extension to uppercase
    final uppercaseExt = extension.toUpperCase();

    // Build the variable name and clean it up
    String result = '$folderNames$capitalizedFileName$uppercaseExt';

    // Replace special characters with underscores
    result = result.replaceAll(RegExp(r'[^\w]'), '_');

    return result;
  }
}

/// Enum representing the type of asset
enum AssetType {
  image,
  svg,
  font,
  json,
  yaml,
  text,
  video,
  audio,
  other,
}

/// Extension on String to determine asset type from extension
extension AssetTypeExtension on String {
  AssetType toAssetType() {
    final ext = toLowerCase();
    if (ext == 'png' ||
        ext == 'jpg' ||
        ext == 'jpeg' ||
        ext == 'gif' ||
        ext == 'webp') {
      return AssetType.image;
    } else if (ext == 'svg') {
      return AssetType.svg;
    } else if (ext == 'ttf' || ext == 'otf') {
      return AssetType.font;
    } else if (ext == 'json') {
      return AssetType.json;
    } else if (ext == 'yaml' || ext == 'yml') {
      return AssetType.yaml;
    } else if (ext == 'txt' || ext == 'md') {
      return AssetType.text;
    } else if (ext == 'mp4' || ext == 'mov' || ext == 'avi') {
      return AssetType.video;
    } else if (ext == 'mp3' || ext == 'wav' || ext == 'ogg') {
      return AssetType.audio;
    } else {
      return AssetType.other;
    }
  }
}
