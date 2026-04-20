import 'package:share_plus/share_plus.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

class ShareService {
  static Future<void> shareToPlatform(String path, {String? text}) async {
    await Share.shareXFiles([XFile(path)], text: text ?? 'Check out my clutch move on HypeShot! 🔥');
  }

  static Future<bool> saveToGallery(String path) async {
    try {
      final result = await GallerySaver.saveVideo(path);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
