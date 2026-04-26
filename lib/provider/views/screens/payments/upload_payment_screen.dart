import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/payment_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/upload_widget.dart';

class UploadPaymentScreen extends StatefulWidget {
  const UploadPaymentScreen({super.key});

  @override
  State<UploadPaymentScreen> createState() => _UploadPaymentScreenState();
}

class _UploadPaymentScreenState extends State<UploadPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String _paymentMethod = AppConstants.paymentMethodBank;
  File? _proofFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_proofFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى رفع إثبات الدفع'),
          backgroundColor: AppTheme.redDanger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<PaymentProvider>();
      final result = await provider.createPayment(
        amount: double.parse(_amountController.text.trim()),
        paymentMethod: _paymentMethod,
        proofFile: _proofFile,
      );

      setState(() => _isSubmitting = false);
      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الدفعة بنجاح وسيتم مراجعتها'),
            backgroundColor: AppTheme.greenSuccess,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'حدث خطأ أثناء تسجيل الدفعة'),
            backgroundColor: AppTheme.redDanger,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ، يرجى المحاولة مرة أخرى'),
            backgroundColor: AppTheme.redDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'تسجيل دفعة جديدة'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.blueInfo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppTheme.blueInfo.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.blueInfo),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'يرجى رفع إثبات التحويل (صورة الإيصال) وسيتم مراجعة الدفعة خلال 24 ساعة',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.darkGrayText),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'المبلغ (ر.س)',
                    prefixIcon: Icon(Icons.attach_money),
                    hintText: '0.00',
                    hintTextDirection: TextDirection.ltr,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'المبلغ مطلوب';
                    }
                    final amount = double.tryParse(value.trim());
                    if (amount == null || amount <= 0) {
                      return 'القيمة غير صحيحة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Payment method
                DropdownButtonFormField2<String>(
                  value: _paymentMethod,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'طريقة الدفع',
                    prefixIcon: Icon(Icons.payment_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: AppConstants.paymentMethodBank,
                        child: Text('تحويل بنكي')),
                    DropdownMenuItem(
                        value: AppConstants.paymentMethodWallet,
                        child: Text('محفظة إلكترونية')),
                    DropdownMenuItem(
                        value: AppConstants.paymentMethodCash,
                        child: Text('نقدي')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _paymentMethod = value);
                  },
                  dropdownStyleData: DropdownStyleData(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                // Proof upload
                UploadWidget(
                  label: 'إثبات الدفع (صورة الإيصال)',
                  onFileSelected: (file, name, size) {
                    setState(() => _proofFile = file);
                  },
                  onFileRemoved: () {
                    setState(() => _proofFile = null);
                  },
                  isLoading: _isSubmitting,
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
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('جاري التسجيل...',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )
                        : const Text('تسجيل الدفعة',
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
