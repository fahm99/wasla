import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/payment_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    await context.read<PaymentProvider>().loadPayments();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'معتمد':
        return AppTheme.greenSuccess;
      case 'مرفوض':
        return AppTheme.redDanger;
      default:
        return AppTheme.yellowAccent;
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'تحويل بنكي':
        return Icons.account_balance;
      case 'محفظة إلكترونية':
        return Icons.phone_android;
      default:
        return Icons.money;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'المدفوعات',
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () async {
                await context.push('/payments/upload');
                _loadPayments();
              },
            ),
          ],
        ),
        body: Consumer<PaymentProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'جاري تحميل المدفوعات...');
            }
            if (provider.payments.isEmpty) {
              return EmptyState(
                title: 'لا توجد مدفوعات',
                message: 'لم يتم تسجيل أي عملية دفع بعد',
                icon: Icons.receipt_long_outlined,
                buttonText: 'تسجيل دفعة جديدة',
                onButtonPressed: () async {
                  await context.push('/payments/upload');
                  _loadPayments();
                },
              );
            }
            return RefreshIndicator(
              color: AppTheme.primaryDarkBlue,
              onRefresh: _loadPayments,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.payments.length,
                itemBuilder: (context, index) {
                  final payment = provider.payments[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDarkBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_getMethodIcon(payment.paymentMethod), color: AppTheme.primaryDarkBlue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${payment.amount.toStringAsFixed(2)} ر.س',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(payment.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      payment.status,
                                      style: TextStyle(fontSize: 11, color: _getStatusColor(payment.status), fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(payment.paymentMethod, style: const TextStyle(fontSize: 13, color: AppTheme.darkGrayText)),
                              if (payment.createdAt != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${payment.createdAt!.day}/${payment.createdAt!.month}/${payment.createdAt!.year}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.darkGrayText),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
