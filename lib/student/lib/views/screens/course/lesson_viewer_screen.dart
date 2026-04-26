import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/loading_widget.dart';

class LessonViewerScreen extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final String lessonId;

  const LessonViewerScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
  });

  @override
  State<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends State<LessonViewerScreen> {
  Map<String, dynamic>? _lesson;
  bool _isLoading = true;
  String? _error;
  bool _isCompleted = false;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final lesson = await SupabaseService.getLessonById(widget.lessonId);
      final progress = await SupabaseService.getLessonProgress(widget.lessonId);

      setState(() {
        _lesson = {
          'id': lesson.id,
          'title': lesson.title,
          'type': lesson.type,
          'content': lesson.content,
          'file_url': lesson.fileUrl,
          'file_name': lesson.fileName,
          'file_size': lesson.fileSize,
          'duration': lesson.duration,
          'is_free': lesson.isFree,
          'order': lesson.order,
          'module_id': lesson.moduleId,
        };
        _isCompleted = progress['completed'] ?? false;
        _isLoading = false;
      });

      if (lesson.type == 'video' &&
          lesson.fileUrl != null &&
          lesson.fileUrl!.isNotEmpty) {
        _initVideoPlayer(lesson.fileUrl!);
      }
    } catch (e) {
      setState(() {
        _error = 'خطأ في تحميل الدرس';
        _isLoading = false;
      });
    }
  }

  void _initVideoPlayer(String url) {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      _videoController!.initialize().then((_) {
        if (mounted) {
          setState(() => _videoInitialized = true);
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: false,
            looping: false,
            showControls: true,
            aspectRatio: 16 / 9,
          );
        }
      }).catchError((e) {
        if (mounted) {
          setState(() => _videoInitialized = false);
        }
      });
    } catch (e) {
      _videoInitialized = false;
    }
  }

  Future<void> _markComplete() async {
    try {
      await SupabaseService.markLessonComplete(widget.lessonId);
      setState(() => _isCompleted = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(Constants.lessonCompleteSuccess),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في تحديث التقدم'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  Future<void> _openFile() async {
    if (_lesson?['file_url'] == null) return;
    final uri = Uri.parse(_lesson!['file_url']);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح الملف'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: CustomAppBar(
        title: _lesson?['title'] ?? 'الدرس',
        showBack: true,
        actions: [
          if (_isCompleted)
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(Icons.check_circle, color: AppTheme.successGreen),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'جاري تحميل الدرس...')
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!,
                          style: const TextStyle(
                              fontFamily: 'Cairo', fontSize: 14)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLesson,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
      bottomNavigationBar: _lesson != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCompleted
                          ? AppTheme.successGreen
                          : AppTheme.primaryBlue,
                    ),
                    onPressed: _isCompleted ? null : _markComplete,
                    child: Text(
                      _isCompleted ? '✓ تم الإكمال' : 'تحديد كمكتمل',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildContent() {
    final type = _lesson?['type'] ?? 'text';

    switch (type) {
      case 'video':
        return _buildVideoContent();
      case 'pdf':
        return _buildPdfContent();
      case 'image':
        return _buildImageContent();
      case 'file':
        return _buildFileContent();
      case 'audio':
        return _buildAudioContent();
      case 'text':
      default:
        return _buildTextContent();
    }
  }

  Widget _buildVideoContent() {
    if (!_videoInitialized || _chewieController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, size: 64, color: AppTheme.greyText),
            const SizedBox(height: 16),
            const Text(
              'لم يتم تحميل الفيديو',
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 16, color: AppTheme.greyText),
            ),
            if (_lesson?['file_url'] != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openFile,
                child: const Text('فتح الرابط'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Chewie(controller: _chewieController!),
        ),
      ],
    );
  }

  Widget _buildPdfContent() {
    final fileUrl = _lesson?['file_url'];
    if (fileUrl == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 64, color: AppTheme.greyText),
            SizedBox(height: 16),
            Text('لا يوجد ملف PDF',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    color: AppTheme.greyText)),
          ],
        ),
      );
    }

    return SfPdfViewer.network(fileUrl);
  }

  Widget _buildTextContent() {
    final content = _lesson?['content'];
    if (content == null || content.toString().isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد محتوى نصي',
          style: TextStyle(
              fontFamily: 'Cairo', fontSize: 16, color: AppTheme.greyText),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SelectableText(
          content.toString(),
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            color: AppTheme.darkText,
            height: 1.8,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    final imageUrl = _lesson?['file_url'];
    if (imageUrl == null) {
      return const Center(
        child: Text(
          'لا توجد صورة',
          style: TextStyle(
              fontFamily: 'Cairo', fontSize: 16, color: AppTheme.greyText),
        ),
      );
    }

    return InteractiveViewer(
      child: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (_, __) => const LoadingWidget(),
          errorWidget: (_, __, ___) => const Icon(Icons.broken_image,
              size: 64, color: AppTheme.greyText),
        ),
      ),
    );
  }

  Widget _buildFileContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.infoBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.insert_drive_file,
                  size: 40, color: AppTheme.infoBlue),
            ),
            const SizedBox(height: 16),
            Text(
              _lesson?['file_name'] ?? 'ملف',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
              textAlign: TextAlign.center,
            ),
            if (_lesson?['file_size'] != null) ...[
              const SizedBox(height: 8),
              Text(
                _formatFileSize(_lesson!['file_size']),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppTheme.greyText,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _openFile,
                icon: const Icon(Icons.download),
                label: const Text('تحميل / فتح الملف'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioContent() {
    final fileUrl = _lesson?['file_url'];
    if (fileUrl == null) {
      return const Center(
        child: Text(
          'لا يوجد ملف صوتي',
          style: TextStyle(
              fontFamily: 'Cairo', fontSize: 16, color: AppTheme.greyText),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.headphones,
                  size: 48, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              _lesson?['title'] ?? 'ملف صوتي',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openFile,
              icon: const Icon(Icons.play_arrow),
              label: const Text('تشغيل الصوت'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
