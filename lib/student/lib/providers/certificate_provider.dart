import 'package:flutter/foundation.dart';
import '../models/certificate_model.dart';
import '../services/supabase_service.dart';

class CertificateProvider with ChangeNotifier {
  List<CertificateModel> _certificates = [];
  CertificateModel? _currentCertificate;
  bool _isLoading = false;
  String? _error;

  List<CertificateModel> get certificates => _certificates;
  CertificateModel? get currentCertificate => _currentCertificate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyCertificates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _certificates = await SupabaseService.getMyCertificates();
      _error = null;
    } catch (e) {
      _error = 'خطأ في تحميل الشهادات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCertificateById(String certificateId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentCertificate = await SupabaseService.getCertificateById(certificateId);
      _error = null;
    } catch (e) {
      _error = 'خطأ في تحميل الشهادة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
