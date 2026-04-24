class RatingModel {
  final String id;
  final double rating;
  final String? review;
  final String studentId;
  final String courseId;
  final String? studentName;
  final String? studentAvatar;
  final DateTime? createdAt;

  RatingModel({
    required this.id,
    required this.rating,
    this.review,
    required this.studentId,
    required this.courseId,
    this.studentName,
    this.studentAvatar,
    this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] ?? '',
      rating: (json['rating'] is int) ? (json['rating'] as int).toDouble() : (json['rating'] ?? 0.0).toDouble(),
      review: json['review'],
      studentId: json['student_id'] ?? '',
      courseId: json['course_id'] ?? '',
      studentName: json['student_name'],
      studentAvatar: json['student_avatar'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'review': review,
      'student_id': studentId,
      'course_id': courseId,
    };
  }

  String get formattedDate {
    if (createdAt == null) return '';
    return '${createdAt!.year}/${createdAt!.month.toString().padLeft(2, '0')}/${createdAt!.day.toString().padLeft(2, '0')}';
  }
}
