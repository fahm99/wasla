import '../providers/certificate_provider.dart';

class CertificateController {
  final CertificateProvider _provider;

  CertificateController(this._provider);

  Future<bool> validateAndIssue({
    required String studentName,
    required String courseName,
    required String providerName,
    required double score,
    required String studentId,
    required String courseId,
    required String providerId,
  }) {
    if (studentName.trim().isEmpty) {
      _provider.setError('اسم الطالب مطلوب');
      return Future.value(false);
    }
    if (courseName.trim().isEmpty) {
      _provider.setError('اسم الدورة مطلوب');
      return Future.value(false);
    }
    if (score < 0 || score > 100) {
      _provider.setError('الدرجة يجب أن تكون بين 0 و 100');
      return Future.value(false);
    }
    return _provider
        .issueCertificate(
          studentName: studentName,
          courseName: courseName,
          providerName: providerName,
          score: score,
          studentId: studentId,
          courseId: courseId,
          providerId: providerId,
        )
        .then((v) => v != null);
  }
}
