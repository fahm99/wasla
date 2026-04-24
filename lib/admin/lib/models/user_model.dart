class UserModel {
  final String id;
  final String email;
  final String? phone;
  final String fullName;
  final String role;
  final String status;
  final String? avatarUrl;
  final String? bio;
  final String? specialization;
  final String? qualification;
  final String? nationalId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.phone,
    required this.fullName,
    required this.role,
    required this.status,
    this.avatarUrl,
    this.bio,
    this.specialization,
    this.qualification,
    this.nationalId,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      avatarUrl: json['avatar_url']?.toString(),
      bio: json['bio']?.toString(),
      specialization: json['specialization']?.toString(),
      qualification: json['qualification']?.toString(),
      nationalId: json['national_id']?.toString(),
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
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'role': role,
      'status': status,
      'avatar_url': avatarUrl,
      'bio': bio,
      'specialization': specialization,
      'qualification': qualification,
      'national_id': nationalId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? status,
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? specialization,
    String? qualification,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      role: role,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      specialization: specialization ?? this.specialization,
      qualification: qualification ?? this.qualification,
      nationalId: nationalId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String get statusText {
    switch (status) {
      case 'ACTIVE':
        return 'نشط';
      case 'PENDING':
        return 'معلق';
      case 'SUSPENDED':
        return 'معلّق';
      case 'REJECTED':
        return 'مرفوض';
      default:
        return status;
    }
  }

  String get roleText {
    switch (role) {
      case 'ADMIN':
        return 'مشرف';
      case 'PROVIDER':
        return 'مقدم خدمة';
      case 'STUDENT':
        return 'طالب';
      default:
        return role;
    }
  }
}
