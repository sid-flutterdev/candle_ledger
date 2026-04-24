import '../models/trade.dart';
import 'base_repository.dart';

class TradeRepository extends BaseRepository<Trade> {
  TradeRepository() : super('trades');

  @override
  Trade fromFirestore(Map<String, dynamic> map) {
    return Trade.fromFirestore(map);
  }

  @override
  String getId(Trade item) => item.id;

  @override
  Map<String, dynamic> toFirestore(Trade item, String userId) {
    return item.toFirestore(userId);
  }
}
