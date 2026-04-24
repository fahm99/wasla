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
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      level: json['level'] ?? 'مبتدئ',
      image: json['image'],
      status: json['status'] ?? 'مسودة',
      category: json['category'] ?? 'أخرى',
      providerId: json['provider_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      studentsCount: json['students_count'],
      modulesCount: json['modules_count'],
      averageRating: json['average_rating']?.toDouble(),
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
}
