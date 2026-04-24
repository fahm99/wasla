import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_nav.dart';
import '../../../widgets/chart_widget.dart';
import '../../../widgets/loading_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _revenueStats = {};
  Map<String, dynamic> _accountStats = {};
  List<MapEntry<String, double>> _monthlyRevenue = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Provider.of<SupabaseService>(context, listen: false);
      _revenueStats = await supabase.getRevenueStats();
      _accountStats = await supabase.getAccountStatusStats();

      final monthlyRaw =
          _revenueStats['monthly_revenue'] as Map<String, dynamic>? ?? {};
      _monthlyRevenue = monthlyRaw.entries
          .map((e) => MapEntry(e.key, (e.value as num).toDouble()))
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key));
    } catch (e) {
      _revenueStats = {};
      _accountStats = {};
      _monthlyRevenue = [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrayBg,
      appBar: CustomAppBar(
        title: Constants.titleReports,
        showBack: false,
        backgroundColor: AppTheme.primaryDarkBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.primaryDarkBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Summary Cards
                    _buildSummaryCards(),
                    const SizedBox(height: 16),
                    // Revenue Bar Chart
                    _buildRevenueChart(),
                    const SizedBox(height: 16),
                    // Account Status Pie Chart
                    _buildAccountStatusChart(),
                    const SizedBox(height: 16),
                    // Monthly Revenue List
                    _buildMonthlyRevenueList(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
    );
  }

  Widget _buildSummaryCards() {
    final totalRevenue =
        (_revenueStats['total_revenue'] as num?)?.toDouble() ?? 0;
    final approvedRevenue =
        (_revenueStats['approved_revenue'] as num?)?.toDouble() ?? 0;
    final pendingRevenue =
        (_revenueStats['pending_revenue'] as num?)?.toDouble() ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص الإيرادات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'إجمالي الإيرادات',
                  '${totalRevenue.toStringAsFixed(0)} ر.س',
                  AppTheme.primaryDarkBlue,
                  Icons.attach_money,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  'إيرادات مقبولة',
                  '${approvedRevenue.toStringAsFixed(0)} ر.س',
                  AppTheme.greenSuccess,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  'إيرادات معلقة',
                  '${pendingRevenue.toStringAsFixed(0)} ر.س',
                  AppTheme.orange,
                  Icons.pending,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: AppTheme.darkGrayText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    if (_monthlyRevenue.isEmpty) {
      return const ChartWidget(
        title: 'الإيرادات الشهرية',
        child: SizedBox(
          height: 200,
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
        ),
      );
    }

    return ChartWidget(
      title: 'الإيرادات الشهرية',
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= _monthlyRevenue.length) {
                      return const SizedBox();
                    }
                    final parts = _monthlyRevenue[index].key.split('-');
                    final months = [
                      'يناير',
                      'فبراير',
                      'مارس',
                      'أبريل',
                      'مايو',
                      'يونيو',
                      'يوليو',
                      'أغسطس',
                      'سبتمبر',
                      'أكتوبر',
                      'نوفمبر',
                      'ديسمبر'
                    ];
                    final monthIndex =
                        parts.length >= 2 ? int.tryParse(parts[1]) ?? 1 : 1;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        months[monthIndex - 1].substring(0, 3),
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
                  reservedSize: 40,
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: _monthlyRevenue.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value,
                    color: AppTheme.primaryDarkBlue,
                    width: _monthlyRevenue.length > 8 ? 12 : 20,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: _monthlyRevenue.isNotEmpty
                          ? _monthlyRevenue
                                  .map((e) => e.value)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.2
                          : 100,
                      color: AppTheme.lightGrayBg,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountStatusChart() {
    final active = (_accountStats['active'] as int?) ?? 0;
    final pending = (_accountStats['pending'] as int?) ?? 0;
    final suspended = (_accountStats['suspended'] as int?) ?? 0;
    final rejected = (_accountStats['rejected'] as int?) ?? 0;
    final total = active + pending + suspended + rejected;

    if (total == 0) {
      return const ChartWidget(
        title: 'توزيع حالات الحسابات',
        child: SizedBox(
          height: 220,
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
        ),
      );
    }

    return ChartWidget(
      title: 'توزيع حالات الحسابات',
      child: SizedBox(
        height: 260,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: PieChart(
                PieChartData(
                  sections: [
                    if (active > 0)
                      PieChartSectionData(
                        value: active.toDouble(),
                        color: AppTheme.greenSuccess,
                        title: '${(active / total * 100).toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white,
                        ),
                        radius: 80,
                      ),
                    if (pending > 0)
                      PieChartSectionData(
                        value: pending.toDouble(),
                        color: AppTheme.orange,
                        title: '${(pending / total * 100).toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white,
                        ),
                        radius: 80,
                      ),
                    if (suspended > 0)
                      PieChartSectionData(
                        value: suspended.toDouble(),
                        color: AppTheme.redDanger,
                        title:
                            '${(suspended / total * 100).toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white,
                        ),
                        radius: 80,
                      ),
                    if (rejected > 0)
                      PieChartSectionData(
                        value: rejected.toDouble(),
                        color: AppTheme.darkGrayText,
                        title:
                            '${(rejected / total * 100).toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white,
                        ),
                        radius: 80,
                      ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Legend
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendItem(AppTheme.greenSuccess, 'نشط', active),
                  const SizedBox(height: 8),
                  _legendItem(AppTheme.orange, 'معلق', pending),
                  const SizedBox(height: 8),
                  _legendItem(AppTheme.redDanger, 'معلّق', suspended),
                  const SizedBox(height: 8),
                  _legendItem(AppTheme.darkGrayText, 'مرفوض', rejected),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label ($count)',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppTheme.darkGrayText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyRevenueList() {
    if (_monthlyRevenue.isEmpty) return const SizedBox();

    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تفاصيل الإيرادات الشهرية',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _monthlyRevenue.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = _monthlyRevenue[index];
                final parts = entry.key.split('-');
                final monthIndex =
                    parts.length >= 2 ? int.tryParse(parts[1]) ?? 1 : 1;
                final monthName = months[monthIndex - 1];
                final year = parts.isNotEmpty ? parts[0] : '';

                return ListTile(
                  title: Text(
                    '$monthName $year',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDarkBlue,
                    ),
                  ),
                  trailing: Text(
                    '${entry.value.toStringAsFixed(0)} ر.س',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryDarkBlue,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
