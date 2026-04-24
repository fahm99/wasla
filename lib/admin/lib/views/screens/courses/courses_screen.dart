import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/courses_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_nav.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/tab_bar_widget.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final _searchController = TextEditingController();
  int _selectedTab = 0;
  final List<String> _tabs = [
    Constants.tabAll,
    'منشور',
    'مؤرشف',
    'مسودة',
  ];

  String _getFilterFromTab(int index) {
    switch (index) {
      case 0:
        return '';
      case 1:
        return 'PUBLISHED';
      case 2:
        return 'ARCHIVED';
      case 3:
        return 'DRAFT';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CoursesProvider>(context, listen: false).loadCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  Future<void> _handleArchive(String courseId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'أرشفة الكورس',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryDarkBlue,
            ),
          ),
          content: Text(
            'هل أنت متأكد من أرشفة كورس "$title"؟',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppTheme.darkGrayText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                Constants.actionCancel,
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'أرشفة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppTheme.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<CoursesProvider>(context, listen: false);
      final success = await provider.updateCourseStatus(courseId, 'ARCHIVED');
      if (success) {
        _showSuccess('تم أرشفة الكورس بنجاح');
      } else {
        _showError(provider.errorMessage ?? Constants.msgError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightGrayBg,
        appBar: CustomAppBar(
          title: Constants.titleCourses,
          showBack: false,
          backgroundColor: AppTheme.primaryDarkBlue,
        ),
        body: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  Provider.of<CoursesProvider>(context, listen: false)
                      .searchCourses(query);
                },
                decoration: InputDecoration(
                  hintText: 'بحث عن كورس...',
                  prefixIcon: const Icon(Icons.search,
                      color: AppTheme.darkGrayText),
                  filled: true,
                  fillColor: AppTheme.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTheme.primaryDarkBlue, width: 1.5),
                  ),
                ),
              ),
            ),
            // Tab Bar
            TabBarWidget(
              tabs: _tabs,
              selectedIndex: _selectedTab,
              onTabChanged: (index) {
                setState(() => _selectedTab = index);
                Provider.of<CoursesProvider>(context, listen: false)
                    .setFilter(_getFilterFromTab(index));
              },
            ),
            // Courses List
            Expanded(
              child: Consumer<CoursesProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const LoadingWidget(itemCount: 5);
                  }

                  if (provider.courses.isEmpty) {
                    return EmptyState(
                      icon: Icons.school_outlined,
                      title: Constants.msgNoData,
                      subtitle: 'لا توجد كورسات في هذا التصنيف',
                      onAction: () => provider.loadCourses(),
                      actionText: Constants.actionRefresh,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadCourses(),
                    color: AppTheme.primaryDarkBlue,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: provider.courses.length,
                      itemBuilder: (context, index) {
                        final course = provider.courses[index];
                        return _buildCourseCard(context, course, provider);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
      ),
    );
  }

  Widget _buildCourseCard(
      BuildContext context, course, CoursesProvider provider) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => context.push('/courses/${course.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: course.thumbnailUrl != null &&
                          course.thumbnailUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: course.thumbnailUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 80,
                            height: 80,
                            color: AppTheme.lightGrayBg,
                            child: const Icon(Icons.school,
                                color: AppTheme.darkGrayText),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: AppTheme.lightGrayBg,
                            child: const Icon(Icons.school,
                                color: AppTheme.darkGrayText),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDarkBlue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.school,
                              color: AppTheme.primaryDarkBlue, size: 32),
                        ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDarkBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (course.providerName != null)
                        Text(
                          course.providerName!,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: AppTheme.darkGrayText,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getCourseStatusColor(course.status)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              course.statusText,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getCourseStatusColor(course.status),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (course.price != null)
                            Text(
                              '${course.price} ر.س',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryDarkBlue,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Archive button
                if (course.status == 'PUBLISHED')
                  IconButton(
                    icon: const Icon(Icons.archive_outlined,
                        color: AppTheme.orange, size: 20),
                    onPressed: () =>
                        _handleArchive(course.id, course.title),
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCourseStatusColor(String status) {
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
}
