import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_nav.dart';
import '../../../widgets/loading_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await SupabaseService.getStudentStats();
      setState(() {
        _stats = stats;
        _isLoadingStats = false;
      });
    } catch (_) {
      setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: TextStyle(fontFamily: 'Cairo', color: AppTheme.greyText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => context.push('/profile/edit'),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.white,
                          border: Border.all(color: AppTheme.white, width: 3),
                          image: user?.avatar != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(user!.avatar!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user?.avatar == null
                            ? Center(
                                child: Text(
                                  user?.initials ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'الطالب',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _isLoadingStats
                        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
                        : _buildStatsGrid(),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      icon: Icons.edit_outlined,
                      title: 'تعديل الملف الشخصي',
                      onTap: () => context.push('/profile/edit'),
                    ),
                    _buildMenuItem(
                      icon: Icons.emoji_events_outlined,
                      title: 'الإنجازات',
                      onTap: () => context.push('/profile/achievements'),
                    ),
                    _buildMenuItem(
                      icon: Icons.verified_outlined,
                      title: 'شهاداتي',
                      onTap: () => context.push('/certificates'),
                    ),
                    _buildMenuItem(
                      icon: Icons.menu_book_outlined,
                      title: 'دوراتي',
                      onTap: () => context.push('/my-courses'),
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'الإشعارات',
                      onTap: () => context.push('/notifications'),
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'تسجيل الخروج',
                      color: AppTheme.dangerRed,
                      onTap: _logout,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
    );
  }

  Widget _buildStatsGrid() {
    final stats = _stats ?? {};
    return Container(
      padding: const EdgeInsets.all(16),
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
          _buildStatItem(
            icon: Icons.school,
            label: 'الدورات',
            value: '${stats['total_enrollments'] ?? 0}',
            color: AppTheme.primaryBlue,
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'المكتملة',
            value: '${stats['completed_courses'] ?? 0}',
            color: AppTheme.successGreen,
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: Icons.verified,
            label: 'الشهادات',
            value: '${stats['total_certificates'] ?? 0}',
            color: AppTheme.secondaryAmber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: AppTheme.greyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      color: AppTheme.lightGrey,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (color ?? AppTheme.primaryBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color ?? AppTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color ?? AppTheme.darkText,
                ),
              ),
            ),
            Icon(
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
