import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

class EditorPipeline {
  /// Merges current and previous chunks and outputs a single MP4 path
  static Future<String?> mergeChunks(String? previous, String? current) async {
    if (previous == null && current == null) return null;
    if (previous == null) return current;
    if (current == null) return previous;

    final Directory extDir = await getTemporaryDirectory();
    final String listPath = '${extDir.path}/merge_list.txt';
    final String outPath = '${extDir.path}/merged_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // Create a text file with file paths for FFmpeg concat demuxer
    final file = File(listPath);
    await file.writeAsString("file '$previous'\nfile '$current'\n");

    final session = await FFmpegKit.execute('-f concat -safe 0 -i $listPath -c copy $outPath');
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outPath;
    }
    return current; // Fallback to current chunk
  }

  /// Auto-trims, applies 9:16 vertical crop, adds captions.
  static Future<String?> processHighlight({
    required String inputPath,
    bool verticalCrop = true,
    String? caption,
  }) async {
    final Directory extDir = await getTemporaryDirectory();
    final String outPath = '${extDir.path}/export_${DateTime.now().millisecondsSinceEpoch}.mp4';

    List<String> filters = [];
    
    // 9:16 Vertical Crop
    if (verticalCrop) {
      filters.add("crop=ih*9/16:ih");
    }

    // Dynamic Captions
    if (caption != null && caption.isNotEmpty) {
      // Basic text overlay. In a real app we'd load a local TTF.
      filters.add("drawtext=text='$caption':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2");
    }

    String filterStr = filters.isNotEmpty ? '-vf "${filters.join(',')}"' : '';
    // Optional: Auto-trim last 15 seconds: -sseof -15
    final session = await FFmpegKit.execute('-sseof -15 -i $inputPath $filterStr -y $outPath');
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outPath;
    }
    return null;
  }
}
