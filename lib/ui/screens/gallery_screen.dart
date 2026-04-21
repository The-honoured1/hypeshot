import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../services/gallery_service.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

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
    setState(() => _isLoading = true);
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
    final thumbPath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 300,
      quality: 75,
    );
    return thumbPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 24),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'gallery.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54))
                  : _clips.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(LucideIcons.packageOpen, color: AppTheme.textSecondary, size: 32),
                              SizedBox(height: 16),
                              Text('no captures yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 0.5)),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 9 / 16,
                          ),
                          itemCount: _clips.length,
                          itemBuilder: (context, index) {
                            final clip = _clips[index];
                            return GestureDetector(
                              onTap: () async {
                                await context.push('/preview', extra: clip.path);
                                _loadClips(); // Reload if deleted
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  color: AppTheme.surface,
                                  child: FutureBuilder<String?>(
                                    future: _getThumbnail(clip.path),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData && snapshot.data != null) {
                                        return Image.file(
                                          File(snapshot.data!),
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return const Center(child: Icon(LucideIcons.video, color: Colors.white24, size: 20));
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
