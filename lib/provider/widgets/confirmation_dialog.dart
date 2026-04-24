import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDanger;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'تأكيد',
    this.cancelText = 'إلغاء',
    this.isDanger = false,
    this.onConfirm,
    this.onCancel,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDanger: isDanger,
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
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDanger
                    ? AppTheme.redDanger.withOpacity(0.1)
                    : AppTheme.primaryDarkBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isDanger ? Icons.warning_amber_rounded : Icons.info_outline,
                color: isDanger ? AppTheme.redDanger : AppTheme.primaryDarkBlue,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDanger ? AppTheme.redDanger : AppTheme.primaryDarkBlue,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.darkGrayText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: onCancel,
            child: Text(
              cancelText,
              style: const TextStyle(
                color: AppTheme.darkGrayText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDanger ? AppTheme.redDanger : AppTheme.primaryDarkBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
