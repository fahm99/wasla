import 'package:flutter/material.dart';
import '../providers/dashboard_provider.dart';

class DashboardController {
  final DashboardProvider provider;

  DashboardController(this.provider);

  Future<void> initialize() async {
    await provider.loadDashboardData();
  }

  Future<void> refresh() async {
    await provider.loadDashboardData();
  }

  void dispose() {}

  // Formatted stats for display
  String formatRevenue(double revenue) {
    return '${revenue.toStringAsFixed(0)} ر.س';
  }

  String formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  // Quick action handling
  void navigateToAccounts(BuildContext context) {
    Navigator.of(context).pushNamed('/accounts');
  }

  void navigateToPendingAccounts(BuildContext context) {
    Navigator.of(context).pushNamed('/accounts');
  }

  void navigateToPayments(BuildContext context) {
    Navigator.of(context).pushNamed('/payments');
  }
}
