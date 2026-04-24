import '../providers/payment_provider.dart';

class PaymentController {
  final PaymentProvider _provider;

  PaymentController(this._provider);

  Future<bool> validateAndCreate({
    required double amount,
    required String paymentMethod,
    dynamic proofFile,
  }) {
    if (amount <= 0) {
      _provider.setError('المبلغ يجب أن يكون أكبر من صفر');
      return Future.value(false);
    }
    return _provider
        .createPayment(
          amount: amount,
          paymentMethod: paymentMethod,
          proofFile: proofFile,
        )
        .then((v) => v != null);
  }
}
