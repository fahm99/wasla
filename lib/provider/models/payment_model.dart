class PaymentModel {
  final String id;
  final double amount;
  final String status;
  final String paymentMethod;
  final String? proofUrl;
  final String? providerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.proofUrl,
    this.providerId,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'معلق',
      paymentMethod: json['payment_method'] ?? 'تحويل بنكي',
      proofUrl: json['proof_url'],
      providerId: json['provider_id'],
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
      'amount': amount,
      'status': status,
      'payment_method': paymentMethod,
      'proof_url': proofUrl,
      'provider_id': providerId,
    };
  }
}
