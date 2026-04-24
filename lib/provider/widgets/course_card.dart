import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../config/constants.dart';
import '../models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPublish;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    final isPublished = course.status == AppConstants.statusPublished;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: onTap ?? () => context.push('/courses/${course.id}'),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      color: AppTheme.lightGrayBg,
                      child: course.image != null && course.image!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: course.image!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryDarkBlue,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppTheme.primaryDarkBlue.withOpacity(0.1),
                                child: const Icon(
                                  Icons.school,
                                  size: 60,
                                  color: AppTheme.primaryDarkBlue,
                                ),
                              ),
                            )
                          : Container(
                              color: AppTheme.primaryDarkBlue.withOpacity(0.1),
                              child: const Icon(
                                Icons.school,
                                size: 60,
                                color: AppTheme.primaryDarkBlue,
                              ),
                            ),
                    ),
                    // Status badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isPublished
                              ? AppTheme.greenSuccess
                              : AppTheme.yellowAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isPublished ? 'منشور' : 'مسودة',
                          style: TextStyle(
                            color: isPublished ? Colors.white : AppTheme.primaryDarkBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Price
                    if (course.price > 0)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDarkBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${course.price.toStringAsFixed(0)} ر.س',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDarkBlue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDarkBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course.level,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryDarkBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.blueInfo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course.category,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.blueInfo,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat(
                          Icons.people_outline,
                          '${course.studentsCount ?? 0} طالب',
                        ),
                        _buildStat(
                          Icons.folder_outlined,
                          '${course.modulesCount ?? 0} وحدة',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onEdit ??
                                () => context.push('/courses/${course.id}/edit'),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('تعديل'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryDarkBlue,
                              side: const BorderSide(color: AppTheme.primaryDarkBlue),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onPublish ??
                                () {
                                  // Toggle publish state
                                },
                            icon: Icon(
                              isPublished
                                  ? Icons.unpublished
                                  : Icons.publish,
                              size: 18,
                            ),
                            label: Text(isPublished ? 'إلغاء النشر' : 'نشر'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPublished
                                  ? AppTheme.redDanger
                                  : AppTheme.greenSuccess,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.darkGrayText),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.darkGrayText,
          ),
        ),
      ],
    );
  }
}
