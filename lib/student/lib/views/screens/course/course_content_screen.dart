import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../models/module_model.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/lesson_item.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class CourseContentScreen extends StatefulWidget {
  final String courseId;

  const CourseContentScreen({super.key, required this.courseId});

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  List<ModuleModel> _modules = [];
  bool _isLoading = true;
  double _overallProgress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final modules = await SupabaseService.getModulesByCourse(widget.courseId);
      await SupabaseService.getCourseProgress(widget.courseId);

      int totalLessons = 0;
      int completedLessons = 0;
      for (final m in modules) {
        totalLessons += m.totalLessons;
        completedLessons += m.completedLessons;
      }

      setState(() {
        _modules = modules;
        _overallProgress =
            totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'خطأ في تحميل المحتوى';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: const CustomAppBar(title: 'محتوى الدورة', showBack: true),
      body: _isLoading
          ? const LoadingWidget(message: 'جاري تحميل المحتوى...')
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
                        onPressed: _loadContent,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.primaryBlue,
                  onRefresh: _loadContent,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildProgressCard(),
                      const SizedBox(height: 16),
                      if (_modules.isEmpty)
                        const EmptyState(
                          icon: Icons.folder_open,
                          title: 'لا يوجد محتوى',
                          subtitle: 'لم يتم إضافة محتوى لهذه الدورة بعد',
                        )
                      else
                        ..._modules
                            .map((module) => _buildModuleSection(module)),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'التقدم الكلي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkText,
                ),
              ),
              Text(
                '${_overallProgress.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _overallProgress / 100,
              backgroundColor: AppTheme.lightGrey,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleSection(ModuleModel module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.only(bottom: 8, right: 16, left: 16),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${module.order + 1}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
          title: Text(
            module.title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkText,
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                '${module.completedLessons}/${module.totalLessons} دروس',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppTheme.greyText,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${module.progress.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: module.progress >= 1.0
                      ? AppTheme.successGreen
                      : AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          children: module.lessons.map((lesson) {
            return LessonItem(
              lesson: lesson,
              index: module.lessons.indexOf(lesson) + 1,
              onTap: () {
                context.push(
                  '/courses/${widget.courseId}/modules/${module.id}/lessons/${lesson.id}',
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
