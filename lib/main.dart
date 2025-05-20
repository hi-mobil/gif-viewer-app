import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

// 카테고리 모델 클래스
class Category {
  String id;
  String name;
  List<GifItem> gifs;

  Category({
    required this.id,
    required this.name,
    List<GifItem>? gifs,
  }) : gifs = gifs ?? [];
}

// GIF 아이템 모델 클래스
class GifItem {
  String id;
  String name;
  dynamic data; // File 또는 Uint8List
  DateTime createdAt;

  GifItem({
    required this.id,
    required this.name,
    required this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

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
  final ImagePicker _picker = ImagePicker();
  List<Category> _categories = [];
  Category? _selectedCategory;
  GifItem? _selectedGif;

  @override
  void initState() {
    super.initState();
    // 기본 카테고리 추가
    _categories.add(Category(
      id: DateTime.now().toString(),
      name: '기본',
    ));
    _selectedCategory = _categories.first;
  }

  Future<void> _pickGifFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null && _selectedCategory != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          if (image.name.toLowerCase().endsWith('.gif')) {
            final gifItem = GifItem(
              id: DateTime.now().toString(),
              name: image.name,
              data: bytes,
            );
            setState(() {
              _selectedCategory!.gifs.add(gifItem);
              _selectedGif = gifItem;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('GIF 파일만 선택할 수 있습니다.')),
            );
          }
        } else {
          if (image.path.toLowerCase().endsWith('.gif')) {
            final gifItem = GifItem(
              id: DateTime.now().toString(),
              name: image.name,
              data: File(image.path),
            );
            setState(() {
              _selectedCategory!.gifs.add(gifItem);
              _selectedGif = gifItem;
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

  void _addCategory() {
    showDialog(
      context: context,
      builder: (context) {
        String newCategoryName = '';
        return AlertDialog(
          title: const Text('새 카테고리'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: '카테고리 이름',
            ),
            onChanged: (value) => newCategoryName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (newCategoryName.isNotEmpty) {
                  setState(() {
                    _categories.add(Category(
                      id: DateTime.now().toString(),
                      name: newCategoryName,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  void _editCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) {
        String newName = category.name;
        return AlertDialog(
          title: const Text('카테고리 수정'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: '카테고리 이름',
            ),
            controller: TextEditingController(text: category.name),
            onChanged: (value) => newName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (newName.isNotEmpty) {
                  setState(() {
                    category.name = newName;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('수정'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('카테고리 삭제'),
          content: Text('${category.name} 카테고리를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _categories.remove(category);
                  if (_selectedCategory == category) {
                    _selectedCategory =
                        _categories.isNotEmpty ? _categories.first : null;
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GIF Viewer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCategory,
            tooltip: '새 카테고리',
          ),
        ],
      ),
      body: Row(
        children: [
          // 카테고리 사이드바
          Container(
            width: 200,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return ListTile(
                        title: Text(category.name),
                        selected: _selectedCategory == category,
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _editCategory(category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () => _deleteCategory(category),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // 메인 컨텐츠 영역
          Expanded(
            child: Column(
              children: [
                if (_selectedCategory != null) ...[
                  if (_selectedCategory!.gifs.isNotEmpty)
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _selectedCategory!.gifs.length,
                        itemBuilder: (context, index) {
                          final gif = _selectedCategory!.gifs[index];
                          return GestureDetector(
                            onTap: () => setState(() => _selectedGif = gif),
                            child: Card(
                              child: Stack(
                                children: [
                                  if (gif.data is File)
                                    Image.file(
                                      gif.data,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    )
                                  else if (gif.data is Uint8List)
                                    Image.memory(
                                      gif.data,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black54,
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                        gif.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    const Expanded(
                      child: Center(
                        child: Text(
                          '카테고리에 GIF가 없습니다',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                ],
                if (_selectedGif != null)
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(8),
                    child: Card(
                      child: _selectedGif!.data is File
                          ? Image.file(
                              _selectedGif!.data,
                              fit: BoxFit.contain,
                            )
                          : Image.memory(
                              _selectedGif!.data,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed:
                        _selectedCategory != null ? _pickGifFromGallery : null,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('갤러리에서 GIF 추가'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
