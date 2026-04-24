import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../../config/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/custom_app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _institutionNameController = TextEditingController();
  final _bankAccountController = TextEditingController();
  String? _institutionType;
  File? _avatarFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _institutionNameController.text = user.institutionName ?? '';
      _institutionType = user.institutionType;
      _bankAccountController.text = user.bankAccount ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _institutionNameController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80);
    if (picked != null) {
      setState(() => _avatarFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final authProvider = context.read<AuthProvider>();

    // Upload avatar if selected
    if (_avatarFile != null) {
      await authProvider.updateAvatar(_avatarFile!);
    }

    // Update profile
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      institutionType: _institutionType,
      institutionName: _institutionNameController.text.trim().isNotEmpty
          ? _institutionNameController.text.trim()
          : null,
      bankAccount: _bankAccountController.text.trim().isNotEmpty
          ? _bankAccountController.text.trim()
          : null,
    );

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تم تحديث الملف الشخصي بنجاح'),
            backgroundColor: AppTheme.greenSuccess),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(authProvider.error ?? 'حدث خطأ'),
            backgroundColor: AppTheme.redDanger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'تعديل الملف الشخصي'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            AppTheme.primaryDarkBlue.withOpacity(0.1),
                        backgroundImage: _avatarFile != null
                            ? FileImage(_avatarFile!) as ImageProvider
                            : (user?.avatar != null
                                ? NetworkImage(user!.avatar!) as ImageProvider
                                : null),
                        child: _avatarFile == null && user?.avatar == null
                            ? const Icon(Icons.person,
                                size: 50, color: AppTheme.primaryDarkBlue)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: AppTheme.primaryDarkBlue,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text('اضغط لتغيير الصورة',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.darkGrayText)),
                const SizedBox(height: 24),
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      prefixIcon: Icon(Icons.person_outline)),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'الاسم مطلوب'
                      : null,
                ),
                const SizedBox(height: 16),
                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 16),
                // Institution type
                DropdownButtonFormField2<String>(
                  value: _institutionType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: 'نوع المؤسسة',
                      prefixIcon: Icon(Icons.business_outlined)),
                  items: const [
                    DropdownMenuItem(value: 'جامعة', child: Text('جامعة')),
                    DropdownMenuItem(value: 'مدرسة', child: Text('مدرسة')),
                    DropdownMenuItem(value: 'معهد', child: Text('معهد')),
                    DropdownMenuItem(
                        value: 'مركز تدريب', child: Text('مركز تدريب')),
                    DropdownMenuItem(value: 'أخرى', child: Text('أخرى')),
                  ],
                  onChanged: (value) =>
                      setState(() => _institutionType = value),
                  dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 16),
                // Institution name
                TextFormField(
                  controller: _institutionNameController,
                  decoration: const InputDecoration(
                      labelText: 'اسم المؤسسة',
                      prefixIcon: Icon(Icons.account_balance_outlined)),
                ),
                const SizedBox(height: 16),
                // Bank account
                TextFormField(
                  controller: _bankAccountController,
                  decoration: const InputDecoration(
                      labelText: 'رقم الحساب البنكي (IBAN)',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined)),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('حفظ التعديلات',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
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
