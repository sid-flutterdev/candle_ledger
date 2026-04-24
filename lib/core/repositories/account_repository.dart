import '../models/account.dart';
import 'base_repository.dart';

class AccountRepository extends BaseRepository<Account> {
  AccountRepository() : super('accounts');

  @override
  Account fromFirestore(Map<String, dynamic> map) {
    return Account.fromFirestore(map);
  }

  @override
  String getId(Account item) => item.id;

  @override
  Map<String, dynamic> toFirestore(Account item, String userId) {
    return item.toFirestore(userId);
  }
}
