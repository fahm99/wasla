class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String role;
  final String status;
  final String? bio;
  final String? gender;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.role = 'STUDENT',
    this.status = 'PENDING',
    this.bio,
    this.gender,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      role: json['role'] ?? 'STUDENT',
      status: json['status'] ?? 'PENDING',
      bio: json['bio'],
      gender: json['gender'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'status': status,
      'bio': bio,
      'gender': gender,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'gender': gender,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? bio,
    String? gender,
    String? status,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role,
      status: status ?? this.status,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      createdAt: createdAt,
    );
  }

  String get initials {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name.substring(0, name.length > 1 ? 2 : 1);
  }
}
