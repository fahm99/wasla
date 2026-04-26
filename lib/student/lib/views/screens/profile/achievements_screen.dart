import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';
import '../../../widgets/custom_app_bar.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      {
        'icon': Icons.school,
        'title': 'الخطوة الأولى',
        'description': 'سجل في أول دورة',
        'color': AppTheme.primaryBlue,
        'unlocked': true,
      },
      {
        'icon': Icons.check_circle,
        'title': 'منجز',
        'description': 'أكمل أول دورة',
        'color': AppTheme.successGreen,
        'unlocked': true,
      },
      {
        'icon': Icons.verified,
        'title': 'حاصل على شهادة',
        'description': 'احصل على أول شهادة',
        'color': AppTheme.secondaryAmber,
        'unlocked': false,
      },
      {
        'icon': Icons.star,
        'title': 'متفوق',
        'description': 'حقق درجة 100% في اختبار',
        'color': AppTheme.infoBlue,
        'unlocked': false,
      },
      {
        'icon': Icons.local_fire_department,
        'title': 'متعلم نشط',
        'description': 'أكمل 5 دورات',
        'color': AppTheme.dangerRed,
        'unlocked': false,
      },
      {
        'icon': Icons.workspace_premium,
        'title': 'خبير',
        'description': 'أكمل 10 دورات',
        'color': Colors.purple,
        'unlocked': false,
      },
      {
        'icon': Icons.rate_review,
        'title': 'ناقد',
        'description': 'اكتب 5 تقييمات',
        'color': Colors.teal,
        'unlocked': false,
      },
      {
        'icon': Icons.quiz,
        'title': 'محارب الاختبارات',
        'description': 'أكمل 10 اختبارات',
        'color': Colors.orange,
        'unlocked': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: const CustomAppBar(title: 'الإنجازات', showBack: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          final isUnlocked = achievement['unlocked'] as bool;
          final color = achievement['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnlocked ? AppTheme.white : AppTheme.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: isUnlocked
                  ? Border.all(color: color.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isUnlocked ? color.withOpacity(0.1) : AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    achievement['icon'] as IconData,
                    color: isUnlocked ? color : AppTheme.greyText,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement['title'] as String,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isUnlocked ? AppTheme.darkText : AppTheme.greyText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement['description'] as String,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppTheme.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check,
                      color: color,
                      size: 18,
                    ),
                  )
                else
                  Icon(
                    Icons.lock_outline,
                    color: AppTheme.greyText.withOpacity(0.5),
                    size: 20,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
