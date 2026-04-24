import '../services/supabase_service.dart';

class ReportsController {
  final SupabaseService _supabaseService;

  ReportsController(this._supabaseService);

  Future<Map<String, dynamic>> getRevenueStats() async {
    return await _supabaseService.getRevenueStats();
  }

  Future<Map<String, dynamic>> getAccountStatusStats() async {
    return await _supabaseService.getAccountStatusStats();
  }

  Future<void> getMonthlyStats() async {
    await _supabaseService.getMonthlyStats();
  }

  void dispose() {}
}
