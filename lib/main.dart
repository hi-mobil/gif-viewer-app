import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GIF Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GifViewerPage(),
    );
  }
}

class GifViewerPage extends StatefulWidget {
  const GifViewerPage({super.key});

  @override
  State<GifViewerPage> createState() => _GifViewerPageState();
}

class _GifViewerPageState extends State<GifViewerPage> {
  File? _selectedGif;
  Uint8List? _selectedGifBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickGifFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          if (image.name.toLowerCase().endsWith('.gif')) {
            setState(() {
              _selectedGifBytes = bytes;
              _selectedGif = null;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('GIF 파일만 선택할 수 있습니다.')),
            );
          }
        } else {
          if (image.path.toLowerCase().endsWith('.gif')) {
            setState(() {
              _selectedGif = File(image.path);
              _selectedGifBytes = null;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('GIF 파일만 선택할 수 있습니다.')),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GIF 파일을 선택하는 중 오류가 발생했습니다: $e')),
      );
    }
  }

  Future<void> _pickGifFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gif'],
        withData: true,
      );

      if (result != null) {
        if (kIsWeb) {
          if (result.files.single.bytes != null) {
            setState(() {
              _selectedGifBytes = result.files.single.bytes;
              _selectedGif = null;
            });
          }
        } else {
          setState(() {
            _selectedGif = File(result.files.single.path!);
            _selectedGifBytes = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GIF 파일을 선택하는 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GIF Viewer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedGif != null) ...[
              Expanded(
                child: Image.file(
                  _selectedGif!,
                  fit: BoxFit.contain,
                ),
              ),
            ] else if (_selectedGifBytes != null) ...[
              Expanded(
                child: Image.memory(
                  _selectedGifBytes!,
                  fit: BoxFit.contain,
                ),
              ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Text(
                    'GIF 파일을 선택해주세요',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickGifFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('갤러리에서 선택'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickGifFromFile,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('파일에서 선택'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
