import 'package:flutter/material.dart';
import '../models/certificate_model.dart';
import '../services/supabase_service.dart';

class CertificateProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<CertificateModel> _certificates = [];
  List<Map<String, dynamic>> _templates = [];
  bool _isLoading = false;
  String? _error;

  List<CertificateModel> get certificates => _certificates;
  List<Map<String, dynamic>> get templates => _templates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCertificatesByProvider(String providerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _certificates =
          await _supabaseService.getCertificatesByProvider(providerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCertificatesByCourse(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _certificates = await _supabaseService.getCertificatesByCourse(courseId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CertificateModel?> issueCertificate({
    required String studentName,
    required String courseName,
    required String providerName,
    required double score,
    required String studentId,
    required String courseId,
    required String providerId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cert = await _supabaseService.issueCertificate(
        studentName: studentName,
        courseName: courseName,
        providerName: providerName,
        score: score,
        studentId: studentId,
        courseId: courseId,
        providerId: providerId,
      );
      _certificates.insert(0, cert);
      _isLoading = false;
      notifyListeners();
      return cert;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadTemplates(String providerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _templates = await _supabaseService.getCertificateTemplates(providerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTemplate({
    required String name,
    required String backgroundColor,
    required String textColor,
    String? logoUrl,
    String? signatureUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.createCertificateTemplate(
        name: name,
        backgroundColor: backgroundColor,
        textColor: textColor,
        logoUrl: logoUrl,
        signatureUrl: signatureUrl,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTemplate(String templateId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.deleteCertificateTemplate(templateId);
      _templates.removeWhere((t) => t['id'] == templateId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
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
