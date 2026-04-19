import 'package:get/get.dart';
import 'package:hive/hive.dart';

/// Represents a deposit or withdrawal entry stored in Hive.
/// We use a plain Box<dynamic> to avoid needing a Hive adapter.
class AccountTransaction {
  final String id;
  final String accountId;
  final String type; // 'deposit' | 'withdrawal'
  final double amount;
  final DateTime date;
  final String? note;

  AccountTransaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<dynamic, dynamic> toMap() => {
        'id': id,
        'accountId': accountId,
        'type': type,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note ?? '',
      };

  factory AccountTransaction.fromMap(Map map) => AccountTransaction(
        id: map['id'] as String,
        accountId: map['accountId'] as String,
        type: map['type'] as String,
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        note: map['note'] as String?,
      );
}

class TransactionController extends GetxController {
  final Box _box = Hive.box('transactions');

  var transactions = <AccountTransaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    transactions.assignAll(
      _box.values
          .whereType<Map>()
          .map((m) => AccountTransaction.fromMap(m))
          .toList(),
    );
  }

  Future<void> addTransaction({
    required String accountId,
    required String type,
    required double amount,
    String? note,
  }) async {
    final tx = AccountTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      accountId: accountId,
      type: type,
      amount: amount,
      date: DateTime.now(),
      note: note,
    );
    await _box.add(tx.toMap());
    _load();
  }

  List<AccountTransaction> forAccount(String accountId) =>
      transactions.where((t) => t.accountId == accountId).toList();

  Future<void> deleteTransaction(String id) async {
    final key = _box.keys.firstWhere((k) {
      final v = _box.get(k);
      return v is Map && v['id'] == id;
    }, orElse: () => null);

    if (key != null) {
      await _box.delete(key);
      _load();
    }
  }

  Future<void> clearByAccountId(String accountId) async {
    final keys = _box.keys.where((k) {
      final v = _box.get(k);
      return v is Map && v['accountId'] == accountId;
    }).toList();
    for (final k in keys) {
      await _box.delete(k);
    }
    _load();
  }
}
