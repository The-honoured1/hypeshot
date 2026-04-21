import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GalleryService {
  static Future<Directory> getGalleryDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final galleryDir = Directory('${root.path}/Clips');
    if (!await galleryDir.exists()) {
      await galleryDir.create(recursive: true);
    }
    return galleryDir;
  }

  static Future<String> saveClipToGallery(String sourcePath) async {
    final galleryDir = await getGalleryDirectory();
    final fileName = 'hypeshot_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final savedPath = '${galleryDir.path}/$fileName';
    
    final sourceFile = File(sourcePath);
    await sourceFile.copy(savedPath);
    return savedPath;
  }

  static Future<List<File>> getSavedClips() async {
    final galleryDir = await getGalleryDirectory();
    final files = galleryDir.listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.mp4'))
        .toList();
    
    // Sort by most recent first
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }

  static Future<void> deleteClip(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
