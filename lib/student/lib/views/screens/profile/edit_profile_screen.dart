import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/custom_app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  String _gender = 'ذكر';
  File? _newAvatar;
  String? _avatarUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _gender = user?.gender ?? 'ذكر';
    _avatarUrl = user?.avatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 80);

      if (pickedFile != null) {
        setState(() {
          _newAvatar = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في اختيار الصورة'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? avatarPath = _avatarUrl;

      if (_newAvatar != null) {
        final userId = context.read<AuthProvider>().user?.id;
        if (userId != null) {
          avatarPath = await StorageService.uploadAvatar(_newAvatar!, userId);
        }
      }

      final success = await context.read<AuthProvider>().updateProfile(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
            bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
            gender: _gender,
            avatar: avatarPath,
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(Constants.profileUpdateSuccess),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.read<AuthProvider>().error ?? Constants.generalError),
              backgroundColor: AppTheme.dangerRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في تحديث الملف الشخصي'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: const CustomAppBar(title: 'تعديل الملف الشخصي', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.lightGrey,
                          image: _newAvatar != null
                              ? DecorationImage(image: FileImage(_newAvatar!), fit: BoxFit.cover)
                              : _avatarUrl != null
                                  ? DecorationImage(
                                      image: CachedNetworkImageProvider(_avatarUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: _newAvatar == null && _avatarUrl == null
                            ? Center(
                                child: Text(
                                  context.read<AuthProvider>().user?.initials ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: AppTheme.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.darkText),
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return Constants.requiredField;
                  if (value.trim().length < 3) return Constants.nameTooShort;
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.darkText),
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return Constants.requiredField;
                  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!regex.hasMatch(value)) return Constants.invalidEmail;
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.darkText),
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف (اختياري)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.lightGrey),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wc_outlined, color: AppTheme.greyText),
                    const SizedBox(width: 10),
                    const Text('الجنس', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppTheme.greyText)),
                    const Spacer(),
                    Radio<String>(
                      value: 'ذكر',
                      groupValue: _gender,
                      onChanged: (val) => setState(() => _gender = val!),
                      activeColor: AppTheme.primaryBlue,
                    ),
                    const Text('ذكر', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.darkText)),
                    Radio<String>(
                      value: 'أنثى',
                      groupValue: _gender,
                      onChanged: (val) => setState(() => _gender = val!),
                      activeColor: AppTheme.primaryBlue,
                    ),
                    const Text('أنثى', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.darkText)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _bioController,
                textDirection: TextDirection.rtl,
                maxLines: 3,
                style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.darkText),
                decoration: const InputDecoration(
                  labelText: 'نبذة عنك (اختياري)',
                  prefixIcon: Icon(Icons.info_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2)
                      : const Text('حفظ التغييرات'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
