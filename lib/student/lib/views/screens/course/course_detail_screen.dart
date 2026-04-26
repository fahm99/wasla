import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/app_theme.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/enrollment_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/rating_stars.dart';
import '../../../widgets/loading_widget.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEnrolled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    context.read<CourseProvider>().loadCourseById(widget.courseId);
    _checkEnrollment();
  }

  Future<void> _checkEnrollment() async {
    await context.read<EnrollmentProvider>().loadEnrollment(widget.courseId);
    if (mounted) {
      setState(() {
        _isEnrolled = context.read<EnrollmentProvider>().currentEnrollment != null;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final course = courseProvider.currentCourse;

    if (courseProvider.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.lightBg,
        appBar: CustomAppBar(title: '', showBack: true),
        body: LoadingWidget(message: 'جاري تحميل الدورة...'),
      );
    }

    if (course == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightBg,
        appBar: const CustomAppBar(title: 'الدورة', showBack: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('الدورة غير موجودة', style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('العودة'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: AppTheme.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: course.image != null && course.image!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: course.image!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.primaryBlue,
                        child: const Center(
                          child: Icon(Icons.school, size: 80, color: AppTheme.white),
                        ),
                      ),
                    )
                  : Container(
                      color: AppTheme.primaryBlue,
                      child: const Center(
                        child: Icon(Icons.school, size: 80, color: AppTheme.white),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (course.shortDescription != null)
                    Text(
                      course.shortDescription!,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: AppTheme.greyText,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingStars(
                        rating: course.averageRating ?? 0,
                        reviewCount: course.ratingCount ?? 0,
                      ),
                      const Spacer(),
                      Text(
                        course.formattedPrice,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: course.price == 0 ? AppTheme.successGreen : AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _infoChip(Icons.schedule, course.formattedDuration),
                      const SizedBox(width: 10),
                      _infoChip(Icons.signal_cellular_alt, course.level),
                      const SizedBox(width: 10),
                      _infoChip(Icons.people, '${course.enrollmentsCount ?? 0} طالب'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (course.providerName != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppTheme.lightGrey,
                            backgroundImage: course.providerAvatar != null
                                ? CachedNetworkImageProvider(course.providerAvatar!)
                                : null,
                            child: course.providerAvatar == null
                                ? Text(
                                    course.providerName!.substring(0, 1),
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.darkText,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'المدرب',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10,
                                    color: AppTheme.greyText,
                                  ),
                                ),
                                Text(
                                  course.providerName!,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.darkText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildActionButtons(course),
                  const SizedBox(height: 16),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryBlue,
                    unselectedLabelColor: AppTheme.greyText,
                    indicatorColor: AppTheme.primaryBlue,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: 'نبذة عن الدورة'),
                      Tab(text: 'المتطلبات'),
                      Tab(text: 'الأهداف'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDescriptionTab(course.description),
                        _buildListTab(course.requirements, 'لا توجد متطلبات محددة'),
                        _buildListTab(course.objectives, 'لا توجد أهداف محددة'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.lightBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryBlue),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppTheme.darkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(dynamic course) {
    if (_isEnrolled) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successGreen,
          ),
          onPressed: () => context.push('/courses/${widget.courseId}/content'),
          child: const Text('متابعة التعلم'),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.push('/courses/${widget.courseId}/enroll'),
              child: Text(course.price == 0 ? 'سجل مجاناً' : 'سجل الآن'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primaryBlue),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: AppTheme.primaryBlue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('مشاركة الدورة')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionTab(String description) {
    return SingleChildScrollView(
      child: Text(
        description,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          color: AppTheme.darkText,
          height: 1.6,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildListTab(List<String> items, String emptyText) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: AppTheme.greyText,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.check_circle, size: 16, color: AppTheme.successGreen),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                items[index],
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppTheme.darkText,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
