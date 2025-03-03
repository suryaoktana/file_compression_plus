# File Compression Plus

A Flutter package for compressing various file types including images and PDFs. This package provides simple and efficient methods to reduce file sizes while maintaining acceptable quality.

Developed by Tisankan.

## Features

- **Image Compression**: Compress JPG, PNG, and WebP images with customizable quality and dimensions
- **PDF Compression**: Compress PDF files with different compression levels
- **Simple API**: Easy-to-use methods with sensible defaults
- **Customizable**: Configure compression parameters to suit your needs

## Getting Started

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  file_compression_plus: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

### Image Compression

```dart
import 'dart:io';
import 'package:file_compression_plus/file_compression_plus.dart';

// Basic usage with default settings
Future<void> compressImageExample() async {
  File originalImage = File('path/to/image.jpg');
  File compressedImage = await FileCompressor.compressImage(
    file: originalImage,
  );
  print('Compressed image saved to: ${compressedImage.path}');
}

// Advanced usage with custom settings
Future<void> advancedImageCompression() async {
  File originalImage = File('path/to/image.png');
  File compressedImage = await FileCompressor.compressImage(
    file: originalImage,
    quality: 70,
    maxWidth: 1280,
    maxHeight: 720,
    format: ImageFormat.jpg, // Convert PNG to JPG
  );
  print('Compressed image saved to: ${compressedImage.path}');
}
```

### PDF Compression

```dart
import 'dart:io';
import 'package:file_compression_plus/file_compression_plus.dart';

// Basic usage with best compression
Future<void> compressPdfExample() async {
  File originalPdf = File('path/to/document.pdf');
  File compressedPdf = await FileCompressor.compressPdf(
    file: originalPdf,
  );
  print('Compressed PDF saved to: ${compressedPdf.path}');
}

// With custom compression level
Future<void> customPdfCompression() async {
  File originalPdf = File('path/to/document.pdf');
  File compressedPdf = await FileCompressor.compressPdf(
    file: originalPdf,
    compressionLevel: PdfCompressionLevel.normal,
  );
  print('Compressed PDF saved to: ${compressedPdf.path}');
}
```

## Additional Information

- The compressed files are saved to the temporary directory by default
- For production use, you may want to copy the compressed files to a permanent location
- This package uses [image_compression_flutter](https://pub.dev/packages/image_compression_flutter) for image compression and [syncfusion_flutter_pdf](https://pub.dev/packages/syncfusion_flutter_pdf) for PDF compression

## License

This project is licensed under the MIT License - see the LICENSE file for details.

```
