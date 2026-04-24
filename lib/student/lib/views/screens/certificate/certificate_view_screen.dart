import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../config/app_theme.dart';
import '../../../providers/certificate_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/loading_widget.dart';

class CertificateViewScreen extends StatefulWidget {
  final String certificateId;

  const CertificateViewScreen({super.key, required this.certificateId});

  @override
  State<CertificateViewScreen> createState() => _CertificateViewScreenState();
}

class _CertificateViewScreenState extends State<CertificateViewScreen> {
  @override
  void initState() {
    super.initState();
    _loadCertificate();
  }

  void _loadCertificate() {
    context.read<CertificateProvider>().loadCertificateById(widget.certificateId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CertificateProvider>();
    final cert = provider.currentCertificate;

    if (provider.isLoading) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'الشهادة', showBack: true),
        body: const LoadingWidget(message: 'جاري تحميل الشهادة...'),
      );
    }

    if (cert == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'الشهادة', showBack: true),
        body: const Center(child: Text('الشهادة غير موجودة')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: const CustomAppBar(title: 'الشهادة', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryBlue,
                  width: 3,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.verified,
                      size: 40,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'شهادة إتمام',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: AppTheme.greyText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryAmber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    cert.courseName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'يشهد بأن',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: AppTheme.greyText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      cert.studentName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'قد أتم بنجاح جميع متطلبات الدورة المقدمة من',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppTheme.greyText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cert.providerName,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'الدرجة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppTheme.greyText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cert.formattedScore,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: AppTheme.lightGrey,
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                      ),
                      Column(
                        children: [
                          const Text(
                            'رقم الشهادة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppTheme.greyText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cert.certificateNumber,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    cert.formattedDate,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppTheme.greyText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Share.share(
                          'لقد حصلت على شهادة إتمام دورة "${cert.courseName}" من ${cert.providerName} على منصة وسلة التعليمية! 🎓',
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('مشاركة'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
