class PaymentModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final double amount;
  final String status;
  final String? proofUrl;
  final String? courseId;
  final String? courseTitle;
  final String paymentMethod;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? processedAt;

  PaymentModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.amount,
    required this.status,
    this.proofUrl,
    this.courseId,
    this.courseTitle,
    required this.paymentMethod,
    this.notes,
    this.createdAt,
    this.processedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      userId:
          json['provider_id']?.toString() ?? json['user_id']?.toString() ?? '',
      userName:
          json['provider_name']?.toString() ?? json['user_name']?.toString(),
      userAvatar: json['provider_avatar']?.toString() ??
          json['user_avatar']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'PENDING',
      proofUrl: json['proof_url']?.toString(),
      courseId: json['course_id']?.toString(),
      courseTitle: json['course_title']?.toString(),
      paymentMethod: json['payment_method']?.toString() ?? '',
      notes: json['notes']?.toString() ?? json['description']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      processedAt: json['processed_at'] != null
          ? DateTime.tryParse(json['processed_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'amount': amount,
      'status': status,
      'proof_url': proofUrl,
      'course_id': courseId,
      'course_title': courseTitle,
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
    };
  }

  PaymentModel copyWith({String? status, String? notes}) {
    return PaymentModel(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      amount: amount,
      status: status ?? this.status,
      proofUrl: proofUrl,
      courseId: courseId,
      courseTitle: courseTitle,
      paymentMethod: paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      processedAt: status != this.status ? DateTime.now() : processedAt,
    );
  }

  String get statusText {
    switch (status) {
      case 'APPROVED':
        return 'مقبولة';
      case 'PENDING':
        return 'معلقة';
      case 'REJECTED':
        return 'مرفوضة';
      default:
        return status;
    }
  }

  String get paymentMethodText {
    switch (paymentMethod) {
      case 'BANK_TRANSFER':
        return 'تحويل بنكي';
      case 'CREDIT_CARD':
        return 'بطاقة ائتمان';
      case 'WALLET':
        return 'محفظة إلكترونية';
      default:
        return paymentMethod;
    }
  }
}
