import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';
import '../services/supabase_service.dart';

class PaymentsProvider with ChangeNotifier {
  final SupabaseService _supabaseService;

  PaymentsProvider(this._supabaseService);

  List<PaymentModel> _payments = [];
  List<PaymentModel> _filteredPayments = [];
  PaymentModel? _selectedPayment;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String _currentFilter = '';
  String _searchQuery = '';

  List<PaymentModel> get payments => _filteredPayments;
  PaymentModel? get selectedPayment => _selectedPayment;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;

  Future<void> loadPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _payments = await _supabaseService.getAllPayments(
        status: _currentFilter.isEmpty ? null : _currentFilter,
      );
      _applyFilter();
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحميل المدفوعات';
      _payments = [];
      _filteredPayments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    loadPayments();
  }

  void searchPayments(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredPayments = List.from(_payments);
    } else {
      _filteredPayments = _payments
          .where((p) =>
              (p.userName ?? '')
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (p.courseTitle ?? '')
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<PaymentModel> getPaymentDetail(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedPayment = await _supabaseService.getPaymentById(id);
      notifyListeners();
      return _selectedPayment!;
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحميل بيانات الدفعة';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approvePayment(String id) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _supabaseService.approvePayment(id);

      final index = _payments.indexWhere((p) => p.id == id);
      if (index != -1) {
        _payments[index] = updated;
      }
      final filteredIndex = _filteredPayments.indexWhere((p) => p.id == id);
      if (filteredIndex != -1) {
        if (_currentFilter.isEmpty || _currentFilter == 'APPROVED') {
          _filteredPayments[filteredIndex] = updated;
        } else {
          _filteredPayments.removeAt(filteredIndex);
        }
      }

      if (_selectedPayment?.id == id) {
        _selectedPayment = updated;
      }

      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في قبول الدفعة';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectPayment(String id, String? reason) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _supabaseService.rejectPayment(id, reason);

      final index = _payments.indexWhere((p) => p.id == id);
      if (index != -1) {
        _payments[index] = updated;
      }
      final filteredIndex = _filteredPayments.indexWhere((p) => p.id == id);
      if (filteredIndex != -1) {
        if (_currentFilter.isEmpty || _currentFilter == 'REJECTED') {
          _filteredPayments[filteredIndex] = updated;
        } else {
          _filteredPayments.removeAt(filteredIndex);
        }
      }

      if (_selectedPayment?.id == id) {
        _selectedPayment = updated;
      }

      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في رفض الدفعة';
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
