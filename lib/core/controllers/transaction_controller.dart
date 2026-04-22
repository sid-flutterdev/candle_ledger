import 'package:candle_ledger/core/repositories/transaction_repository.dart';
import 'package:candle_ledger/core/services/firebase_auth_service.dart';
import 'package:get/get.dart';

/// Represents a deposit or withdrawal entry stored in Hive.
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
  final TransactionRepository _txRepo = Get.find<TransactionRepository>();
  final FirebaseAuthService _auth = Get.find<FirebaseAuthService>();

  var transactions = <AccountTransaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  String? get userId => _auth.currentUser?.uid;

  /// Loads transactions from local Hive cache first, then syncs from Firestore if logged in.
  Future<void> loadTransactions() async {
    // 1. Load from Hive for instant UI rendering
    _updateList(_txRepo.getAllLocal());

    // 2. Sync from Firestore if user is authenticated
    if (userId != null) {
      final remoteData = await _txRepo.syncFromFirestore(userId!);
      _updateList(remoteData);
    }
  }

  void _updateList(List<dynamic> rawData) {
    transactions.assignAll(
      rawData
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

    await _txRepo.save(tx.toMap(), userId ?? 'local_user');
    transactions.add(tx);
  }

  List<AccountTransaction> forAccount(String accountId) =>
      transactions.where((t) => t.accountId == accountId).toList();

  Future<void> deleteTransaction(String id) async {
    await _txRepo.delete(id, userId ?? 'local_user');
    transactions.removeWhere((t) => t.id == id);
  }

  Future<void> clearByAccountId(String accountId) async {
    final toDelete = transactions
        .where((t) => t.accountId == accountId)
        .toList();
    for (final tx in toDelete) {
      await _txRepo.delete(tx.id, userId ?? 'local_user');
    }
    transactions.removeWhere((t) => t.accountId == accountId);
  }
}
