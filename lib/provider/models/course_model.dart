class CourseModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String level;
  final String? image;
  final String status;
  final String category;
  final String providerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  int? studentsCount;
  int? modulesCount;
  double? averageRating;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.level,
    this.image,
    required this.status,
    required this.category,
    required this.providerId,
    this.createdAt,
    this.updatedAt,
    this.studentsCount,
    this.modulesCount,
    this.averageRating,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      level: json['level']?.toString() ?? 'BEGINNER',
      image: json['image']?.toString(),
      status: json['status']?.toString() ?? 'DRAFT',
      category: json['category']?.toString() ?? '',
      providerId: json['provider_id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      studentsCount: json['students_count'] as int?,
      modulesCount: json['modules_count'] as int?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'level': level,
      'image': image,
      'status': status,
      'category': category,
      'provider_id': providerId,
    };
  }

  CourseModel copyWith({
    String? title,
    String? description,
    double? price,
    String? level,
    String? image,
    String? status,
    String? category,
    int? studentsCount,
    int? modulesCount,
    double? averageRating,
  }) {
    return CourseModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      level: level ?? this.level,
      image: image ?? this.image,
      status: status ?? this.status,
      category: category ?? this.category,
      providerId: providerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      studentsCount: studentsCount ?? this.studentsCount,
      modulesCount: modulesCount ?? this.modulesCount,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  /// نص الحالة بالعربية
  String get statusText {
    switch (status) {
      case 'PUBLISHED':
        return 'منشور';
      case 'ARCHIVED':
        return 'مؤرشف';
      case 'DRAFT':
        return 'مسودة';
      default:
        return status;
    }
  }

  /// نص المستوى بالعربية
  String get levelText {
    switch (level) {
      case 'BEGINNER':
        return 'مبتدئ';
      case 'INTERMEDIATE':
        return 'متوسط';
      case 'ADVANCED':
        return 'متقدم';
      default:
        return level;
    }
  }

  bool get isPublished => status == 'PUBLISHED';
  bool get isDraft => status == 'DRAFT';
}
