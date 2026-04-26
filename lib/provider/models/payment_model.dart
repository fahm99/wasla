class PaymentModel {
  final String id;
  final double amount;
  final String status;
  final String paymentMethod;
  final String? proofUrl;
  final String? providerId;
  final DateTime? createdAt;
  final DateTime? processedAt;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.proofUrl,
    this.providerId,
    this.createdAt,
    this.processedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'PENDING',
      paymentMethod: json['payment_method']?.toString() ?? '',
      proofUrl: json['proof_url']?.toString(),
      providerId: json['provider_id']?.toString(),
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
      'amount': amount,
      'status': status,
      'payment_method': paymentMethod,
      'proof_url': proofUrl,
      'provider_id': providerId,
    };
  }

  /// نص الحالة بالعربية
  String get statusText {
    switch (status) {
      case 'PENDING':
        return 'معلق';
      case 'APPROVED':
        return 'مقبول';
      case 'REJECTED':
        return 'مرفوض';
      case 'REFUNDED':
        return 'مسترد';
      default:
        return status;
    }
  }
}
