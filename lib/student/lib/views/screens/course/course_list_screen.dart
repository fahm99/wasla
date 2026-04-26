import 'package:flutter/material.dart' hide FilterChip;
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/course_provider.dart';
import '../../../widgets/course_card.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/custom_bottom_nav.dart';
import '../../../widgets/filter_chip.dart';
import '../../../config/constants.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  String? _selectedCategory;
  String? _selectedLevel;
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    context.read<CourseProvider>().loadPublishedCourses(
          category: _selectedCategory,
          level: _selectedLevel,
          sortBy: _sortBy,
          refresh: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
        elevation: 0,
        title: const Text(
          'الدورات',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: Constants.levels.map((level) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FilterChip(
                          label: level,
                          selected: _selectedLevel == level,
                          onSelected: (_) {
                            setState(() {
                              _selectedLevel =
                                  _selectedLevel == level ? null : level;
                            });
                            _loadCourses();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'ترتيب:',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppTheme.greyText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _sortBy,
                      underline: const SizedBox.shrink(),
                      isDense: true,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'newest', child: Text('الأحدث')),
                        DropdownMenuItem(
                            value: 'rating', child: Text('الأعلى تقييماً')),
                        DropdownMenuItem(
                            value: 'popular', child: Text('الأكثر شعبية')),
                        DropdownMenuItem(
                            value: 'price_low', child: Text('السعر: الأقل')),
                        DropdownMenuItem(
                            value: 'price_high', child: Text('السعر: الأعلى')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _sortBy = value);
                          _loadCourses();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 3,
                    itemBuilder: (_, __) => const ShimmerCourseCard(),
                  )
                : provider.courses.isEmpty
                    ? const EmptyState(
                        icon: Icons.school_outlined,
                        title: 'لا توجد دورات',
                        subtitle: 'لم يتم العثور على دورات مطابقة',
                      )
                    : RefreshIndicator(
                        color: AppTheme.primaryBlue,
                        onRefresh: () async => _loadCourses(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.courses.length,
                          itemBuilder: (context, index) {
                            return CourseCard(course: provider.courses[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}
