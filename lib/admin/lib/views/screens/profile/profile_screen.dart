import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/custom_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightGrayBg,
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            if (user == null) {
              return const Center(
                child: Text(
                  'لم يتم العثور على بيانات المستخدم',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppTheme.darkGrayText,
                  ),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                // Profile Header
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: AppTheme.primaryDarkBlue,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primaryDarkBlue,
                            Color(0xFF1A237E),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: AppTheme.yellowAccent,
                              backgroundImage:
                                  user.avatarUrl != null &&
                                          user.avatarUrl!.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          user.avatarUrl!)
                                      : null,
                              child: user.avatarUrl == null ||
                                      user.avatarUrl!.isEmpty
                                  ? Text(
                                      user.fullName.isNotEmpty
                                          ? user.fullName[0]
                                          : 'A',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primaryDarkBlue,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.yellowAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'مشرف النظام',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryDarkBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Profile Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Info Card
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'معلومات الحساب',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryDarkBlue,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _profileRow(Icons.person, 'الاسم',
                                    user.fullName),
                                _profileRow(Icons.email, 'البريد الإلكتروني',
                                    user.email),
                                if (user.phone != null)
                                  _profileRow(Icons.phone, 'رقم الهاتف',
                                      user.phone!),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Menu Items
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          child: Column(
                            children: [
                              _menuItem(
                                icon: Icons.settings,
                                title: 'الإعدادات',
                                subtitle: 'إعدادات التطبيق',
                                color: AppTheme.blueInfo,
                                onTap: () => context.push('/settings'),
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              _menuItem(
                                icon: Icons.lock,
                                title: 'تغيير كلمة المرور',
                                subtitle: 'تحديث كلمة المرور',
                                color: AppTheme.orange,
                                onTap: () =>
                                    context.push('/change-password'),
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              _menuItem(
                                icon: Icons.info_outline,
                                title: 'حول التطبيق',
                                subtitle: 'وصلة - لوحة تحكم المشرف',
                                color: AppTheme.darkGrayText,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Logout
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout,
                                color: AppTheme.redDanger),
                            label: const Text(
                              Constants.actionLogout,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.redDanger,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppTheme.redDanger, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'وصلة الإدارة v1.0.0',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: AppTheme.darkGrayText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 5),
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryDarkBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                color: AppTheme.primaryDarkBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppTheme.darkGrayText,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryDarkBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDarkBlue,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppTheme.darkGrayText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppTheme.darkGrayText),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'تسجيل الخروج',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryDarkBlue,
            ),
          ),
          content: const Text(
            'هل أنت متأكد من تسجيل الخروج؟',
            style: TextStyle(
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
                backgroundColor: AppTheme.redDanger,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                Constants.actionLogout,
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

    if (confirmed == true && mounted) {
      Provider.of<AuthProvider>(context, listen: false).logout();
      context.go('/login');
    }
  }
}
