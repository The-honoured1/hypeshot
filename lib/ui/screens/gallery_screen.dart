import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme.dart';
import '../../services/gallery_service.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<File> _clips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClips();
  }

  Future<void> _loadClips() async {
    final clips = await GalleryService.getSavedClips();
    if (mounted) {
      setState(() {
        _clips = clips;
        _isLoading = false;
      });
    }
  }

  Future<String?> _getThumbnail(String videoPath) async {
    final tempDir = await getTemporaryDirectory();
    return await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 150,
      quality: 40,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GALLERY',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.refreshCw, size: 16, color: AppTheme.textDim),
                        onPressed: _loadClips,
                      ),
                      Text(
                        '${_clips.length} CLIPS',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textDim, letterSpacing: 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textDim))
                  : _clips.isEmpty
                      ? _buildEmptyState()
                      : _buildGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(LucideIcons.package, size: 40, color: AppTheme.borderThin),
          SizedBox(height: 16),
          Text(
            'STASH EMPTY',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppTheme.textDim, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: _clips.length,
      itemBuilder: (context, index) {
        final media = _clips[index];
        final isImage = media.path.endsWith('.jpg') || media.path.endsWith('.jpeg');

        return GestureDetector(
          onTap: () async {
            await context.push('/preview', extra: media.path);
            _loadClips();
          },
          onLongPress: () async {
             await GalleryService.deleteClip(media.path);
             _loadClips();
          },
          child: Container(
            decoration: AppTheme.studioCard(),
            clipBehavior: Clip.antiAlias,
            child: isImage
                ? Image.file(media, fit: BoxFit.cover)
                : FutureBuilder<String?>(
                    future: _getThumbnail(media.path),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Image.file(File(snapshot.data!), fit: BoxFit.cover);
                      }
                      return Container(color: AppTheme.bgElevated);
                    },
                  ),
          ),
        );
      },
    );
  }
}
