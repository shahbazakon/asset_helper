# Asset Helper

A Flutter package that automatically generates reference files for assets in your Flutter project.

## Installation

```yaml
dev_dependencies:
  asset_helper: ^1.0.1
```

## Commands

| Command | Description |
|---------|-------------|
| `flutter pub run asset_helper:generate` | Generate asset reference file |
| `flutter pub run asset_helper:clean` | Identify unused assets |
| `flutter pub run asset_helper:analyze` | Analyze and summarize all assets |

## Usage

After running the generate command, import and use the generated file:

```dart
import 'package:your_app/generated/assets.dart';

// Access assets using the naming convention: FolderNameFileNameFileType
Image.asset(Assets.IconsHomeSVG);
Image.asset(Assets.ImagesLogoPNG);
```

## Configuration

Configure in your `pubspec.yaml`:

```yaml
# Asset Helper configuration
asset_helper:
  output_dir: lib/generated
  asset_class_name: Assets
  include_comments: true
  use_new_naming_convention: true
```

Or create an `asset_helper.yaml` file in your project root.

## Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `output_dir` | Output directory for generated file | `lib/generated` |
| `asset_class_name` | Name of generated class | `Assets` |
| `include_comments` | Include comments in generated file | `true` |
| `use_new_naming_convention` | Use FolderNameFileNameFileType pattern | `true` |
| `asset_dirs` | Asset directories to scan | `['assets']` or from pubspec |
| `include_extensions` | File extensions to include | `[]` (include all) |
| `exclude_extensions` | File extensions to exclude | `[]` |

## Features

- ✓ Automatic asset scanning and reference generation
- ✓ Customizable naming conventions
- ✓ Configuration via pubspec.yaml or dedicated config file
- ✓ Asset analysis and unused asset detection
- ✓ Support for nested asset directories

## License

MIT License - see the [LICENSE](LICENSE) file for details. 