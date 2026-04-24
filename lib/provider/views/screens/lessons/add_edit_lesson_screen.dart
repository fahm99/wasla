import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/lesson_provider.dart';
import '../../../widgets/custom_app_bar.dart';

class AddEditLessonScreen extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final String? lessonId;

  const AddEditLessonScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
    this.lessonId,
  });

  @override
  State<AddEditLessonScreen> createState() => _AddEditLessonScreenState();
}

class _AddEditLessonScreenState extends State<AddEditLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();

  File? _selectedFile;
  String _fileName = '';
  int _fileSize = 0;
  String _lessonType = AppConstants.lessonTypeVideo;
  bool _isSubmitting = false;
  final double _uploadProgress = 0;

  bool get _isEditing => widget.lessonId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadLessonData();
    }
  }

  void _loadLessonData() {
    final provider = context.read<LessonProvider>();
    final lesson =
        provider.lessons.where((l) => l.id == widget.lessonId).firstOrNull;
    if (lesson != null) {
      _titleController.text = lesson.title;
      _lessonType = lesson.type;
      _fileName = lesson.fileName ?? '';
      _fileSize = lesson.fileSize ?? 0;
      _durationController.text = lesson.duration ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
          _fileSize = result.files.single.size;
        });
        _autoDetectType(_fileName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في اختيار الملف: $e')),
        );
      }
    }
  }

  void _autoDetectType(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) {
      setState(() => _lessonType = AppConstants.lessonTypeVideo);
    } else if (['pdf'].contains(ext)) {
      setState(() => _lessonType = AppConstants.lessonTypePdf);
    } else if (['mp3', 'wav', 'aac', 'ogg'].contains(ext)) {
      setState(() => _lessonType = AppConstants.lessonTypeAudio);
    } else if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      setState(() => _lessonType = AppConstants.lessonTypeImage);
    } else {
      setState(() => _lessonType = AppConstants.lessonTypeDocument);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes بايت';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} كيلوبايت';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} جيجابايت';
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case AppConstants.lessonTypeVideo:
        return Icons.videocam;
      case AppConstants.lessonTypePdf:
        return Icons.picture_as_pdf;
      case AppConstants.lessonTypeAudio:
        return Icons.audiotrack;
      case AppConstants.lessonTypeImage:
        return Icons.image;
      default:
        return Icons.description;
    }
  }

  Color _getFileColor(String type) {
    switch (type) {
      case AppConstants.lessonTypeVideo:
        return AppTheme.redDanger;
      case AppConstants.lessonTypePdf:
        return AppTheme.redDanger;
      case AppConstants.lessonTypeAudio:
        return AppTheme.greenSuccess;
      case AppConstants.lessonTypeImage:
        return Colors.purple;
      default:
        return AppTheme.blueInfo;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final provider = context.read<LessonProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updateLesson(
        lessonId: widget.lessonId!,
        title: _titleController.text.trim(),
        type: _lessonType,
        file: _selectedFile,
        fileName: _fileName.isNotEmpty ? _fileName : null,
        fileSize: _fileSize > 0 ? _fileSize : null,
        duration: _durationController.text.trim().isNotEmpty
            ? _durationController.text.trim()
            : null,
      );
    } else {
      final lesson = await provider.createLesson(
        title: _titleController.text.trim(),
        type: _lessonType,
        moduleId: widget.moduleId,
        order: provider.lessons.length,
        file: _selectedFile,
        fileName: _fileName.isNotEmpty ? _fileName : null,
        fileSize: _fileSize > 0 ? _fileSize : null,
        duration: _durationController.text.trim().isNotEmpty
            ? _durationController.text.trim()
            : null,
      );
      success = lesson != null;
    }

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'تم تحديث الدرس' : 'تم إنشاء الدرس'),
          backgroundColor: AppTheme.greenSuccess,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(provider.error ?? 'حدث خطأ'),
            backgroundColor: AppTheme.redDanger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileColor = _getFileColor(_lessonType);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar:
            CustomAppBar(title: _isEditing ? 'تعديل الدرس' : 'إضافة درس جديد'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الدرس',
                    prefixIcon: Icon(Icons.title_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'عنوان الدرس مطلوب'
                      : null,
                ),
                const SizedBox(height: 16),
                // Type dropdown
                DropdownButtonFormField2<String>(
                  value: _lessonType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'نوع الدرس',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: AppConstants.lessonTypeVideo,
                        child: Text('فيديو')),
                    DropdownMenuItem(
                        value: AppConstants.lessonTypePdf, child: Text('PDF')),
                    DropdownMenuItem(
                        value: AppConstants.lessonTypeDocument,
                        child: Text('مستند')),
                    DropdownMenuItem(
                        value: AppConstants.lessonTypeAudio,
                        child: Text('صوتي')),
                    DropdownMenuItem(
                        value: AppConstants.lessonTypeImage,
                        child: Text('صورة')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _lessonType = value);
                  },
                  dropdownStyleData: DropdownStyleData(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                // Duration
                TextFormField(
                  controller: _durationController,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'المدة (بالدقائق)',
                    prefixIcon: Icon(Icons.timer_outlined),
                    hintText: 'مثال: 30',
                    hintTextDirection: TextDirection.ltr,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                // File upload
                const Text(
                  'رفع ملف الدرس',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDarkBlue),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _isSubmitting ? null : _pickFile,
                  child: Container(
                    width: double.infinity,
                    padding: _selectedFile == null && _fileName.isEmpty
                        ? const EdgeInsets.all(32)
                        : const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedFile == null && _fileName.isEmpty
                          ? AppTheme.lightGrayBg
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.mediumGray),
                    ),
                    child: _selectedFile != null || _fileName.isNotEmpty
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: fileColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(_getFileIcon(_lessonType),
                                        color: fileColor, size: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedFile != null
                                              ? _selectedFile!.path
                                                  .split('/')
                                                  .last
                                              : _fileName,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryDarkBlue),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatFileSize(_fileSize),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.darkGrayText),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!_isSubmitting)
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: AppTheme.redDanger),
                                      onPressed: () {
                                        setState(() {
                                          _selectedFile = null;
                                          _fileName = '';
                                          _fileSize = 0;
                                        });
                                      },
                                    ),
                                ],
                              ),
                              if (_isSubmitting) ...[
                                const SizedBox(height: 12),
                                const LinearProgressIndicator(
                                    backgroundColor: AppTheme.mediumGray,
                                    color: AppTheme.primaryDarkBlue),
                              ],
                            ],
                          )
                        : Column(
                            children: [
                              Icon(Icons.cloud_upload_outlined,
                                  size: 48,
                                  color:
                                      AppTheme.darkGrayText.withOpacity(0.4)),
                              const SizedBox(height: 12),
                              Text('اضغط لاختيار ملف',
                                  style: TextStyle(
                                      color: AppTheme.darkGrayText
                                          .withOpacity(0.7))),
                              const SizedBox(height: 8),
                              Text('(فيديو، PDF، مستند، صوتي، صورة)',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.darkGrayText
                                          .withOpacity(0.5))),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDarkBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            _isEditing ? 'حفظ التعديلات' : 'إضافة الدرس',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
