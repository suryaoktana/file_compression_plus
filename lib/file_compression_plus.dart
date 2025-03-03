library file_compression_plus;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Main class for file compression operations
class FileCompressor {
  /// Compresses an image file and returns the compressed file
  /// 
  /// [file] - The image file to compress
  /// [quality] - Quality of the compressed image (0-100, default: 80)
  /// [maxWidth] - Maximum width of the output image (default: 1920)
  /// [maxHeight] - Maximum height of the output image (default: 1080)
  /// [format] - Output format (default: original format)
  /// 
  /// Returns a [Future<File>] with the compressed image
  static Future<File> compressImage({
    required File file,
    int quality = 80,
    int maxWidth = 1920,
    int maxHeight = 1080,
    ImageFormat? format,
  }) async {
    try {
      final extension = path.extension(file.path).toLowerCase();
      
      format ??= _getImageFormatFromExtension(extension);
      
      final config = Configuration(
        outputType: format,
        quality: quality,
        size: ImageSize(width: maxWidth, height: maxHeight),
      );
      
      final input = ImageFile(
        rawBytes: await file.readAsBytes(),
        filePath: file.path,
      );
      
      final output = await compressInQueue(ImageFileConfiguration(
        input: input,
        config: config,
      ));
      
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputExtension = _getExtensionFromFormat(format);
      final outputPath = path.join(dir.path, 'compressed_${timestamp}${outputExtension}');
      
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(output.rawBytes);
      
      return outputFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing image: $e');
      }
      rethrow;
    }
  }
  
  /// Compresses a PDF file and returns the compressed file
  /// 
  /// [file] - The PDF file to compress
  /// [compressionLevel] - Level of compression (default: PdfCompressionLevel.best)
  /// 
  /// Returns a [Future<File>] with the compressed PDF
  static Future<File> compressPdf({
    required File file,
    PdfCompressionLevel compressionLevel = PdfCompressionLevel.best,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      
      document.compressionLevel = compressionLevel;
      
      final compressedBytes = await document.save();
      document.dispose();
      
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = path.join(dir.path, 'compressed_${timestamp}.pdf');
      
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(compressedBytes as List<int>);
      
      return outputFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing PDF: $e');
      }
      rethrow;
    }
  }
  
  /// Helper method to get image format from file extension
  static ImageFormat _getImageFormatFromExtension(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return ImageFormat.jpg;
      case '.png':
        return ImageFormat.png;
      case '.webp':
        return ImageFormat.webp;
      default:
        return ImageFormat.jpg;
    }
  }
  
  /// Helper method to get file extension from image format
  static String _getExtensionFromFormat(ImageFormat format) {
    switch (format) {
      case ImageFormat.jpg:
        return '.jpg';
      case ImageFormat.png:
        return '.png';
      case ImageFormat.webp:
        return '.webp';
      default:
        return '.jpg';
    }
  }
}

/// Enum for PDF compression levels
enum PdfCompressionLevel {
  /// No compression
  none,
  
  /// Normal compression
  normal,
  
  /// Best compression
  best
}
