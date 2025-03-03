import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_compression_plus/file_compression_plus.dart';
import 'package:path/path.dart' as path;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/services.dart';

@GenerateMocks([File])
import 'file_compression_plus_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (methodCall) async {
      if (methodCall.method == 'getTemporaryDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    },
  );
  
  late File testImageFile;
  late File testPdfFile;
  late File emptyFile;
  
  setUpAll(() async {
    final testDir = Directory('test');
    testImageFile = File(path.join(testDir.path, '67beeca377f4e.png'));
    testPdfFile = File(path.join(testDir.path, 'Ultimate UI-Task.pdf'));
    
    emptyFile = File('${Directory.systemTemp.path}/empty.jpg');
    await emptyFile.writeAsBytes(Uint8List(0));
  });

  tearDownAll(() async {
    if (await emptyFile.exists()) {
      await emptyFile.delete();
    }
  });

  group('Image Compression', () {
    test('Image compression returns a File', () async {
      expect(
        FileCompressor.compressImage(file: testImageFile),
        isA<Future<File>>(),
      );
    });

    test('Image compression throws error for non-existent file', () async {
      final nonExistentFile = File('non_existent.jpg');
      expect(
        () => FileCompressor.compressImage(file: nonExistentFile),
        throwsA(isA<FileSystemException>().having(
          (e) => e.message,
          'message',
          contains('File does not exist'),
        )),
      );
    });
    
    test('Image compression with invalid parameters throws error', () {
      expect(
        () => FileCompressor.compressImage(
          file: testImageFile,
          quality: -1,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Quality must be between 0 and 100'),
        )),
      );
      
      expect(
        () => FileCompressor.compressImage(
          file: testImageFile,
          quality: 101,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Quality must be between 0 and 100'),
        )),
      );
    });

    test('Image compression reduces file size', () async {
      final originalSize = await testImageFile.length();
      final compressedFile = await FileCompressor.compressImage(
        file: testImageFile,
        quality: 50,
      );
      final compressedSize = await compressedFile.length();
      
      expect(compressedSize, lessThan(originalSize));
      await compressedFile.delete();
    });

    test('Image compression with format conversion', () async {
      final compressedFile = await FileCompressor.compressImage(
        file: testImageFile,
        format: ImageFormat.jpg,
      );
      
      expect(path.extension(compressedFile.path).toLowerCase(), equals('.jpg'));
      await compressedFile.delete();
    });
  });

  group('PDF Compression', () {
    test('PDF compression returns a File', () async {
      expect(
        FileCompressor.compressPdf(file: testPdfFile),
        isA<Future<File>>(),
      );
    });

    test('PDF compression throws error for invalid file format', () {
      expect(
        () => FileCompressor.compressPdf(file: testImageFile),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Invalid file format'),
        )),
      );
    });
    
    test('PDF compression throws error for empty file', () async {
      expect(
        () => FileCompressor.compressPdf(file: emptyFile),
        throwsA(isA<FileSystemException>().having(
          (e) => e.message,
          'message',
          contains('File is empty'),
        )),
      );
    });

    test('PDF compression throws error for non-existent file', () async {
      final nonExistentFile = File('non_existent.pdf');
      expect(
        () => FileCompressor.compressPdf(file: nonExistentFile),
        throwsA(isA<FileSystemException>().having(
          (e) => e.message,
          'message',
          contains('File does not exist'),
        )),
      );
    });
    
    test('PDF compression produces valid output file', () async {
      final compressedFile = await FileCompressor.compressPdf(
        file: testPdfFile,
        compressionLevel: PdfCompressionLevel.best,
      );
      
      expect(await compressedFile.exists(), isTrue);
      expect(await compressedFile.length(), greaterThan(0));
      await compressedFile.delete();
    });

    test('PDF compression with different compression levels produces valid files', () async {
      final compressedNone = await FileCompressor.compressPdf(
        file: testPdfFile,
        compressionLevel: PdfCompressionLevel.none,
      );
      
      final compressedBest = await FileCompressor.compressPdf(
        file: testPdfFile,
        compressionLevel: PdfCompressionLevel.best,
      );
      
      expect(await compressedNone.exists(), isTrue);
      expect(await compressedBest.exists(), isTrue);
      expect(await compressedNone.length(), greaterThan(0));
      expect(await compressedBest.length(), greaterThan(0));
      
      await compressedNone.delete();
      await compressedBest.delete();
    });
  });
}
