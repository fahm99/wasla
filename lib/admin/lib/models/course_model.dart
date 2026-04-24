class CourseModel {
  final String id;
  final String title;
  final String? description;
  final String providerId;
  final String? providerName;
  final String? providerAvatar;
  final String? thumbnailUrl;
  final double? price;
  final String level;
  final String category;
  final String status;
  final int? studentCount;
  final double? rating;
  final int? totalLessons;
  final int? totalHours;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CourseModel({
    required this.id,
    required this.title,
    this.description,
    required this.providerId,
    this.providerName,
    this.providerAvatar,
    this.thumbnailUrl,
    this.price,
    required this.level,
    required this.category,
    required this.status,
    this.studentCount,
    this.rating,
    this.totalLessons,
    this.totalHours,
    this.createdAt,
    this.updatedAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      providerId: json['provider_id']?.toString() ?? '',
      providerName: json['provider_name']?.toString(),
      providerAvatar: json['provider_avatar']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      price: (json['price'] as num?)?.toDouble(),
      level: json['level']?.toString() ?? 'مبتدئ',
      category: json['category']?.toString() ?? 'عام',
      status: json['status']?.toString() ?? 'DRAFT',
      studentCount: json['student_count'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalLessons: json['total_lessons'] as int?,
      totalHours: json['total_hours'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'provider_id': providerId,
      'provider_name': providerName,
      'thumbnail_url': thumbnailUrl,
      'price': price,
      'level': level,
      'category': category,
      'status': status,
      'student_count': studentCount,
      'rating': rating,
      'total_lessons': totalLessons,
      'total_hours': totalHours,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CourseModel copyWith({String? status}) {
    return CourseModel(
      id: id,
      title: title,
      description: description,
      providerId: providerId,
      providerName: providerName,
      providerAvatar: providerAvatar,
      thumbnailUrl: thumbnailUrl,
      price: price,
      level: level,
      category: category,
      status: status ?? this.status,
      studentCount: studentCount,
      rating: rating,
      totalLessons: totalLessons,
      totalHours: totalHours,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String get statusText {
    switch (status) {
      case 'PUBLISHED':
        return 'منشور';
      case 'ARCHIVED':
        return 'مؤرشف';
      case 'DRAFT':
        return 'مسودة';
      case 'PENDING':
        return 'معلق';
      case 'REJECTED':
        return 'مرفوض';
      default:
        return status;
    }
  }

  String get levelText {
    switch (level) {
      case 'BEGINNER':
        return 'مبتدئ';
      case 'INTERMEDIATE':
        return 'متوسط';
      case 'ADVANCED':
        return 'متقدم';
      case 'ALL':
        return 'جميع المستويات';
      default:
        return level;
    }
  }
}
