import 'dart:io';
import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/supabase_service.dart';

class PaymentProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _error;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPayments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _payments = await _supabaseService.getPaymentsByProvider();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PaymentModel?> createPayment({
    required double amount,
    required String paymentMethod,
    File? proofFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? proofUrl;
      if (proofFile != null) {
        // Upload proof first
        // proofUrl will be set by uploadPaymentProof below
      }

      final payment = await _supabaseService.createPayment(
        amount: amount,
        paymentMethod: paymentMethod,
        proofUrl: proofUrl,
      );

      if (proofFile != null) {
        final updated = await _supabaseService.uploadPaymentProof(
          paymentId: payment.id,
          proofFile: proofFile,
        );
        _payments.insert(0, updated);
      } else {
        _payments.insert(0, payment);
      }

      _isLoading = false;
      notifyListeners();
      return payment;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }
}
