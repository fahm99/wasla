import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../config/app_theme.dart';

class UploadWidget extends StatefulWidget {
  final String label;
  final String? acceptedExtensions;
  final File? initialFile;
  final Function(File file, String fileName, int fileSize)? onFileSelected;
  final VoidCallback? onFileRemoved;
  final bool isLoading;
  final double? progress;

  const UploadWidget({
    super.key,
    required this.label,
    this.acceptedExtensions,
    this.initialFile,
    this.onFileSelected,
    this.onFileRemoved,
    this.isLoading = false,
    this.progress,
  });

  @override
  State<UploadWidget> createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  File? _selectedFile;
  String? _fileName;
  int? _fileSize;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.initialFile;
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    switch (ext) {
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return Icons.videocam;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'mp3':
      case 'wav':
      case 'aac':
        return Icons.audiotrack;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    switch (ext) {
      case 'mp4':
      case 'mov':
      case 'avi':
        return AppTheme.redDanger;
      case 'pdf':
        return AppTheme.redDanger;
      case 'doc':
      case 'docx':
        return AppTheme.blueInfo;
      case 'mp3':
      case 'wav':
        return AppTheme.greenSuccess;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.purple;
      case 'zip':
      case 'rar':
        return Colors.orange;
      default:
        return AppTheme.darkGrayText;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes بايت';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} كيلوبايت';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} جيجابايت';
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        setState(() {
          _selectedFile = file;
          _fileName = result.files.single.name;
          _fileSize = result.files.single.size;
        });
        widget.onFileSelected?.call(file, _fileName!, _fileSize!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في اختيار الملف: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 8),
          if (_selectedFile == null)
            InkWell(
              onTap: widget.isLoading ? null : _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.mediumGray,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: AppTheme.darkGrayText.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'اضغط لاختيار ملف',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkGrayText.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightGrayBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.mediumGray),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getFileColor(_fileName!)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getFileIcon(_fileName!),
                          color: _getFileColor(_fileName!),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fileName!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryDarkBlue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatFileSize(_fileSize ?? 0),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.darkGrayText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!widget.isLoading)
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppTheme.redDanger),
                          onPressed: () {
                            setState(() {
                              _selectedFile = null;
                              _fileName = null;
                              _fileSize = null;
                            });
                            widget.onFileRemoved?.call();
                          },
                        ),
                    ],
                  ),
                  if (widget.isLoading && widget.progress != null) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: widget.progress,
                      backgroundColor: AppTheme.mediumGray,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryDarkBlue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'جاري الرفع... ${(widget.progress! * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkGrayText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
