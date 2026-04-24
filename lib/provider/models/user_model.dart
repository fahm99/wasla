class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String role;
  final String status;
  final String? institutionType;
  final String? institutionName;
  final String? bankAccount;
  final String? subscriptionPlan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.role,
    required this.status,
    this.institutionType,
    this.institutionName,
    this.bankAccount,
    this.subscriptionPlan,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      role: json['role'] ?? 'provider',
      status: json['status'] ?? 'active',
      institutionType: json['institution_type'],
      institutionName: json['institution_name'],
      bankAccount: json['bank_account'],
      subscriptionPlan: json['subscription_plan'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
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
      'institution_type': institutionType,
      'institution_name': institutionName,
      'bank_account': bankAccount,
      'subscription_plan': subscriptionPlan,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? institutionType,
    String? institutionName,
    String? bankAccount,
    String? subscriptionPlan,
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
      institutionType: institutionType ?? this.institutionType,
      institutionName: institutionName ?? this.institutionName,
      bankAccount: bankAccount ?? this.bankAccount,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
