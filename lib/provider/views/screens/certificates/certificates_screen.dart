import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/certificate_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';

class CertificatesScreen extends StatefulWidget {
  final String courseId;

  const CertificatesScreen({super.key, required this.courseId});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    await context.read<CertificateProvider>().loadCertificatesByCourse(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'الشهادات'),
        body: Consumer<CertificateProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'جاري تحميل الشهادات...');
            }
            if (provider.certificates.isEmpty) {
              return const EmptyState(
                title: 'لا توجد شهادات',
                message: 'لم يتم إصدار أي شهادة لهذه الدورة بعد',
                icon: Icons.workspace_premium_outlined,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.certificates.length,
              itemBuilder: (context, index) {
                final cert = provider.certificates[index];
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
                          color: AppTheme.yellowAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.workspace_premium, color: Colors.orange, size: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cert.studentName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue)),
                            const SizedBox(height: 4),
                            Text(cert.courseName, style: const TextStyle(fontSize: 13, color: AppTheme.darkGrayText)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('الدرجة: ${cert.score.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: AppTheme.greenSuccess, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 16),
                                Text('رقم: ${cert.certificateNumber}', style: const TextStyle(fontSize: 11, color: AppTheme.darkGrayText)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
