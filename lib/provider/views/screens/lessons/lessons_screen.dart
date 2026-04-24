import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/lesson_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/confirmation_dialog.dart';

class LessonsScreen extends StatefulWidget {
  final String courseId;
  final String moduleId;

  const LessonsScreen({super.key, required this.courseId, required this.moduleId});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    await context.read<LessonProvider>().loadLessons(widget.moduleId);
  }

  IconData _getLessonIcon(String type) {
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

  Color _getLessonColor(String type) {
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'إدارة الدروس'),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await context.push('/courses/${widget.courseId}/modules/${widget.moduleId}/lessons/new');
            _loadLessons();
          },
          backgroundColor: AppTheme.primaryDarkBlue,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('إضافة درس', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Consumer<LessonProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'جاري تحميل الدروس...');
            }
            if (provider.lessons.isEmpty) {
              return EmptyState(
                title: 'لا توجد دروس',
                message: 'ابدأ بإضافة دروس لهذه الوحدة',
                icon: Icons.play_circle_outline,
                buttonText: 'إضافة درس جديد',
                onButtonPressed: () async {
                  await context.push('/courses/${widget.courseId}/modules/${widget.moduleId}/lessons/new');
                  _loadLessons();
                },
              );
            }
            return ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.lessons.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = provider.lessons.removeAt(oldIndex);
                  provider.lessons.insert(newIndex, item);
                });
              },
              proxyDecorator: (child, index, animation) {
                return Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final lesson = provider.lessons[index];
                final color = _getLessonColor(lesson.type);
                return Container(
                  key: ValueKey(lesson.id),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(_getLessonIcon(lesson.type), color: color, size: 24),
                    ),
                    title: Text(lesson.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryDarkBlue)),
                    subtitle: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(lesson.type, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                        ),
                        if (lesson.formattedFileSize.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(lesson.formattedFileSize, style: const TextStyle(fontSize: 11, color: AppTheme.darkGrayText)),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primaryDarkBlue),
                          onPressed: () async {
                            await context.push(
                              '/courses/${widget.courseId}/modules/${widget.moduleId}/lessons/${lesson.id}/edit',
                            );
                            _loadLessons();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.redDanger),
                          onPressed: () async {
                            final confirm = await ConfirmationDialog.show(
                              context,
                              title: 'حذف الدرس',
                              message: 'هل أنت متأكد من حذف هذا الدرس؟',
                              isDanger: true,
                              confirmText: 'حذف',
                            );
                            if (confirm == true) {
                              await provider.deleteLesson(lesson.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم حذف الدرس'), backgroundColor: AppTheme.greenSuccess),
                                );
                              }
                            }
                          },
                        ),
                        const Icon(Icons.drag_handle, color: AppTheme.darkGrayText),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
