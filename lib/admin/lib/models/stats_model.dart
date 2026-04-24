class StatsModel {
  final int activeProviders;
  final int pendingAccounts;
  final int suspendedAccounts;
  final int totalStudents;
  final int totalCourses;
  final double totalRevenue;
  final int totalPayments;
  final int totalNotifications;

  StatsModel({
    required this.activeProviders,
    required this.pendingAccounts,
    required this.suspendedAccounts,
    required this.totalStudents,
    required this.totalCourses,
    required this.totalRevenue,
    required this.totalPayments,
    required this.totalNotifications,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      activeProviders: (json['active_providers'] as num?)?.toInt() ?? 0,
      pendingAccounts: (json['pending_accounts'] as num?)?.toInt() ?? 0,
      suspendedAccounts: (json['suspended_accounts'] as num?)?.toInt() ?? 0,
      totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
      totalCourses: (json['total_courses'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalPayments: (json['total_payments'] as num?)?.toInt() ?? 0,
      totalNotifications: (json['total_notifications'] as num?)?.toInt() ?? 0,
    );
  }

  factory StatsModel.empty() {
    return StatsModel(
      activeProviders: 0,
      pendingAccounts: 0,
      suspendedAccounts: 0,
      totalStudents: 0,
      totalCourses: 0,
      totalRevenue: 0.0,
      totalPayments: 0,
      totalNotifications: 0,
    );
  }
}
