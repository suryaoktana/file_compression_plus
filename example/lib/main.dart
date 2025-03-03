import 'dart:io';
import 'package:file_compression_plus/file_compression_plus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Compression Plus Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _selectedFile;
  File? _compressedFile;
  bool _isCompressing = false;

  Future<void> _compressImage() async {
    if (_selectedFile == null) return;

    setState(() {
      _isCompressing = true;
    });

    try {
      final compressedFile = await FileCompressor.compressImage(
        file: _selectedFile!,
        quality: 70,
        maxWidth: 1280,
        maxHeight: 720,
      );

      setState(() {
        _compressedFile = compressedFile;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isCompressing = false;
      });
    }
  }

  Future<void> _compressPdf() async {
    if (_selectedFile == null) return;

    setState(() {
      _isCompressing = true;
    });

    try {
      final compressedFile = await FileCompressor.compressPdf(
        file: _selectedFile!,
        compressionLevel: PdfCompressionLevel.best,
      );

      setState(() {
        _compressedFile = compressedFile;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isCompressing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Compression Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isCompressing ? null : _compressImage,
                child: const Text('Compress Image'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isCompressing ? null : _compressPdf,
                child: const Text('Compress PDF'),
              ),
              if (_isCompressing) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
              if (_compressedFile != null) ...[
                const SizedBox(height: 16),
                Text('Compressed file saved to:\n${_compressedFile!.path}'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
