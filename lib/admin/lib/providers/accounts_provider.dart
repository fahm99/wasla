import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AccountsProvider with ChangeNotifier {
  final SupabaseService _supabaseService;

  AccountsProvider(this._supabaseService);

  List<UserModel> _accounts = [];
  List<UserModel> _filteredAccounts = [];
  UserModel? _selectedAccount;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String _currentFilter = 'PENDING';
  String _searchQuery = '';

  List<UserModel> get accounts => _filteredAccounts;
  UserModel? get selectedAccount => _selectedAccount;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;

  Future<void> loadAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final role = _currentFilter == 'PENDING' ? null : 'PROVIDER';
      final status = _currentFilter == 'PENDING' ? 'PENDING' : _currentFilter;

      _accounts = await _supabaseService.getAllAccounts(
        role: role,
        status: status,
      );
      _applyFilter();
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحميل الحسابات';
      _accounts = [];
      _filteredAccounts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    loadAccounts();
  }

  void searchAccounts(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredAccounts = List.from(_accounts);
    } else {
      _filteredAccounts = _accounts
          .where((a) =>
              a.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              a.email.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<UserModel> getAccountDetail(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedAccount = await _supabaseService.getAccountById(id);
      notifyListeners();
      return _selectedAccount!;
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحميل بيانات الحساب';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAccountStatus(String id, String status) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _supabaseService.updateAccountStatus(id, status);

      final index = _accounts.indexWhere((a) => a.id == id);
      if (index != -1) {
        _accounts[index] = updated;
      }
      final filteredIndex = _filteredAccounts.indexWhere((a) => a.id == id);
      if (filteredIndex != -1) {
        if (status == _currentFilter ||
            _currentFilter == 'PENDING' && status == 'PENDING') {
          _filteredAccounts[filteredIndex] = updated;
        } else {
          _filteredAccounts.removeAt(filteredIndex);
        }
      }

      if (_selectedAccount?.id == id) {
        _selectedAccount = updated;
      }

      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحديث حالة الحساب';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
