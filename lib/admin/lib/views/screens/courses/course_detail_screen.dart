import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/courses_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/confirmation_dialog.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isActionLoading = false;

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppTheme.greenSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppTheme.redDanger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _updateStatus(String status, String actionName) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: '$actionName الكورس',
      message: 'هل أنت متأكد من $actionName هذا الكورس؟',
      confirmText: actionName,
      confirmColor: status == 'PUBLISHED'
          ? AppTheme.greenSuccess
          : AppTheme.orange,
    );

    if (confirmed == true) {
      setState(() => _isActionLoading = true);
      final provider =
          Provider.of<CoursesProvider>(context, listen: false);
      final success =
          await provider.updateCourseStatus(widget.courseId, status);
      setState(() => _isActionLoading = false);

      if (success) {
        _showSuccess('تم $actionName الكورس بنجاح');
      } else {
        _showError(provider.errorMessage ?? Constants.msgError);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PUBLISHED':
        return AppTheme.greenSuccess;
      case 'ARCHIVED':
        return AppTheme.orange;
      case 'DRAFT':
        return AppTheme.darkGrayText;
      case 'PENDING':
        return AppTheme.blueInfo;
      case 'REJECTED':
        return AppTheme.redDanger;
      default:
        return AppTheme.darkGrayText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrayBg,
      appBar: CustomAppBar(
        title: 'تفاصيل الكورس',
        showBack: true,
        backgroundColor: AppTheme.primaryDarkBlue,
      ),
        body: FutureBuilder(
          future: Provider.of<CoursesProvider>(context, listen: false)
              .getCourseDetail(widget.courseId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'حدث خطأ في تحميل البيانات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppTheme.redDanger,
                  ),
                ),
              );
            }

            final course = snapshot.data!;
            final statusColor = _getStatusColor(course.status);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Course Image
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    elevation: 3,
                    child: course.thumbnailUrl != null &&
                            course.thumbnailUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: course.thumbnailUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              height: 200,
                              color: AppTheme.lightGrayBg,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      AppTheme.primaryDarkBlue),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              height: 200,
                              color: AppTheme.primaryDarkBlue.withOpacity(0.08),
                              child: const Icon(Icons.school,
                                  size: 60, color: AppTheme.primaryDarkBlue),
                            ),
                          )
                        : Container(
                            height: 200,
                            color: AppTheme.primaryDarkBlue.withOpacity(0.08),
                            child: const Icon(Icons.school,
                                size: 60, color: AppTheme.primaryDarkBlue),
                          ),
                  ),
                  const SizedBox(height: 16),
                  // Course Info
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  course.title,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryDarkBlue,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  course.statusText,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (course.description != null &&
                              course.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              course.description!,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: AppTheme.darkGrayText,
                                height: 1.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          _infoRow('المقدم',
                              course.providerName ?? 'غير محدد'),
                          _infoRow('المستوى', course.levelText),
                          _infoRow('التصنيف', course.category),
                          if (course.price != null)
                            _infoRow('السعر', '${course.price} ر.س'),
                          if (course.studentCount != null)
                            _infoRow('عدد الطلاب', '${course.studentCount}'),
                          if (course.totalLessons != null)
                            _infoRow(
                                'عدد الدروس', '${course.totalLessons}'),
                          if (course.totalHours != null)
                            _infoRow(
                                'المدة الإجمالية', '${course.totalHours} ساعة'),
                          if (course.rating != null)
                            _infoRow('التقييم', '${course.rating} / 5'),
                          if (course.createdAt != null)
                            _infoRow('تاريخ الإنشاء',
                                DateFormat('yyyy/MM/dd').format(course.createdAt!)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons
                  if (course.status == 'ARCHIVED' || course.status == 'DRAFT')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isActionLoading
                            ? null
                            : () => _updateStatus('PUBLISHED', 'نشر'),
                        icon: const Icon(Icons.publish),
                        label: const Text(
                          'نشر الكورس',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.greenSuccess,
                          foregroundColor: AppTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  if (course.status == 'PUBLISHED')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isActionLoading
                            ? null
                            : () => _updateStatus('ARCHIVED', 'أرشفة'),
                        icon: const Icon(Icons.archive),
                        label: const Text(
                          'أرشفة الكورس',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.orange,
                          foregroundColor: AppTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppTheme.darkGrayText,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryDarkBlue,
            ),
          ),
        ],
      ),
    );
  }
}
