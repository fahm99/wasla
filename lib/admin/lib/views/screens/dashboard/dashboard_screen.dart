import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../models/monthly_stats_model.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_nav.dart';
import '../../../widgets/stat_card.dart';
import '../../../widgets/user_item.dart';
import '../../../widgets/chart_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false)
          .loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightGrayBg,
        appBar: CustomAppBar(
          title: Constants.titleDashboard,
          backgroundColor: AppTheme.primaryDarkBlue,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.white),
              onPressed: () {
                Provider.of<DashboardProvider>(context, listen: false)
                    .loadDashboardData();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.white),
              onPressed: () => _logout(),
            ),
          ],
        ),
        body: Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingWidget(itemCount: 8);
            }

            return RefreshIndicator(
              onRefresh: () => provider.loadDashboardData(),
              color: AppTheme.primaryDarkBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Greeting
                    _buildGreeting(context),
                    const SizedBox(height: 16),
                    // Stats Cards
                    _buildStatsCards(provider),
                    const SizedBox(height: 16),
                    // Monthly Accounts Chart
                    _buildMonthlyChart(provider),
                    const SizedBox(height: 16),
                    // Pending Accounts
                    _buildPendingAccounts(provider),
                    // Quick Actions
                    const SizedBox(height: 16),
                    _buildQuickActions(context),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final name = authProvider.user?.fullName ?? 'المشرف';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً، $name 👋',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'إليك ملخص اليوم',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppTheme.darkGrayText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(DashboardProvider provider) {
    final stats = provider.stats;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
          StatCard(
            title: Constants.statActiveProviders,
            value: '${stats.activeProviders}',
            icon: Icons.people,
            iconColor: AppTheme.greenSuccess,
            onTap: () => context.go('/accounts'),
          ),
          StatCard(
            title: Constants.statPendingAccounts,
            value: '${stats.pendingAccounts}',
            icon: Icons.pending_actions,
            iconColor: AppTheme.orange,
            onTap: () => context.go('/accounts'),
          ),
          StatCard(
            title: Constants.statSuspendedAccounts,
            value: '${stats.suspendedAccounts}',
            icon: Icons.block,
            iconColor: AppTheme.redDanger,
            onTap: () => context.go('/accounts'),
          ),
          StatCard(
            title: Constants.statTotalRevenue,
            value: '${stats.totalRevenue.toStringAsFixed(0)} ر.س',
            icon: Icons.attach_money,
            iconColor: AppTheme.blueInfo,
            onTap: () => context.go('/reports'),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(DashboardProvider provider) {
    return ChartWidget(
      title: 'الحسابات الشهرية',
      trailing: const Text(
        'آخر 6 أشهر',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          color: AppTheme.darkGrayText,
        ),
      ),
      child: provider.monthlyStats.isEmpty
          ? const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'لا توجد بيانات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppTheme.darkGrayText,
                  ),
                ),
              ),
            )
          : SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final stats = provider.monthlyStats;
                          final index = value.toInt();
                          if (index < 0 || index >= stats.length) {
                            return const SizedBox();
                          }
                          final monthLabel =
                              stats[index].formattedMonth.split(' ');
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              monthLabel.length > 1
                                  ? monthLabel[1]
                                  : monthLabel[0],
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                color: AppTheme.darkGrayText,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              color: AppTheme.darkGrayText,
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Providers line
                    LineChartBarData(
                      spots: _getSpots(provider.monthlyStats, 'providers'),
                      isCurved: true,
                      color: AppTheme.primaryDarkBlue,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.white,
                            strokeWidth: 2,
                            strokeColor: AppTheme.primaryDarkBlue,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryDarkBlue.withOpacity(0.08),
                      ),
                    ),
                    // Students line
                    LineChartBarData(
                      spots: _getSpots(provider.monthlyStats, 'students'),
                      isCurved: true,
                      color: AppTheme.yellowAccent,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.white,
                            strokeWidth: 2,
                            strokeColor: AppTheme.yellowAccent,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.yellowAccent.withOpacity(0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<FlSpot> _getSpots(List<MonthlyStatsModel> stats, String type) {
    final List<FlSpot> spots = [];
    for (int i = 0; i < stats.length; i++) {
      final value =
          type == 'providers' ? stats[i].providers.toDouble() : stats[i].students.toDouble();
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  Widget _buildPendingAccounts(DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'حسابات بانتظار الموافقة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryDarkBlue,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/accounts'),
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDarkBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (provider.isLoadingPending)
          const LoadingWidget(itemCount: 3)
        else if (provider.pendingAccounts.isEmpty)
          const EmptyState(
            icon: Icons.check_circle_outline,
            title: 'لا توجد حسابات معلقة',
            subtitle: 'جميع الحسابات تمت مراجعتها',
          )
        else
          ...provider.pendingAccounts
              .take(5)
              .map((user) => UserItem(
                    user: user,
                    onTap: () => context.push('/accounts/${user.id}'),
                  )),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: [
              _quickAction(
                context,
                icon: Icons.person_add,
                label: 'حسابات',
                color: AppTheme.blueInfo,
                onTap: () => context.go('/accounts'),
              ),
              _quickAction(
                context,
                icon: Icons.school,
                label: 'كورسات',
                color: AppTheme.greenSuccess,
                onTap: () => context.go('/courses'),
              ),
              _quickAction(
                context,
                icon: Icons.payment,
                label: 'مدفوعات',
                color: AppTheme.orange,
                onTap: () => context.go('/payments'),
              ),
              _quickAction(
                context,
                icon: Icons.notifications_active,
                label: 'إشعارات',
                color: AppTheme.redDanger,
                onTap: () => context.push('/notifications/send'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryDarkBlue,
            ),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppTheme.darkGrayText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.redDanger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
    );

    if (confirmed == true && mounted) {
      Provider.of<AuthProvider>(context, listen: false).logout();
      context.go('/login');
    }
  }
}
