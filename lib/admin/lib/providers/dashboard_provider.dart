import 'package:flutter/foundation.dart';
import '../models/stats_model.dart';
import '../models/monthly_stats_model.dart';
import '../models/user_model.dart';
import 'package:wasla_provider/shared/services/flask_api_service.dart';

class DashboardProvider with ChangeNotifier {
  final FlaskApiService _apiService;

  DashboardProvider(this._apiService);

  StatsModel _stats = StatsModel.empty();
  List<MonthlyStatsModel> _monthlyStats = [];
  List<UserModel> _pendingAccounts = [];
  bool _isLoading = false;
  bool _isLoadingMonthly = false;
  bool _isLoadingPending = false;
  String? _errorMessage;

  StatsModel get stats => _stats;
  List<MonthlyStatsModel> get monthlyStats => _monthlyStats;
  List<UserModel> get pendingAccounts => _pendingAccounts;
  bool get isLoading => _isLoading;
  bool get isLoadingMonthly => _isLoadingMonthly;
  bool get isLoadingPending => _isLoadingPending;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        loadStats(),
        loadMonthlyStats(),
        loadPendingAccounts(),
      ]);
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحميل البيانات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStats() async {
    try {
      _stats = await _apiService.getStats();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحميل الإحصائيات';
    }
  }

  Future<void> loadMonthlyStats() async {
    _isLoadingMonthly = true;
    notifyListeners();

    try {
      _monthlyStats = await _apiService.getMonthlyStats();
      notifyListeners();
    } catch (e) {
      _monthlyStats = [];
    } finally {
      _isLoadingMonthly = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingAccounts() async {
    _isLoadingPending = true;
    notifyListeners();

    try {
      _pendingAccounts = await _apiService.getPendingAccounts();
      notifyListeners();
    } catch (e) {
      _pendingAccounts = [];
    } finally {
      _isLoadingPending = false;
      notifyListeners();
    }
  }

  void refresh() {
    loadDashboardData();
  }
}
