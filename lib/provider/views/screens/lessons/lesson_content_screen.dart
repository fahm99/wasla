import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../models/lesson_model.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/loading_widget.dart';

class LessonContentScreen extends StatefulWidget {
  final String lessonId;

  const LessonContentScreen({super.key, required this.lessonId});

  @override
  State<LessonContentScreen> createState() => _LessonContentScreenState();
}

class _LessonContentScreenState extends State<LessonContentScreen> {
  LessonModel? _lesson;
  bool _isLoading = true;
  String? _error;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    try {
      // In a real app, fetch from Supabase using lessonId
      setState(() => _isLoading = true);
      // Simulate loading - replace with actual Supabase call
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initVideoPlayer(String url) async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
      );
      if (mounted) setState(() {});
    } catch (e) {
      // Handle video error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(title: _lesson?.title ?? 'محتوى الدرس'),
        body: _isLoading
            ? const LoadingWidget(message: 'جاري تحميل المحتوى...')
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: AppTheme.redDanger),
                        const SizedBox(height: 16),
                        Text(_error!, style: const TextStyle(color: AppTheme.redDanger)),
                      ],
                    ),
                  )
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_lesson == null) {
      return const Center(child: Text('لم يتم العثور على الدرس'));
    }

    if (_lesson!.type == AppConstants.lessonTypeVideo && _lesson!.fileUrl != null) {
      return Column(
        children: [
          Expanded(
            child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam, size: 80, color: AppTheme.primaryDarkBlue),
                        SizedBox(height: 16),
                        Text('جاري تحميل الفيديو...'),
                      ],
                    ),
                  ),
          ),
        ],
      );
    }

    if (_lesson!.type == AppConstants.lessonTypeImage && _lesson!.fileUrl != null) {
      return Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: _lesson!.fileUrl!,
            fit: BoxFit.contain,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 80),
          ),
        ),
      );
    }

    // For PDF, Document, and Audio types
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primaryDarkBlue.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.insert_drive_file, size: 80, color: AppTheme.primaryDarkBlue),
            ),
            const SizedBox(height: 24),
            Text(
              _lesson!.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(_lesson!.type, style: const TextStyle(fontSize: 14, color: AppTheme.darkGrayText)),
            if (_lesson!.formattedFileSize.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(_lesson!.formattedFileSize, style: const TextStyle(fontSize: 13, color: AppTheme.darkGrayText)),
            ],
          ],
        ),
      ),
    );
  }
}
