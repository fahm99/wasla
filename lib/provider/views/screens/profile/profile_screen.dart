import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'الملف الشخصي',
          showBack: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/profile/edit'),
            ),
          ],
        ),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDarkBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.yellowAccent,
                          backgroundImage: user?.avatar != null ? NetworkImage(user!.avatar!) : null,
                          child: user?.avatar == null
                              ? Text(
                                  user?.name.isNotEmpty == true ? user!.name[0] : 'م',
                                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? 'مزود الخدمة',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.yellowAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user?.subscriptionPlan ?? 'مجاني',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Info items
                  _buildInfoItem(context, icon: Icons.person_outline, title: 'الاسم', value: user?.name ?? ''),
                  _buildInfoItem(context, icon: Icons.email_outlined, title: 'البريد الإلكتروني', value: user?.email ?? ''),
                  _buildInfoItem(context, icon: Icons.phone_outlined, title: 'الهاتف', value: user?.phone ?? 'غير محدد'),
                  _buildInfoItem(context, icon: Icons.business_outlined, title: 'المؤسسة', value: user?.institutionName ?? 'غير محدد'),
                  _buildInfoItem(context, icon: Icons.lock_outline, title: 'تغيير كلمة المرور', value: '', onTap: () => context.push('/profile/change-password')),
                  const SizedBox(height: 24),
                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        authProvider.signOut();
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout, color: AppTheme.redDanger),
                      label: const Text('تسجيل الخروج', style: TextStyle(color: AppTheme.redDanger)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.redDanger),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: 3,
          onTap: (index) {},
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.primaryDarkBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppTheme.primaryDarkBlue, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.darkGrayText)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.primaryDarkBlue)),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.arrow_back_ios_new, size: 16, color: AppTheme.darkGrayText),
          ],
        ),
      ),
    );
  }
}
