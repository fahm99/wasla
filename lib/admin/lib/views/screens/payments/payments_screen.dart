import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../models/payment_model.dart';
import '../../../providers/payments_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_nav.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/tab_bar_widget.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _searchController = TextEditingController();
  int _selectedTab = 0;
  final List<String> _tabs = [
    Constants.tabAll,
    'معلقة',
    Constants.tabApproved,
    Constants.tabRejectedPayment,
  ];

  String _getFilterFromTab(int index) {
    switch (index) {
      case 0:
        return '';
      case 1:
        return 'PENDING';
      case 2:
        return 'APPROVED';
      case 3:
        return 'REJECTED';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentsProvider>(context, listen: false).loadPayments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrayBg,
      appBar: const CustomAppBar(
        title: Constants.titlePayments,
        showBack: false,
        backgroundColor: AppTheme.primaryDarkBlue,
      ),
        body: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  Provider.of<PaymentsProvider>(context, listen: false)
                      .searchPayments(query);
                },
                decoration: InputDecoration(
                  hintText: 'بحث عن دفعة...',
                  prefixIcon: const Icon(Icons.search,
                      color: AppTheme.darkGrayText),
                  filled: true,
                  fillColor: AppTheme.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTheme.primaryDarkBlue, width: 1.5),
                  ),
                ),
              ),
            ),
            // Tab Bar
            TabBarWidget(
              tabs: _tabs,
              selectedIndex: _selectedTab,
              onTabChanged: (index) {
                setState(() => _selectedTab = index);
                Provider.of<PaymentsProvider>(context, listen: false)
                    .setFilter(_getFilterFromTab(index));
              },
            ),
            // Payments List
            Expanded(
              child: Consumer<PaymentsProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const LoadingWidget(itemCount: 5);
                  }

                  if (provider.payments.isEmpty) {
                    return EmptyState(
                      icon: Icons.payment_outlined,
                      title: Constants.msgNoData,
                      subtitle: 'لا توجد مدفوعات في هذا التصنيف',
                      onAction: () => provider.loadPayments(),
                      actionText: Constants.actionRefresh,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadPayments(),
                    color: AppTheme.primaryDarkBlue,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: provider.payments.length,
                      itemBuilder: (context, index) {
                        final payment = provider.payments[index];
                        return _buildPaymentCard(context, payment);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
      
    );
  }

  Widget _buildPaymentCard(BuildContext context, PaymentModel payment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.push('/payments/${payment.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    // Amount circle
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getPaymentStatusColor(payment.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.attach_money,
                          color: _getPaymentStatusColor(payment.status),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                payment.userName ?? 'مستخدم',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryDarkBlue,
                                ),
                              ),
                              Text(
                                '${payment.amount} ر.س',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryDarkBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (payment.courseTitle != null) ...[
                                const Icon(Icons.school,
                                    size: 14, color: AppTheme.darkGrayText),
                                const SizedBox(width: 4),
                                Text(
                                  payment.courseTitle!,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: AppTheme.darkGrayText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: Text(
                                  payment.createdAt != null
                                      ? DateFormat('yyyy/MM/dd')
                                          .format(payment.createdAt!)
                                      : '',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: AppTheme.darkGrayText,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            _getPaymentStatusColor(payment.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        payment.statusText,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getPaymentStatusColor(payment.status),
                        ),
                      ),
                    ),
                    Text(
                      payment.paymentMethodText,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppTheme.darkGrayText,
                      ),
                    ),
                    const Icon(Icons.chevron_left,
                        color: AppTheme.darkGrayText, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      
    );
  }

  Color _getPaymentStatusColor(String status) {
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
}
