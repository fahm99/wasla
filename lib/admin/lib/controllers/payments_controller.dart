import '../providers/payments_provider.dart';

class PaymentsController {
  final PaymentsProvider provider;

  PaymentsController(this.provider);

  Future<void> loadPayments({String filter = ''}) async {
    provider.setFilter(filter);
  }

  Future<void> search(String query) async {
    provider.searchPayments(query);
  }

  Future<void> getPaymentDetail(String id) async {
    await provider.getPaymentDetail(id);
  }

  Future<bool> approvePayment(String id) async {
    return await provider.approvePayment(id);
  }

  Future<bool> rejectPayment(String id, String? reason) async {
    return await provider.rejectPayment(id, reason);
  }

  void dispose() {}
}
