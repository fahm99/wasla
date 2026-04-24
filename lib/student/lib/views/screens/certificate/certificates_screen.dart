import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../providers/certificate_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/certificate_card.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  void _loadCertificates() {
    context.read<CertificateProvider>().loadMyCertificates();
  }

  Future<void> _refreshCertificates() async {
    await context.read<CertificateProvider>().loadMyCertificates();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CertificateProvider>();

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: const CustomAppBar(title: 'شهاداتي', showBack: true),
      body: provider.isLoading
          ? const LoadingWidget(message: 'جاري تحميل الشهادات...')
          : provider.certificates.isEmpty
              ? const EmptyState(
                  icon: Icons.verified_outlined,
                  title: 'لا توجد شهادات',
                  subtitle: 'أكمل الدورات بنجاح واحصل على شهادات معتمدة',
                  actionText: 'تصفح الدورات',
                )
              : RefreshIndicator(
                  color: AppTheme.primaryBlue,
                  onRefresh: _refreshCertificates,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.certificates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final cert = provider.certificates[index];
                      return CertificateCard(
                        certificate: cert,
                        onTap: () => context.push('/certificates/${cert.id}'),
                      );
                    },
                  ),
                ),
    );
  }
}
