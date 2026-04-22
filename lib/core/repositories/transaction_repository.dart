import 'package:candle_ledger/core/repositories/base_repository.dart';
import 'package:hive/hive.dart';

class TransactionRepository extends BaseRepository<dynamic> {
  TransactionRepository() : super(
    box: Hive.box('transactions'),
    collectionName: 'transactions',
  );

  @override
  dynamic fromFirestore(Map<String, dynamic> map) => map;

  @override
  String getId(dynamic item) => item['id'].toString();

  @override
  Map<String, dynamic> toFirestore(dynamic item, String userId) {
    final map = Map<String, dynamic>.from(item as Map);
    map['userId'] = userId;
    return map;
  }
}
