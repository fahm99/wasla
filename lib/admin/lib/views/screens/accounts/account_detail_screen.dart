import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../models/user_model.dart';
import '../../../providers/accounts_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/confirmation_dialog.dart';

class AccountDetailScreen extends StatefulWidget {
  final String userId;

  const AccountDetailScreen({super.key, required this.userId});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  bool _isActionLoading = false;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return AppTheme.greenSuccess;
      case 'PENDING':
        return AppTheme.orange;
      case 'SUSPENDED':
        return AppTheme.redDanger;
      case 'REJECTED':
        return AppTheme.redDanger;
      default:
        return AppTheme.darkGrayText;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'نشط';
      case 'PENDING':
        return 'معلق';
      case 'SUSPENDED':
        return 'معلّق';
      case 'REJECTED':
        return 'مرفوض';
      default:
        return status;
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppTheme.greenSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppTheme.redDanger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _updateStatus(String status, String actionName) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: '$actionName الحساب',
      message: 'هل أنت متأكد من $actionName هذا الحساب؟',
      confirmText: actionName,
      confirmColor: status == 'ACTIVE'
          ? AppTheme.greenSuccess
          : status == 'REJECTED'
              ? AppTheme.redDanger
              : AppTheme.orange,
    );

    if (confirmed == true) {
      setState(() => _isActionLoading = true);
      final provider =
          Provider.of<AccountsProvider>(context, listen: false);
      final success =
          await provider.updateAccountStatus(widget.userId, status);
      setState(() => _isActionLoading = false);

      if (success) {
        _showSuccess('تم $actionName الحساب بنجاح');
      } else {
        _showError(provider.errorMessage ?? Constants.msgError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrayBg,
      appBar: const CustomAppBar(
        title: 'تفاصيل الحساب',
        showBack: true,
        backgroundColor: AppTheme.primaryDarkBlue,
      ),
        body: FutureBuilder<UserModel>(
          future: Provider.of<AccountsProvider>(context, listen: false)
              .getAccountDetail(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'حدث خطأ في تحميل البيانات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppTheme.redDanger,
                  ),
                ),
              );
            }

            final user = snapshot.data!;
            final statusColor = _getStatusColor(user.status);
            final statusText = _getStatusText(user.status);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.lightGrayBg,
                            backgroundImage:
                                user.avatarUrl != null &&
                                        user.avatarUrl!.isNotEmpty
                                    ? CachedNetworkImageProvider(user.avatarUrl!)
                                    : null,
                            child: user.avatarUrl == null ||
                                    user.avatarUrl!.isEmpty
                                ? Text(
                                    user.fullName.isNotEmpty
                                        ? user.fullName[0]
                                        : '?',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryDarkBlue,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryDarkBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: AppTheme.darkGrayText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      statusText,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.primaryDarkBlue.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.roleText,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryDarkBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Info Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معلومات الحساب',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryDarkBlue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _infoRow('الاسم الكامل', user.fullName),
                          _infoRow('البريد الإلكتروني', user.email),
                          if (user.phone != null)
                            _infoRow('رقم الهاتف', user.phone!),
                          if (user.specialization != null)
                            _infoRow('التخصص', user.specialization!),
                          if (user.qualification != null)
                            _infoRow('المؤهل', user.qualification!),
                          if (user.bio != null && user.bio!.isNotEmpty)
                            _infoRow('نبذة', user.bio!),
                          if (user.nationalId != null)
                            _infoRow('رقم الهوية', user.nationalId!),
                          if (user.createdAt != null)
                            _infoRow(
                                'تاريخ التسجيل',
                                DateFormat('yyyy/MM/dd - HH:mm')
                                    .format(user.createdAt!)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons
                  if (user.status == 'PENDING') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isActionLoading
                            ? null
                            : () => _updateStatus('ACTIVE', 'قبول'),
                        icon: const Icon(Icons.check_circle),
                        label: const Text(
                          'قبول الحساب',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.greenSuccess,
                          foregroundColor: AppTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isActionLoading
                            ? null
                            : () => _updateStatus('REJECTED', 'رفض'),
                        icon: const Icon(Icons.cancel),
                        label: const Text(
                          'رفض الحساب',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.redDanger,
                          foregroundColor: AppTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ] else if (user.status == 'ACTIVE') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isActionLoading
                            ? null
                            : () => _updateStatus('SUSPENDED', 'تعليق'),
                        icon: const Icon(Icons.block),
                        label: const Text(
                          'تعليق الحساب',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.orange,
                          foregroundColor: AppTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ] else if (user.status == 'SUSPENDED') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isActionLoading
                            ? null
                            : () => _updateStatus('ACTIVE', 'تفعيل'),
                        icon: const Icon(Icons.check_circle),
                        label: const Text(
                          'تفعيل الحساب',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.greenSuccess,
                          foregroundColor: AppTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: AppTheme.darkGrayText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppTheme.primaryDarkBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}
