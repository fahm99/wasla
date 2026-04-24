class MonthlyStatsModel {
  final String month;
  final int providers;
  final int students;
  final double revenue;

  MonthlyStatsModel({
    required this.month,
    required this.providers,
    required this.students,
    required this.revenue,
  });

  factory MonthlyStatsModel.fromJson(Map<String, dynamic> json) {
    return MonthlyStatsModel(
      month: json['month']?.toString() ?? '',
      providers: (json['providers'] as num?)?.toInt() ?? 0,
      students: (json['students'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get formattedMonth {
    if (month.isEmpty) return '';
    try {
      final parts = month.split('-');
      if (parts.length >= 2) {
        final months = [
          'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
          'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
        ];
        final monthIndex = int.tryParse(parts[1]) ?? 1;
        return '${months[monthIndex - 1]} ${parts[0]}';
      }
    } catch (_) {}
    return month;
  }
}
