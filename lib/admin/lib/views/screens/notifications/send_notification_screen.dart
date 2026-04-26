import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/notifications_provider.dart';
import '../../../widgets/custom_app_bar.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _targetType = 'ALL';
  bool _isSending = false;

  final List<Map<String, String>> _targetOptions = [
    {'value': 'ALL', 'label': Constants.targetAll},
    {'value': 'PROVIDER', 'label': Constants.targetAllProviders},
    {'value': 'STUDENT', 'label': Constants.targetAllStudents},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final provider = Provider.of<NotificationsProvider>(context, listen: false);
    final success = await provider.sendNotification(
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      targetType: _targetType,
      targetRoles: _targetType == 'ALL' ? null : _targetType,
    );

    setState(() => _isSending = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            Constants.msgSendSuccess,
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppTheme.greenSuccess,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _titleController.clear();
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? Constants.msgError,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppTheme.redDanger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightGrayBg,
        appBar: const CustomAppBar(
          title: Constants.titleSendNotification,
          showBack: true,
          backgroundColor: AppTheme.primaryDarkBlue,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Title
                const Text(
                  Constants.hintNotificationTitle,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'أدخل عنوان الإشعار',
                    prefixIcon: Icon(Icons.title,
                        color: AppTheme.darkGrayText),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال عنوان الإشعار';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Message
                const Text(
                  Constants.hintNotificationMessage,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'أدخل نص الإشعار',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 60),
                      child: Icon(Icons.message,
                          color: AppTheme.darkGrayText),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال نص الإشعار';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Target Audience
                const Text(
                  'الفئة المستهدفة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.mediumGray),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _targetType,
                      isExpanded: true,
                      dropdownColor: AppTheme.white,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: AppTheme.primaryDarkBlue,
                      ),
                      items: _targetOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option['value'],
                          child: Text(option['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _targetType = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سيتم إرسال الإشعار إلى $_targetType',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: AppTheme.darkGrayText,
                  ),
                ),
                const SizedBox(height: 32),
                // Preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDarkBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryDarkBlue.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.preview,
                              color: AppTheme.primaryDarkBlue, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'معاينة الإشعار',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryDarkBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.yellowAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _titleController.text.isEmpty
                                        ? 'عنوان الإشعار'
                                        : _titleController.text,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _titleController.text.isEmpty
                                          ? AppTheme.darkGrayText
                                          : AppTheme.primaryDarkBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _messageController.text.isEmpty
                                  ? 'نص الإشعار سيظهر هنا...'
                                  : _messageController.text,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: _messageController.text.isEmpty
                                    ? AppTheme.darkGrayText
                                    : AppTheme.darkGrayText,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Send Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendNotification,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.white),
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      _isSending ? 'جارٍ الإرسال...' : 'إرسال الإشعار',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDarkBlue,
                      foregroundColor: AppTheme.white,
                      disabledBackgroundColor:
                          AppTheme.primaryDarkBlue.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
