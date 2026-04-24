class CourseModel {
  final String id;
  final String title;
  final String description;
  final String? shortDescription;
  final double price;
  final String level;
  final String? image;
  final String status;
  final String? category;
  final List<String> tags;
  final List<String> requirements;
  final List<String> objectives;
  final int durationMinutes;
  final String providerId;
  final String? providerName;
  final double? averageRating;
  final int? ratingCount;
  final int? enrollmentsCount;
  final String? providerAvatar;
  final DateTime? createdAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.shortDescription,
    required this.price,
    required this.level,
    this.image,
    required this.status,
    this.category,
    this.tags = const [],
    this.requirements = const [],
    this.objectives = const [],
    this.durationMinutes = 0,
    required this.providerId,
    this.providerName,
    this.averageRating,
    this.ratingCount,
    this.enrollmentsCount,
    this.providerAvatar,
    this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'],
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] ?? 0.0).toDouble(),
      level: json['level'] ?? 'مبتدئ',
      image: json['image'],
      status: json['status'] ?? 'draft',
      category: json['category'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      requirements: json['requirements'] != null ? List<String>.from(json['requirements']) : [],
      objectives: json['objectives'] != null ? List<String>.from(json['objectives']) : [],
      durationMinutes: json['duration_minutes'] ?? 0,
      providerId: json['provider_id'] ?? '',
      providerName: json['provider_name'],
      averageRating: (json['average_rating'] is num) ? (json['average_rating'] as num).toDouble() : null,
      ratingCount: json['rating_count'],
      enrollmentsCount: json['enrollments_count'],
      providerAvatar: json['provider_avatar'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'short_description': shortDescription,
      'price': price,
      'level': level,
      'image': image,
      'status': status,
      'category': category,
      'tags': tags,
      'requirements': requirements,
      'objectives': objectives,
      'duration_minutes': durationMinutes,
      'provider_id': providerId,
    };
  }

  String get formattedPrice => price == 0 ? 'مجاني' : '$price ر.س';

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '$hours ساعة و $minutes دقيقة';
    } else if (hours > 0) {
      return '$hours ساعة';
    }
    return '$minutes دقيقة';
  }
}
