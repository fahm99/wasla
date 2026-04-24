import '../providers/accounts_provider.dart';

class AccountsController {
  final AccountsProvider provider;

  AccountsController(this.provider);

  Future<void> loadAccounts({String filter = 'PENDING'}) async {
    provider.setFilter(filter);
  }

  Future<void> search(String query) async {
    provider.searchAccounts(query);
  }

  Future<void> getAccountDetail(String id) async {
    await provider.getAccountDetail(id);
  }

  Future<bool> approveAccount(String id) async {
    return await provider.updateAccountStatus(id, 'ACTIVE');
  }

  Future<bool> rejectAccount(String id) async {
    return await provider.updateAccountStatus(id, 'REJECTED');
  }

  Future<bool> suspendAccount(String id) async {
    return await provider.updateAccountStatus(id, 'SUSPENDED');
  }

  Future<bool> activateAccount(String id) async {
    return await provider.updateAccountStatus(id, 'ACTIVE');
  }

  void dispose() {}
}
