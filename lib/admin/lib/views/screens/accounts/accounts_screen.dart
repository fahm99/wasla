import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/accounts_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_nav.dart';
import '../../../widgets/user_item.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/tab_bar_widget.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final _searchController = TextEditingController();
  int _selectedTab = 0;
  final List<String> _tabs = [
    Constants.tabPending,
    Constants.tabActive,
    Constants.tabSuspended,
  ];

  String _getFilterFromTab(int index) {
    switch (index) {
      case 0:
        return 'PENDING';
      case 1:
        return 'ACTIVE';
      case 2:
        return 'SUSPENDED';
      default:
        return 'PENDING';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountsProvider>(context, listen: false)
          .loadAccounts();
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

  Future<void> _handleApprove(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildConfirmDialog(
        title: 'قبول الحساب',
        message: 'هل أنت متأكد من قبول حساب "$userName"؟',
        confirmText: Constants.actionApprove,
        confirmColor: AppTheme.greenSuccess,
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<AccountsProvider>(context, listen: false);
      final success = await provider.updateAccountStatus(userId, 'ACTIVE');
      if (success) {
        _showSuccess('تم قبول حساب $userName بنجاح');
      } else {
        _showError(provider.errorMessage ?? Constants.msgError);
      }
    }
  }

  Future<void> _handleReject(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildConfirmDialog(
        title: 'رفض الحساب',
        message: 'هل أنت متأكد من رفض حساب "$userName"؟ لا يمكن التراجع عن هذا الإجراء.',
        confirmText: Constants.actionReject,
        confirmColor: AppTheme.redDanger,
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<AccountsProvider>(context, listen: false);
      final success = await provider.updateAccountStatus(userId, 'REJECTED');
      if (success) {
        _showSuccess('تم رفض حساب $userName');
      } else {
        _showError(provider.errorMessage ?? Constants.msgError);
      }
    }
  }

  Widget _buildConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: confirmColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.warning_amber_rounded,
                  color: confirmColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryDarkBlue,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: AppTheme.darkGrayText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              Constants.actionCancel,
              style: TextStyle(fontFamily: 'Cairo', color: AppTheme.darkGrayText),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightGrayBg,
        appBar: const CustomAppBar(
          title: Constants.titleAccounts,
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
                  Provider.of<AccountsProvider>(context, listen: false)
                      .searchAccounts(query);
                },
                decoration: InputDecoration(
                  hintText: Constants.hintSearch,
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
                Provider.of<AccountsProvider>(context, listen: false)
                    .setFilter(_getFilterFromTab(index));
              },
            ),
            // Accounts List
            Expanded(
              child: Consumer<AccountsProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const LoadingWidget(itemCount: 5);
                  }

                  if (provider.accounts.isEmpty) {
                    return EmptyState(
                      icon: Icons.people_outline,
                      title: Constants.msgNoData,
                      subtitle: 'لا توجد حسابات في هذا التصنيف',
                      onAction: () => provider.loadAccounts(),
                      actionText: Constants.actionRefresh,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadAccounts(),
                    color: AppTheme.primaryDarkBlue,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: provider.accounts.length,
                      itemBuilder: (context, index) {
                        final user = provider.accounts[index];
                        return UserItem(
                          user: user,
                          showActions: user.status == 'PENDING',
                          onTap: () =>
                              context.push('/accounts/${user.id}'),
                          onApprove: () => _handleApprove(user.id, user.fullName),
                          onReject: () => _handleReject(user.id, user.fullName),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
      ),
    );
  }
}
