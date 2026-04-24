import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/module_provider.dart';
import '../../../widgets/custom_app_bar.dart';

class AddEditModuleScreen extends StatefulWidget {
  final String courseId;
  final String? moduleId;

  const AddEditModuleScreen({super.key, required this.courseId, this.moduleId});

  @override
  State<AddEditModuleScreen> createState() => _AddEditModuleScreenState();
}

class _AddEditModuleScreenState extends State<AddEditModuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool _isSubmitting = false;

  bool get _isEditing => widget.moduleId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadModuleData();
    }
  }

  void _loadModuleData() {
    final provider = context.read<ModuleProvider>();
    final module = provider.modules.where((m) => m.id == widget.moduleId).firstOrNull;
    if (module != null) {
      _titleController.text = module.title;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final provider = context.read<ModuleProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updateModule(
        moduleId: widget.moduleId!,
        title: _titleController.text.trim(),
      );
    } else {
      final module = await provider.createModule(
        title: _titleController.text.trim(),
        courseId: widget.courseId,
        order: provider.modules.length,
      );
      success = module != null;
    }

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'تم تحديث الوحدة' : 'تم إنشاء الوحدة'),
          backgroundColor: AppTheme.greenSuccess,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'حدث خطأ'), backgroundColor: AppTheme.redDanger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(title: _isEditing ? 'تعديل الوحدة' : 'إضافة وحدة جديدة'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اسم الوحدة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الوحدة',
                    prefixIcon: Icon(Icons.view_module_outlined),
                    hintText: 'مثال: مقدمة في البرمجة',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'عنوان الوحدة مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDarkBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_isEditing ? 'حفظ التعديلات' : 'إضافة الوحدة', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
