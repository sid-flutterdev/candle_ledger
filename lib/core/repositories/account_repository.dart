import 'package:candle_ledger/core/models/account.dart';
import 'package:candle_ledger/core/repositories/base_repository.dart';
import 'package:hive/hive.dart';

class AccountRepository extends BaseRepository<Account> {
  AccountRepository() : super(
    box: Hive.box<Account>('accounts'),
    collectionName: 'accounts',
  );

  @override
  Account fromFirestore(Map<String, dynamic> map) => Account.fromFirestore(map);

  @override
  String getId(Account item) => item.id;

  @override
  Map<String, dynamic> toFirestore(Account item, String userId) => item.toFirestore(userId);
}
