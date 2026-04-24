import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/certificate_model.dart';

class CertificateCard extends StatelessWidget {
  final CertificateModel certificate;
  final VoidCallback? onTap;

  const CertificateCard({
    super.key,
    required this.certificate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified, color: AppTheme.secondaryAmber, size: 20),
                    const SizedBox(width: 6),
                    const Text(
                      'شهادة إتمام',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  certificate.formattedScore,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppTheme.secondaryAmber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              certificate.courseName,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: AppTheme.white,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              certificate.providerName,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  certificate.formattedDate,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'عرض',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_back, color: AppTheme.white, size: 16),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
