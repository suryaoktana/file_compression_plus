/// A library for compressing various file types including images and PDFs.
library file_compression_plus;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;

/// Supported image formats for compression.
enum ImageFormat {
  /// JPEG format
  jpg,
  /// PNG format
  png,
  /// WebP format
  webp
}

/// A utility class for compressing various file types.
/// 
/// This class provides static methods to compress images and PDF files
/// with customizable compression settings.
class FileCompressor {
  const FileCompressor._();

  /// Compresses an image file with specified parameters.
  /// 
  /// Parameters:
  /// - [file]: The source image file to compress
  /// - [quality]: Compression quality (0-100), default is 80
  /// - [maxWidth]: Maximum width of the output image, default is 1920
  /// - [maxHeight]: Maximum height of the output image, default is 1080
  /// - [format]: Target format for the compressed image
  /// - [deleteOriginal]: Whether to delete the original file after compression
  /// 
  /// Returns a [File] containing the compressed image.
  /// 
  /// Throws:
  /// - [ArgumentError] if quality is not between 0 and 100
  /// - [FileSystemException] if the file doesn't exist or is empty
  /// - [ArgumentError] if the image format is unsupported
  static Future<File> compressImage({
    required File file,
    int quality = 80,
    int maxWidth = 1920,
    int maxHeight = 1080,
    ImageFormat? format,
    bool deleteOriginal = false,
  }) async {
    if (quality < 0 || quality > 100) {
      throw ArgumentError('Quality must be between 0 and 100');
    }
    
    if (!await file.exists()) {
      throw FileSystemException('File does not exist', file.path);
    }
    
    final fileSize = await file.length();
    if (fileSize == 0) {
      throw FileSystemException('File is empty', file.path);
    }

    final extension = path.extension(file.path).toLowerCase();
    if (!['.jpg', '.jpeg', '.png', '.webp'].contains(extension)) {
      throw ArgumentError('Unsupported image format: $extension');
    }
    
    try {
      format ??= _getImageFormatFromExtension(extension);
      
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File(path.join(tempDir.path, 'temp_${timestamp}${extension}'));
      await file.copy(tempFile.path);
      
      final output = await FlutterImageCompress.compressWithFile(
        tempFile.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: format == ImageFormat.png ? CompressFormat.png : format == ImageFormat.webp ? CompressFormat.webp : CompressFormat.jpeg
      );
      
      await tempFile.delete();
      
      if (output == null || output.isEmpty) {
        throw Exception('Compression failed: output file is empty');
      }
      
      final outputExtension = _getExtensionFromFormat(format);
      final outputPath = path.join(tempDir.path, 'compressed_$timestamp$outputExtension');
      
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(output);

      
      if (deleteOriginal && await file.exists()) {
        await file.delete();
      }
      
      return outputFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing image: $e');
      }
      rethrow;
    }
  }
  
  static ImageFormat _getImageFormatFromExtension(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return ImageFormat.jpg;
      case '.png':
        return ImageFormat.png;
      case '.webp':
        return ImageFormat.webp;
    }
    throw ArgumentError('Unsupported image format: $extension');
  }

  static String _getExtensionFromFormat(ImageFormat format) {
    return switch (format) {
      ImageFormat.jpg => '.jpg',
      ImageFormat.png => '.png',
      ImageFormat.webp => '.webp'
    };
  }

  static Future<File> compressPdf({
    required File file,
    PdfCompressionLevel compressionLevel = PdfCompressionLevel.best,
    bool deleteOriginal = false,
  }) async {
    if (!await file.exists()) {
      throw FileSystemException('File does not exist', file.path);
    }
    
    final fileSize = await file.length();
    if (fileSize == 0) {
      throw FileSystemException('File is empty', file.path);
    }

    final extension = path.extension(file.path).toLowerCase();
    if (extension != '.pdf') {
      throw ArgumentError('Invalid file format: expected .pdf, got $extension');
    }
    
    syncfusion.PdfDocument? document;
    File? outputFile;
    try {
      final bytes = await file.readAsBytes();
      try {
        document = syncfusion.PdfDocument(inputBytes: bytes);
      } catch (e) {
        if (kDebugMode) {
          print('Error loading PDF: $e');
        }
        throw Exception('Invalid PDF file format');
      }
      
      if (document.pages.count == 0) {
        throw Exception('Invalid PDF file: document is empty');
      }
      
      switch (compressionLevel) {
        case PdfCompressionLevel.none:
          document.compressionLevel = syncfusion.PdfCompressionLevel.none;
          break;
        case PdfCompressionLevel.normal:
          document.compressionLevel = syncfusion.PdfCompressionLevel.normal;
          break;
        case PdfCompressionLevel.best:
          document.compressionLevel = syncfusion.PdfCompressionLevel.best;
          break;
      }
      
      for (int i = 0; i < document.pages.count; i++) {
        final page = document.pages[i];
        page.graphics.save();
      }
      
      final compressedBytes = await document.save();
      
      if (compressedBytes.isEmpty) {
        throw Exception('Compression failed: output file is empty');
      }
      
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = path.join(dir.path, 'compressed_${timestamp}.pdf');
      
      outputFile = File(outputPath);
      await outputFile.writeAsBytes(compressedBytes);
      
      if (deleteOriginal && await file.exists()) {
        await file.delete();
      }
      
      return outputFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing PDF: $e');
      }
      if (e is ArgumentError || e.toString().contains('Invalid PDF')) {
        throw Exception('Invalid PDF file format');
      }
      if (outputFile != null && await outputFile.exists()) {
        await outputFile.delete();
      }
      rethrow;
    } finally {
      document?.dispose();
    }
  }
}

enum PdfCompressionLevel {
  none,
  normal,
  best
}
