import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart' as picker;
import '../domain/entities/file_entity.dart';

class FilePickerProvider with ChangeNotifier {
  final List<FileEntity> _selectedFiles = [];
  List<FileEntity> _recentFiles = [];

  List<FileEntity> get selectedFiles => _selectedFiles;
  List<FileEntity> get recentFiles => _recentFiles;

  FilePickerProvider() {
    _loadRecentFiles();
  }

  void _loadRecentFiles() {
    // Mock recent files for UI demonstration
    _recentFiles = [
      FileEntity(
        id: '1',
        name: 'vacation.jpg',
        path: '/mock/path/vacation.jpg',
        size: 4718592, // 4.5 MB
        type: FileType.image,
        addedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      FileEntity(
        id: '2',
        name: 'project-final.mp4',
        path: '/mock/path/project-final.mp4',
        size: 1288490189, // 1.2 GB
        type: FileType.video,
        addedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      FileEntity(
        id: '3',
        name: 'podcast-ep3.mp3',
        path: '/mock/path/podcast-ep3.mp3',
        size: 33554432, // 32 MB
        type: FileType.audio,
        addedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<void> pickFiles() async {
    try {
      debugPrint('Opening file picker with multiple selection enabled...');
      final result = await picker.FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: picker.FileType.any,
        allowCompression: false,
      );

      if (result != null) {
        debugPrint('Files picked: ${result.files.length}');
        
        // Filter out duplicates by path
        final existingPaths = _selectedFiles.map((f) => f.path).toSet();
        
        final newFiles = result.files
            .where((file) => !existingPaths.contains(file.path))
            .map((file) {
          debugPrint('  - ${file.name} (${file.size} bytes)');
          return FileEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString() + file.name,
            name: file.name,
            path: file.path ?? '',
            size: file.size,
            type: FileType.fromExtension(file.extension ?? ''),
          );
        }).toList();

        if (newFiles.isNotEmpty) {
          _selectedFiles.addAll(newFiles);
          debugPrint('Added ${newFiles.length} new files. Total selected files: ${_selectedFiles.length}');
          notifyListeners();
        } else {
          debugPrint('No new files added (all were already selected)');
        }
      } else {
        debugPrint('File picker cancelled');
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    }
  }

  void removeFile(String fileId) {
    _selectedFiles.removeWhere((file) => file.id == fileId);
    notifyListeners();
  }

  void clearSelectedFiles() {
    _selectedFiles.clear();
    notifyListeners();
  }

  int get totalSize {
    return _selectedFiles.fold(0, (sum, file) => sum + file.size);
  }

  String get totalSizeFormatted {
    final size = totalSize;
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
