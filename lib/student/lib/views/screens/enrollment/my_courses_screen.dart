import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/app_theme.dart';
import '../../../providers/enrollment_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_nav.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  void _loadEnrollments() {
    context.read<EnrollmentProvider>().loadMyEnrollments();
  }

  Future<void> _refreshEnrollments() async {
    await context.read<EnrollmentProvider>().loadMyEnrollments();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EnrollmentProvider>();

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: const CustomAppBar(title: 'دوراتي', showBack: false),
      body: provider.isLoading
          ? const LoadingWidget(message: 'جاري تحميل الدورات...')
          : provider.enrollments.isEmpty
              ? const EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'لا توجد دورات مسجلة',
                  subtitle: 'ابدأ رحلتك التعليمية وسجل في دورات جديدة',
                  actionText: 'تصفح الدورات',
                )
              : RefreshIndicator(
                  color: AppTheme.primaryBlue,
                  onRefresh: _refreshEnrollments,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.enrollments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final enrollment = provider.enrollments[index];
                      return _buildEnrollmentCard(enrollment);
                    },
                  ),
                ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  Widget _buildEnrollmentCard(dynamic enrollment) {
    return GestureDetector(
      onTap: () => context.push('/courses/${enrollment.courseId}/content'),
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 80,
                height: 60,
                child: enrollment.courseImage != null
                    ? CachedNetworkImage(
                        imageUrl: enrollment.courseImage!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          child: const Icon(Icons.school,
                              color: AppTheme.primaryBlue),
                        ),
                      )
                    : Container(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        child: const Icon(Icons.school,
                            color: AppTheme.primaryBlue),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enrollment.courseTitle ?? 'دورة',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (enrollment.providerName != null)
                    Text(
                      enrollment.providerName!,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppTheme.greyText,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (enrollment.progress ?? 0) / 100,
                            backgroundColor: AppTheme.lightGrey,
                            valueColor: AlwaysStoppedAnimation(
                              (enrollment.progress ?? 0) >= 100
                                  ? AppTheme.successGreen
                                  : AppTheme.primaryBlue,
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(enrollment.progress ?? 0).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: (enrollment.progress ?? 0) >= 100
                              ? AppTheme.successGreen
                              : AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_left,
              color: AppTheme.greyText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
