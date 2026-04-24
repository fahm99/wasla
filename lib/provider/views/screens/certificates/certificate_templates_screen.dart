import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/certificate_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/confirmation_dialog.dart';

class CertificateTemplatesScreen extends StatefulWidget {
  final bool isEditing;

  const CertificateTemplatesScreen({super.key, this.isEditing = false});

  @override
  State<CertificateTemplatesScreen> createState() => _CertificateTemplatesScreenState();
}

class _CertificateTemplatesScreenState extends State<CertificateTemplatesScreen> {
  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      await context.read<CertificateProvider>().loadTemplates(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'قوالب الشهادات'),
        body: Consumer<CertificateProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'جاري تحميل القوالب...');
            }
            if (provider.templates.isEmpty) {
              return const EmptyState(
                title: 'لا توجد قوالب',
                message: 'أنشئ قالب شهادة لتخصيص شهادات المتدربين',
                icon: Icons.dashboard_customize_outlined,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.templates.length,
              itemBuilder: (context, index) {
                final template = provider.templates[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _parseColor(template['background_color'] ?? '#FFFFFF'),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.mediumGray),
                          ),
                          child: Center(
                            child: Text(
                              'شهادة',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _parseColor(template['text_color'] ?? '#000000'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                template['name'] ?? 'قالب بدون اسم',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'لون الخلفية: ${template['background_color'] ?? '#FFFFFF'}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.darkGrayText),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.redDanger),
                          onPressed: () async {
                            final confirm = await ConfirmationDialog.show(
                              context,
                              title: 'حذف القالب',
                              message: 'هل أنت متأكد من حذف هذا القالب؟',
                              isDanger: true,
                              confirmText: 'حذف',
                            );
                            if (confirm == true) {
                              await provider.deleteTemplate(template['id']);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم حذف القالب'), backgroundColor: AppTheme.greenSuccess),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      final hex = colorString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}
    return Colors.white;
  }
}
