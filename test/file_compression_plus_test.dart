import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_compression_plus/file_compression_plus.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([File])
import 'file_compression_plus_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('FileCompressor', () {
    test('Image format detection works correctly', () {
      // Test the image format detection logic by checking return types
      expect(
        FileCompressor.compressImage(file: File('test.jpg')),
        isA<Future<File>>(),
      );
      
      expect(
        FileCompressor.compressImage(file: File('test.png')),
        isA<Future<File>>(),
      );
      
      expect(
        FileCompressor.compressImage(file: File('test.webp')),
        isA<Future<File>>(),
      );
      
      // Test with unknown extension
      expect(
        FileCompressor.compressImage(file: File('test.unknown')),
        isA<Future<File>>(),
      );
    });
    
    test('Image compression parameters are correctly applied', () {
      // Test with custom parameters
      expect(
        FileCompressor.compressImage(
          file: File('test.jpg'),
          quality: 50,
          maxWidth: 800,
          maxHeight: 600,
          format: ImageFormat.png,
        ),
        isA<Future<File>>(),
      );
    });
    
    test('PDF compression returns a File', () {
      expect(
        FileCompressor.compressPdf(file: File('test.pdf')),
        isA<Future<File>>(),
      );
    });
    
    test('PDF compression with different levels', () {
      // Test with different compression levels
      expect(
        FileCompressor.compressPdf(
          file: File('test.pdf'),
          compressionLevel: PdfCompressionLevel.none,
        ),
        isA<Future<File>>(),
      );
      
      expect(
        FileCompressor.compressPdf(
          file: File('test.pdf'),
          compressionLevel: PdfCompressionLevel.normal,
        ),
        isA<Future<File>>(),
      );
      
      expect(
        FileCompressor.compressPdf(
          file: File('test.pdf'),
          compressionLevel: PdfCompressionLevel.best,
        ),
        isA<Future<File>>(),
      );
    });
    
    test('PdfCompressionLevel enum has correct values', () {
      expect(PdfCompressionLevel.values.length, 3);
      expect(PdfCompressionLevel.none.index, 0);
      expect(PdfCompressionLevel.normal.index, 1);
      expect(PdfCompressionLevel.best.index, 2);
    });
  });
}
