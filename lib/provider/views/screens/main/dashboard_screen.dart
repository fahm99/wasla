import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/custom_bottom_nav.dart';
import '../../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    context.read<CourseProvider>().loadCourses();
    context.read<NotificationProvider>().loadNotifications();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    try {
      // Stats will be loaded from provider when connected
    } catch (e) {
      // Handle error
    }
    setState(() => _isLoadingStats = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: const CustomDrawer(currentRoute: '/dashboard'),
        appBar: CustomAppBar(
          title: 'لوحة التحكم',
          showBack: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push('/notifications'),
            ),
            Builder(
              builder: (context) => IconButton(
                icon: const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.yellowAccent,
                  child: Icon(Icons.person,
                      size: 18, color: AppTheme.primaryDarkBlue),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          color: AppTheme.primaryDarkBlue,
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryDarkBlue, Color(0xFF1A237E)],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مرحباً ${authProvider.user?.name ?? "مزود الخدمة"} 👋',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'إليك ملخص نشاطك اليوم',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.yellowAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.analytics,
                              color: AppTheme.yellowAccent,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Stats cards
                const Text(
                  'الإحصائيات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                _isLoadingStats
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                        children: [
                          StatCard(
                            title: 'إجمالي الدورات',
                            value: '${_stats?['totalCourses'] ?? '0'}',
                            icon: Icons.school_outlined,
                            iconColor: AppTheme.blueInfo,
                          ),
                          StatCard(
                            title: 'إجمالي الطلاب',
                            value: '${_stats?['totalStudents'] ?? '0'}',
                            icon: Icons.people_outline,
                            iconColor: AppTheme.greenSuccess,
                          ),
                          StatCard(
                            title: 'الشهادات الصادرة',
                            value: '${_stats?['totalCertificates'] ?? '0'}',
                            icon: Icons.emoji_events_outlined,
                            iconColor: AppTheme.yellowAccent,
                          ),
                          StatCard(
                            title: 'الإيرادات',
                            value:
                                '${(_stats?['totalRevenue'] ?? 0).toStringAsFixed(0)} ر.س',
                            icon: Icons.payments_outlined,
                            iconColor: AppTheme.primaryDarkBlue,
                          ),
                        ],
                      ),
                const SizedBox(height: 24),
                // Quick actions
                const Text(
                  'إجراءات سريعة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuickAction(
                  context,
                  icon: Icons.add_circle_outline,
                  title: 'إضافة دورة جديدة',
                  subtitle: 'إنشاء ونشر دورة تعليمية جديدة',
                  color: AppTheme.blueInfo,
                  onTap: () => context.push('/courses/new'),
                ),
                const SizedBox(height: 12),
                _buildQuickAction(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'إدارة المدفوعات',
                  subtitle: 'عرض وتتبع المدفوعات',
                  color: AppTheme.greenSuccess,
                  onTap: () => context.push('/payments'),
                ),
                const SizedBox(height: 12),
                _buildQuickAction(
                  context,
                  icon: Icons.card_membership_outlined,
                  title: 'إدارة الشهادات',
                  subtitle: 'إصدار وإدارة شهادات المتدربين',
                  color: AppTheme.yellowAccent,
                  onTap: () => context.push('/certificates/templates'),
                ),
                const SizedBox(height: 24),
                // Recent courses
                const Text(
                  'آخر الدورات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<CourseProvider>(
                  builder: (context, courseProvider, child) {
                    if (courseProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (courseProvider.courses.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 60,
                                color: AppTheme.darkGrayText.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'لم تقم بإنشاء أي دورة بعد',
                                style: TextStyle(
                                  color: AppTheme.darkGrayText,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => context.push('/courses/new'),
                                icon: const Icon(Icons.add),
                                label: const Text('إنشاء دورة جديدة'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: courseProvider.courses.length > 3
                          ? 3
                          : courseProvider.courses.length,
                      itemBuilder: (context, index) {
                        final course = courseProvider.courses[index];
                        return _buildRecentCourseItem(context, course);
                      },
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: 0,
          onTap: (index) {},
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDarkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkGrayText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_back_ios_new,
              color: AppTheme.darkGrayText.withOpacity(0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCourseItem(BuildContext context, dynamic course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryDarkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school,
              color: AppTheme.primaryDarkBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDarkBlue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${course.studentsCount ?? 0} طالب',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkGrayText,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: course.status == 'منشور'
                            ? AppTheme.greenSuccess.withOpacity(0.1)
                            : AppTheme.yellowAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.status ?? 'مسودة',
                        style: TextStyle(
                          fontSize: 11,
                          color: course.status == 'منشور'
                              ? AppTheme.greenSuccess
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
