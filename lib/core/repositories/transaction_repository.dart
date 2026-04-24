import 'base_repository.dart';

class TransactionRepository extends BaseRepository<Map<String, dynamic>> {
  TransactionRepository() : super('transactions');

  @override
  Map<String, dynamic> fromFirestore(Map<String, dynamic> map) {
    return map;
  }

  @override
  String getId(Map<String, dynamic> item) {
    return (item['id'] ?? '').toString();
  }

  @override
  Map<String, dynamic> toFirestore(Map<String, dynamic> item, String userId) {
    final map = Map<String, dynamic>.from(item);
    map['userId'] = userId;
    return map;
  }
}
