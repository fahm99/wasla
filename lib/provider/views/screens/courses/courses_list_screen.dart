import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/course_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/course_card.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';

class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  String _filter = 'all'; // all, published, draft

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    await context.read<CourseProvider>().loadCourses();
  }

  List get _filteredCourses {
    final courses = context.watch<CourseProvider>().courses;
    if (_filter == 'all') return courses;
    if (_filter == 'published') {
      return courses.where((c) => c.status == 'PUBLISHED').toList();
    }
    return courses.where((c) => c.status == 'DRAFT').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'الدورات',
          showBack: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Search
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await context.push('/courses/new');
            _loadCourses();
          },
          backgroundColor: AppTheme.yellowAccent,
          foregroundColor: AppTheme.primaryDarkBlue,
          icon: const Icon(Icons.add),
          label: const Text(
            'دورة جديدة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            // Filter tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightGrayBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFilterTab('الكل', 'all'),
                  ),
                  Expanded(
                    child: _buildFilterTab('منشور', 'published'),
                  ),
                  Expanded(
                    child: _buildFilterTab('مسودة', 'draft'),
                  ),
                ],
              ),
            ),
            // Course list
            Expanded(
              child: Consumer<CourseProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const LoadingWidget(
                        message: 'جاري تحميل الدورات...');
                  }
                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 60, color: AppTheme.redDanger),
                          const SizedBox(height: 16),
                          Text(provider.error!,
                              style:
                                  const TextStyle(color: AppTheme.redDanger)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadCourses,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (_filteredCourses.isEmpty) {
                    return EmptyState(
                      title: 'لا توجد دورات',
                      message: _filter == 'all'
                          ? 'لم تقم بإنشاء أي دورة بعد. ابدأ بإنشاء دورتك الأولى!'
                          : 'لا توجد دورات بهذه الحالة',
                      icon: Icons.school_outlined,
                      buttonText: 'إنشاء دورة جديدة',
                      onButtonPressed: () async {
                        await context.push('/courses/new');
                        _loadCourses();
                      },
                    );
                  }
                  return RefreshIndicator(
                    color: AppTheme.primaryDarkBlue,
                    onRefresh: _loadCourses,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _filteredCourses.length,
                      itemBuilder: (context, index) {
                        return CourseCard(
                          course: _filteredCourses[index],
                          onPublish: () {
                            final course = _filteredCourses[index];
                            final publish = course.status != 'PUBLISHED';
                            provider
                                .publishCourse(course.id, publish)
                                .then((success) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(publish
                                        ? 'تم نشر الدورة'
                                        : 'تم إلغاء نشر الدورة'),
                                    backgroundColor: publish
                                        ? AppTheme.greenSuccess
                                        : AppTheme.yellowAccent,
                                  ),
                                );
                              }
                            });
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, String filter) {
    final isActive = _filter == filter;
    return GestureDetector(
      onTap: () => setState(() => _filter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryDarkBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.white : AppTheme.darkGrayText,
          ),
        ),
      ),
    );
  }
}
