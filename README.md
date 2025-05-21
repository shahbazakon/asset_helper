# Asset Helper

A Flutter package that automatically generates reference files for assets in a Flutter project.

## Features

- 📁 **Automatic Asset Analysis**: Scans the assets/ directory recursively to find all assets
- 🔄 **Automatic Reference File Generation**: Generates a Dart file with static references
- 🤖 **Machine Learning Integration**: Auto-categorizes assets and suggests improvements (coming soon)
- 📝 **pubspec.yaml Parsing**: Reads and ensures compatibility with Flutter's asset configuration
- 🛠️ **CLI Tool Support**: Commands to generate, clean, and analyze assets

## Installation

Add this to your `pubspec.yaml`:

```yaml
dev_dependencies:
  asset_helper: ^0.1.0
```

## Usage

### Basic Usage

```dart
// Run this command in your Flutter project
flutter pub run asset_helper:generate
```

This will generate an `assets.dart` file that you can import in your project:

```dart
import 'package:your_app/generated/assets.dart';

// Use generated asset references with the new naming convention:
// For an asset at assets/icons/home.svg:
Image.asset(Assets.IconsHomeSVG);

// For an asset at assets/images/logo.png:
Image.asset(Assets.ImagesLogoPNG);
```

### CLI Commands

- `flutter pub run asset_helper:generate` - Generates the reference file
- `flutter pub run asset_helper:clean` - Cleans up unused assets
- `flutter pub run asset_helper:analyze` - Provides a summary of all assets

## Configuration

You can configure the package directly in your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/fonts/

# Asset Helper configuration
asset_helper:
  output_dir: lib/generated
  asset_class_name: Assets
  include_comments: true
  use_new_naming_convention: true
```

Alternatively, create an `asset_helper.yaml` file in your project root to customize:

```yaml
output_dir: lib/generated
asset_class_name: AppAssets
include_comments: true
use_new_naming_convention: true
```

### Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `output_dir` | Directory where the generated file will be placed | `lib/generated` |
| `asset_class_name` | Name of the generated asset class | `Assets` |
| `include_comments` | Whether to include comments in the generated file | `true` |
| `use_new_naming_convention` | Use the new naming convention (FolderNameFileNameFileType) | `true` |
| `asset_dirs` | List of directories to scan for assets | `['assets']` (or from `pubspec.yaml`) |
| `include_extensions` | List of file extensions to include (empty = include all) | `[]` |
| `exclude_extensions` | List of file extensions to exclude | `[]` |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 