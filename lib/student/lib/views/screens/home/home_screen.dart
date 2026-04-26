import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/banner_slider.dart';
import '../../../widgets/course_card.dart';
import '../../../widgets/custom_bottom_nav.dart';
import '../../../widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<CourseProvider>().loadPublishedCourses(refresh: true);
    context.read<NotificationProvider>().loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: RefreshIndicator(
        color: AppTheme.primaryBlue,
        onRefresh: () async {
          _loadData();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: AppTheme.primaryBlue,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(right: 16, left: 16, bottom: 16),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'وسلة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.white,
                          ),
                        ),
                        Text(
                          'مرحباً ${context.watch<AuthProvider>().user?.name ?? ''}',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: AppTheme.white),
                      onPressed: () => context.push('/notifications'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildBannerSlider(),
            ),
            SliverToBoxAdapter(
              child: _buildCategories(),
            ),
            SliverToBoxAdapter(
              child: _buildSectionTitle('الدورات المميزة', onSeeAll: () => context.push('/courses')),
            ),
            SliverToBoxAdapter(
              child: _buildFeaturedCourses(),
            ),
            SliverToBoxAdapter(
              child: _buildSectionTitle('أحدث الدورات', onSeeAll: () => context.push('/courses')),
            ),
            SliverToBoxAdapter(
              child: _buildLatestCourses(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  Widget _buildBannerSlider() {
    final banners = [
      BannerItem(
        title: 'ابدأ رحلتك التعليمية',
        subtitle: 'دورات متنوعة في مختلف المجالات',
        tag: 'جديد',
        gradientColors: const [Color(0xFF1E40AF), Color(0xFF3B82F6)],
      ),
      BannerItem(
        title: 'تعلّم من أفضل المدربين',
        subtitle: 'محتوى عالي الجودة',
        tag: 'مميز',
        gradientColors: const [Color(0xFF7C3AED), Color(0xFFA78BFA)],
      ),
      BannerItem(
        title: 'احصل على شهادات معتمدة',
        subtitle: 'عزّز سيرتك الذاتية',
        tag: 'شهادات',
        gradientColors: const [Color(0xFF059669), Color(0xFF34D399)],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BannerSlider(
        height: 160,
        items: banners,
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      children: [
        _buildSectionTitle('التصنيفات'),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: Constants.categories.length > 8 ? 8 : Constants.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = Constants.categories[index];
              final icons = [
                Icons.code, Icons.phone_android, Icons.psychology,
                Icons.palette, Icons.business, Icons.campaign,
                Icons.analytics, Icons.security,
              ];
              final colors = [
                AppTheme.primaryBlue, AppTheme.successGreen, Colors.purple,
                Colors.pink, AppTheme.secondaryAmber, AppTheme.infoBlue,
                Colors.teal, AppTheme.dangerRed,
              ];

              return GestureDetector(
                onTap: () => context.push('/search?category=$category'),
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icons[index % icons.length],
                          color: colors[index % colors.length],
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkText,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkText,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'عرض الكل',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCourses() {
    final courseProvider = context.watch<CourseProvider>();

    if (courseProvider.isLoading) {
      return SizedBox(
        height: 240,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => const ShimmerCourseCard(),
        ),
      );
    }

    if (courseProvider.courses.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'لا توجد دورات حالياً',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppTheme.greyText,
            ),
          ),
        ),
      );
    }

    final featured = courseProvider.courses.where((c) => c.averageRating != null && c.averageRating! >= 4.0).toList();
    final displayCourses = featured.isNotEmpty ? featured : courseProvider.courses.take(5).toList();

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: displayCourses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 220,
            child: CourseCard(course: displayCourses[index]),
          );
        },
      ),
    );
  }

  Widget _buildLatestCourses() {
    final courseProvider = context.watch<CourseProvider>();

    if (courseProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ShimmerCourseCard(),
      );
    }

    if (courseProvider.courses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: courseProvider.courses.take(3).map((course) {
          return CourseCard(course: course);
        }).toList(),
      ),
    );
  }
}
