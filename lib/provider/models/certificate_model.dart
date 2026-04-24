class CertificateModel {
  final String id;
  final String certificateNumber;
  final String studentName;
  final String courseName;
  final String providerName;
  final double score;
  final String? studentId;
  final String? courseId;
  final String? providerId;
  final DateTime? createdAt;

  CertificateModel({
    required this.id,
    required this.certificateNumber,
    required this.studentName,
    required this.courseName,
    required this.providerName,
    required this.score,
    this.studentId,
    this.courseId,
    this.providerId,
    this.createdAt,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] ?? '',
      certificateNumber: json['certificate_number'] ?? '',
      studentName: json['student_name'] ?? '',
      courseName: json['course_name'] ?? '',
      providerName: json['provider_name'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      studentId: json['student_id'],
      courseId: json['course_id'],
      providerId: json['provider_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'certificate_number': certificateNumber,
      'student_name': studentName,
      'course_name': courseName,
      'provider_name': providerName,
      'score': score,
      'student_id': studentId,
      'course_id': courseId,
      'provider_id': providerId,
    };
  }
}
