import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/course_provider.dart';
import '../../../widgets/custom_app_bar.dart';

class AddEditCourseScreen extends StatefulWidget {
  final String? courseId;

  const AddEditCourseScreen({super.key, this.courseId});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  File? _imageFile;
  String _level = AppConstants.levelBeginner;
  String _category = AppConstants.categories.first;
  bool _isSubmitting = false;

  bool get _isEditing => widget.courseId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadCourseData();
    }
  }

  Future<void> _loadCourseData() async {
    final provider = context.read<CourseProvider>();
    if (provider.currentCourse == null) {
      await provider.loadCourseById(widget.courseId!);
    }
    if (!mounted) return;
    final course = provider.currentCourse;
    if (course != null) {
      _titleController.text = course.title;
      _descriptionController.text = course.description;
      _priceController.text = course.price > 0 ? course.price.toStringAsFixed(0) : '';
      _level = course.level;
      _category = course.category;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<CourseProvider>();

    bool success;
    if (_isEditing) {
      success = await provider.updateCourse(
        courseId: widget.courseId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _priceController.text.trim().isEmpty ? 0 : double.parse(_priceController.text.trim()),
        level: _level,
        category: _category,
        imageFile: _imageFile,
      );
    } else {
      final course = await provider.createCourse(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _priceController.text.trim().isEmpty ? 0 : double.parse(_priceController.text.trim()),
        level: _level,
        category: _category,
        imageFile: _imageFile,
      );
      success = course != null;
    }

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'تم تحديث الدورة بنجاح' : 'تم إنشاء الدورة بنجاح'),
          backgroundColor: AppTheme.greenSuccess,
        ),
      );
      context.go('/courses');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'حدث خطأ'),
          backgroundColor: AppTheme.redDanger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(title: _isEditing ? 'تعديل الدورة' : 'إنشاء دورة جديدة'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image picker
                const Text(
                  'صورة الدورة',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryDarkBlue),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrayBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.mediumGray),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                Image.file(_imageFile!, width: double.infinity, height: 200, fit: BoxFit.cover),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.redDanger,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppTheme.darkGrayText.withOpacity(0.4)),
                              const SizedBox(height: 8),
                              Text('اضغط لإضافة صورة', style: TextStyle(color: AppTheme.darkGrayText.withOpacity(0.6))),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الدورة',
                    prefixIcon: Icon(Icons.title_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'عنوان الدورة مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'وصف الدورة',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'وصف الدورة مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Price
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'السعر (ر.س)',
                    prefixIcon: Icon(Icons.attach_money),
                    hintText: '0 للدورات المجانية',
                    hintTextDirection: TextDirection.ltr,
                  ),
                ),
                const SizedBox(height: 16),
                // Level dropdown
                DropdownButtonFormField2<String>(
                  value: _level,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'مستوى الدورة',
                    prefixIcon: Icon(Icons.signal_cellular_alt),
                  ),
                  items: AppConstants.levels.map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _level = value);
                  },
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                // Category dropdown
                DropdownButtonFormField2<String>(
                  value: _category,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'تصنيف الدورة',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: AppConstants.categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 32),
                // Submit button
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
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _isEditing ? 'حفظ التعديلات' : 'إنشاء الدورة',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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
