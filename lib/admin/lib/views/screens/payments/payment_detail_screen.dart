import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/payments_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/confirmation_dialog.dart';

class PaymentDetailScreen extends StatefulWidget {
  final String paymentId;

  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  bool _isActionLoading = false;

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

  Future<void> _approve() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'قبول الدفعة',
      message: 'هل أنت متأكد من قبول هذه الدفعة؟',
      confirmText: Constants.actionApprove,
      confirmColor: AppTheme.greenSuccess,
      icon: Icons.check_circle,
    );

    if (confirmed == true) {
      setState(() => _isActionLoading = true);
      final provider =
          Provider.of<PaymentsProvider>(context, listen: false);
      final success = await provider.approvePayment(widget.paymentId);
      setState(() => _isActionLoading = false);

      if (success) {
        _showSuccess(Constants.msgApproveSuccess);
      } else {
        _showError(provider.errorMessage ?? Constants.msgError);
      }
    }
  }

  Future<void> _reject() async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'رفض الدفعة',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryDarkBlue,
          ),
        ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'يرجى إدخال سبب الرفض (اختياري)',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppTheme.darkGrayText,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'سبب الرفض...',
                  hintStyle: const TextStyle(fontFamily: 'Cairo'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                Constants.actionCancel,
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, reasonController.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.redDanger,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                Constants.actionReject,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppTheme.white,
                ),
              ),
            ),
          ],
        ),
      
    );
    reasonController.dispose();

    if (reason != null) {
      setState(() => _isActionLoading = true);
      final provider =
          Provider.of<PaymentsProvider>(context, listen: false);
      final success =
          await provider.rejectPayment(widget.paymentId, reason.isEmpty ? null : reason);
      setState(() => _isActionLoading = false);

      if (success) {
        _showSuccess(Constants.msgRejectSuccess);
      } else {
        _showError(provider.errorMessage ?? Constants.msgError);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return AppTheme.greenSuccess;
      case 'PENDING':
        return AppTheme.orange;
      case 'REJECTED':
        return AppTheme.redDanger;
      default:
        return AppTheme.darkGrayText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrayBg,
      appBar: CustomAppBar(
        title: 'تفاصيل الدفعة',
        showBack: true,
        backgroundColor: AppTheme.primaryDarkBlue,
      ),
        body: FutureBuilder(
          future: Provider.of<PaymentsProvider>(context, listen: false)
              .getPaymentDetail(widget.paymentId),
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

            final payment = snapshot.data!;
            final statusColor = _getStatusColor(payment.status);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Amount Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryDarkBlue,
                            AppTheme.primaryDarkBlue.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'المبلغ',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${payment.amount} ر.س',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.yellowAccent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              payment.statusText,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Payment Info
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
                            'معلومات الدفعة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryDarkBlue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _infoRow('المستخدم', payment.userName ?? 'غير محدد'),
                          _infoRow('طريقة الدفع', payment.paymentMethodText),
                          if (payment.courseTitle != null)
                            _infoRow('الكورس', payment.courseTitle!),
                          _infoRow(
                              'تاريخ الطلب',
                              payment.createdAt != null
                                  ? DateFormat('yyyy/MM/dd - HH:mm')
                                      .format(payment.createdAt!)
                                  : '-'),
                          if (payment.processedAt != null)
                            _infoRow(
                                'تاريخ المعالجة',
                                DateFormat('yyyy/MM/dd - HH:mm')
                                    .format(payment.processedAt!)),
                          if (payment.notes != null &&
                              payment.notes!.isNotEmpty)
                            _infoRow('ملاحظات', payment.notes!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Proof Image
                  if (payment.proofUrl != null &&
                      payment.proofUrl!.isNotEmpty) ...[
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
                              'إثبات الدفع',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryDarkBlue,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: payment.proofUrl!,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                placeholder: (_, __) => Container(
                                  height: 200,
                                  color: AppTheme.lightGrayBg,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                          AppTheme.primaryDarkBlue),
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  height: 200,
                                  color: AppTheme.lightGrayBg,
                                  child: const Icon(Icons.broken_image,
                                      size: 48, color: AppTheme.darkGrayText),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Action Buttons
                  if (payment.status == 'PENDING') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isActionLoading ? null : _approve,
                        icon: const Icon(Icons.check_circle),
                        label: const Text(
                          'قبول الدفعة',
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
                        onPressed:
                            _isActionLoading ? null : _reject,
                        icon: const Icon(Icons.cancel),
                        label: const Text(
                          'رفض الدفعة',
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppTheme.darkGrayText,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryDarkBlue,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
