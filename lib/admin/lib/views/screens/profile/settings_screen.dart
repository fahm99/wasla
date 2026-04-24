import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';
import '../../../widgets/custom_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'العربية';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightGrayBg,
        appBar: const CustomAppBar(
          title: 'الإعدادات',
          showBack: true,
          backgroundColor: AppTheme.primaryDarkBlue,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // General Settings
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'عام',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryDarkBlue,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text(
                        'الإشعارات',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDarkBlue,
                        ),
                      ),
                      subtitle: const Text(
                        'تفعيل إشعارات التطبيق',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppTheme.darkGrayText,
                        ),
                      ),
                      value: _notificationsEnabled,
                      activeColor: AppTheme.primaryDarkBlue,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    SwitchListTile(
                      title: const Text(
                        'الوضع الليلي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDarkBlue,
                        ),
                      ),
                      subtitle: const Text(
                        'تفعيل المظهر الداكن',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppTheme.darkGrayText,
                        ),
                      ),
                      value: _darkMode,
                      activeColor: AppTheme.primaryDarkBlue,
                      onChanged: (value) {
                        setState(() => _darkMode = value);
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      title: const Text(
                        'اللغة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDarkBlue,
                        ),
                      ),
                      subtitle: Text(
                        _selectedLanguage,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppTheme.darkGrayText,
                        ),
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.blueInfo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.language,
                            color: AppTheme.blueInfo, size: 20),
                      ),
                      trailing: const Icon(Icons.chevron_left,
                          color: AppTheme.darkGrayText),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Platform Settings
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'المنصة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryDarkBlue,
                        ),
                      ),
                    ),
                    _settingItem(
                      icon: Icons.attach_money,
                      title: 'رسوم الاشتراك',
                      subtitle: 'إدارة رسوم الاشتراكات',
                      color: AppTheme.greenSuccess,
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _settingItem(
                      icon: Icons.security,
                      title: 'الصلاحيات',
                      subtitle: 'إدارة صلاحيات المستخدمين',
                      color: AppTheme.orange,
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _settingItem(
                      icon: Icons.backup,
                      title: 'النسخ الاحتياطي',
                      subtitle: 'إدارة النسخ الاحتياطي',
                      color: AppTheme.blueInfo,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // About
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
                        'حول التطبيق',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryDarkBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _aboutRow('اسم التطبيق', 'وصلة إدارة'),
                      _aboutRow('الإصدار', '1.0.0'),
                      _aboutRow('الإطار', 'Flutter 3.x'),
                      _aboutRow('القاعدة', 'Supabase'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingItem({
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
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

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppTheme.darkGrayText,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryDarkBlue,
            ),
          ),
        ],
      ),
    );
  }
}
