import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onSuspend;
  final bool showActions;

  const UserItem({
    super.key,
    required this.user,
    this.onTap,
    this.onApprove,
    this.onReject,
    this.onSuspend,
    this.showActions = false,
  });

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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.lightGrayBg,
                  backgroundImage: user.avatarUrl != null &&
                          user.avatarUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                      ? Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0]
                              : '?',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryDarkBlue,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDarkBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppTheme.darkGrayText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(user.status).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getStatusText(user.status),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(user.status),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.primaryDarkBlue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.roleText,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
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
                // Actions
                if (showActions && user.status == 'PENDING') ...[
                  Column(
                    children: [
                      InkWell(
                        onTap: onApprove,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.greenSuccess.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.check,
                              color: AppTheme.greenSuccess, size: 18),
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: onReject,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.redDanger.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close,
                              color: AppTheme.redDanger, size: 18),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const Icon(Icons.chevron_left,
                      color: AppTheme.darkGrayText),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
