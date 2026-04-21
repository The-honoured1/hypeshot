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
      maxHeight: 200,
      quality: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : _clips.isEmpty
                      ? _buildEmptyState()
                      : _buildGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'GALLERY',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: AppTheme.accentGlass(radius: BorderRadius.circular(12)),
            child: Text(
              '${_clips.length} CLIPS',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accentPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(LucideIcons.package, size: 48, color: AppTheme.textMuted),
          SizedBox(height: 16),
          Text('NO CAPTURES', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _clips.length,
      itemBuilder: (context, index) {
        final clip = _clips[index];
        return GestureDetector(
          onTap: () async {
            await context.push('/preview', extra: clip.path);
            _loadClips();
          },
          child: Container(
            decoration: AppTheme.surfaceCard(radius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FutureBuilder<String?>(
                  future: _getThumbnail(clip.path),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Image.file(File(snapshot.data!), fit: BoxFit.cover);
                    }
                    return Container(color: AppTheme.bgElevated);
                  },
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Icon(LucideIcons.play, size: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
