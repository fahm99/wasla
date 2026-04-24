import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'تأكيد',
    this.cancelText = 'إلغاء',
    this.confirmColor = AppTheme.redDanger,
    this.icon = Icons.warning_amber_rounded,
    this.isLoading = false,
    this.onConfirm,
    this.onCancel,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    Color confirmColor = AppTheme.redDanger,
    IconData icon = Icons.warning_amber_rounded,
    bool isLoading = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
        isLoading: isLoading,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: confirmColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: confirmColor, size: 24),
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
            onPressed: isLoading ? null : onCancel,
            child: Text(
              cancelText,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGrayText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.white),
                    ),
                  )
                : Text(
                    confirmText,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
