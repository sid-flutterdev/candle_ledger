import 'package:candle_ledger/core/models/trade.dart';
import 'package:candle_ledger/core/repositories/base_repository.dart';
import 'package:hive/hive.dart';

class TradeRepository extends BaseRepository<Trade> {
  TradeRepository() : super(
    box: Hive.box<Trade>('trades'),
    collectionName: 'trades',
  );

  @override
  Trade fromFirestore(Map<String, dynamic> map) => Trade.fromFirestore(map);

  @override
  String getId(Trade item) => item.id;

  @override
  Map<String, dynamic> toFirestore(Trade item, String userId) => item.toFirestore(userId);
}
