import 'package:flutter/material.dart';
import '../models/module_model.dart';
import '../services/supabase_service.dart';

class ModuleProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<ModuleModel> _modules = [];
  bool _isLoading = false;
  String? _error;

  List<ModuleModel> get modules => _modules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadModules(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _modules = await _supabaseService.getModulesByCourse(courseId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ModuleModel?> createModule({
    required String title,
    required String courseId,
    required int order,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final module = await _supabaseService.createModule(
        title: title,
        courseId: courseId,
        order: order,
      );
      _modules.add(module);
      _modules.sort((a, b) => a.order.compareTo(b.order));
      _isLoading = false;
      notifyListeners();
      return module;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateModule({
    required String moduleId,
    String? title,
    int? order,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedModule = await _supabaseService.updateModule(
        moduleId: moduleId,
        title: title,
        order: order,
      );

      final index = _modules.indexWhere((m) => m.id == moduleId);
      if (index != -1) {
        _modules[index] = updatedModule;
        _modules.sort((a, b) => a.order.compareTo(b.order));
      }
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

  Future<bool> deleteModule(String moduleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.deleteModule(moduleId);
      _modules.removeWhere((m) => m.id == moduleId);
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

  Future<bool> reorderModules() async {
    try {
      final moduleOrders = _modules
          .asMap()
          .entries
          .map((e) => {'id': e.value.id, 'order': e.key})
          .toList();

      await _supabaseService.reorderModules(moduleOrders);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
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
