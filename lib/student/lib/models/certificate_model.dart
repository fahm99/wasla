class CertificateModel {
  final String id;
  final String certificateNumber;
  final String studentName;
  final String courseName;
  final String providerName;
  final double score;
  final DateTime issuedAt;
  final String studentId;
  final String courseId;
  final String providerId;
  final String? courseImage;

  CertificateModel({
    required this.id,
    required this.certificateNumber,
    required this.studentName,
    required this.courseName,
    required this.providerName,
    required this.score,
    required this.issuedAt,
    required this.studentId,
    required this.courseId,
    required this.providerId,
    this.courseImage,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] ?? '',
      certificateNumber: json['certificate_number'] ?? '',
      studentName: json['student_name'] ?? '',
      courseName: json['course_name'] ?? '',
      providerName: json['provider_name'] ?? '',
      score: (json['score'] is int) ? (json['score'] as int).toDouble() : (json['score'] ?? 0.0).toDouble(),
      issuedAt: json['issued_at'] != null ? DateTime.parse(json['issued_at']) : DateTime.now(),
      studentId: json['student_id'] ?? '',
      courseId: json['course_id'] ?? '',
      providerId: json['provider_id'] ?? '',
      courseImage: json['course_image'],
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
      'issued_at': issuedAt.toIso8601String(),
      'student_id': studentId,
      'course_id': courseId,
      'provider_id': providerId,
    };
  }

  String get formattedDate {
    return '${issuedAt.year}/${issuedAt.month.toString().padLeft(2, '0')}/${issuedAt.day.toString().padLeft(2, '0')}';
  }

  String get formattedScore => '${score.toStringAsFixed(0)}%';
}
