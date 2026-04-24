import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/course_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/loading_widget.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CourseProvider>().loadCourseById(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'تفاصيل الدورة',
          actions: [
            Consumer<CourseProvider>(
              builder: (context, provider, child) {
                if (provider.currentCourse == null) return const SizedBox();
                return IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('حذف الدورة'),
                        content: const Text('هل أنت متأكد من حذف هذه الدورة؟ لا يمكن التراجع عن هذا الإجراء.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('إلغاء'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.redDanger,
                            ),
                            child: const Text('حذف'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && mounted) {
                      final success = await provider.deleteCourse(widget.courseId);
                      if (mounted) {
                        if (success) {
                          context.go('/courses');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.error ?? 'فشل في الحذف')),
                          );
                        }
                      }
                    }
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<CourseProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'جاري تحميل الدورة...');
            }
            final course = provider.currentCourse;
            if (course == null) {
              return const Center(child: Text('لم يتم العثور على الدورة'));
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course image
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 220,
                        color: AppTheme.primaryDarkBlue.withOpacity(0.1),
                        child: course.image != null && course.image!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: course.image!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(color: AppTheme.primaryDarkBlue),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.school,
                                  size: 80,
                                  color: AppTheme.primaryDarkBlue,
                                ),
                              )
                            : const Icon(
                                Icons.school,
                                size: 80,
                                color: AppTheme.primaryDarkBlue,
                              ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: course.status == 'منشور'
                                ? AppTheme.greenSuccess
                                : AppTheme.yellowAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            course.status,
                            style: TextStyle(
                              color: course.status == 'منشور' ? Colors.white : AppTheme.primaryDarkBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Info section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDarkBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInfoChip(Icons.category_outlined, course.category, AppTheme.blueInfo),
                            const SizedBox(width: 8),
                            _buildInfoChip(Icons.signal_cellular_alt, course.level, AppTheme.greenSuccess),
                            const SizedBox(width: 8),
                            if (course.price > 0)
                              _buildInfoChip(Icons.attach_money, '${course.price.toStringAsFixed(0)} ر.س', AppTheme.primaryDarkBlue),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          'وصف الدورة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDarkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          course.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.darkGrayText,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Stats row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(Icons.people_outline, '${course.studentsCount ?? 0}', 'طالب'),
                            ),
                            Expanded(
                              child: _buildStatItem(Icons.folder_outlined, '${course.modulesCount ?? 0}', 'وحدة'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await context.push('/courses/${course.id}/edit');
                                  provider.loadCourseById(course.id);
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('تعديل'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryDarkBlue,
                                  side: const BorderSide(color: AppTheme.primaryDarkBlue),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  provider.publishCourse(course.id, course.status != 'منشور');
                                },
                                icon: Icon(course.status == 'منشور' ? Icons.unpublished : Icons.publish),
                                label: Text(course.status == 'منشور' ? 'إلغاء النشر' : 'نشر الدورة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: course.status == 'منشور' ? AppTheme.redDanger : AppTheme.greenSuccess,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Course management links
                        _buildManagementItem(
                          context,
                          icon: Icons.view_module_outlined,
                          title: 'إدارة الوحدات والدروس',
                          subtitle: 'إضافة وتعديل وترتيب المحتوى',
                          onTap: () => context.push('/courses/${course.id}/modules'),
                        ),
                        const SizedBox(height: 8),
                        _buildManagementItem(
                          context,
                          icon: Icons.quiz_outlined,
                          title: 'إدارة الامتحانات',
                          subtitle: 'إنشاء وإدارة الامتحانات والأسئلة',
                          onTap: () => context.push('/courses/${course.id}/exams'),
                        ),
                        const SizedBox(height: 8),
                        _buildManagementItem(
                          context,
                          icon: Icons.people_outline,
                          title: 'قائمة الطلاب',
                          subtitle: 'عرض الطلاب المسجلين',
                          onTap: () => context.push('/courses/${course.id}/students'),
                        ),
                        const SizedBox(height: 8),
                        _buildManagementItem(
                          context,
                          icon: Icons.workspace_premium_outlined,
                          title: 'الشهادات',
                          subtitle: 'عرض وإصدار الشهادات',
                          onTap: () => context.push('/courses/${course.id}/certificates'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightGrayBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryDarkBlue, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.darkGrayText)),
        ],
      ),
    );
  }

  Widget _buildManagementItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.mediumGray),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryDarkBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryDarkBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.darkGrayText)),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_new, size: 16, color: AppTheme.darkGrayText),
          ],
        ),
      ),
    );
  }
}
