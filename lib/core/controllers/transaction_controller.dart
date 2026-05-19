import 'dart:async';
import '../repositories/transaction_repository.dart';
import '../services/firebase_auth_service.dart';
import 'package:get/get.dart';

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

  Map<String, dynamic> toMap() => {
    'id': id,
    'accountId': accountId,
    'type': type,
    'amount': amount,
    'date': date.toIso8601String(),
    'note': note ?? '',
  };

  factory AccountTransaction.fromMap(Map<String, dynamic> map) => AccountTransaction(
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

  StreamSubscription? _txSub;

  @override
  void onInit() {
    super.onInit();
    // ✅ Re-sync and restart listener whenever Auth state changes
    _auth.authStateChanges.listen((user) {
      if (user != null) {
        _startListening();
        loadTransactions();
      } else {
        _txSub?.cancel();
        transactions.clear();
      }
    });

    // Initial load
    if (userId != null) {
      _startListening();
      loadTransactions();
    }
  }

  @override
  void onClose() {
    _txSub?.cancel();
    super.onClose();
  }

  void _startListening() {
    _txSub?.cancel();
    _txSub = _txRepo.snapshots(userId ?? 'local_user').listen((data) {
      _updateList(data);
    });
  }

  String? get userId => _auth.currentUser?.uid;

  Future<void> loadTransactions() async {
    if (userId != null) {
      final remoteData = await _txRepo.syncFromFirestore(userId!);
      _updateList(remoteData);
    }
  }

  void _updateList(List<Map<String, dynamic>> rawData) {
    transactions.assignAll(
      rawData.map((m) => AccountTransaction.fromMap(m)).toList(),
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
    // Add locally for instant UI update
    if (!transactions.any((t) => t.id == tx.id)) {
      transactions.add(tx);
    }
  }

  Future<void> updateTransaction(AccountTransaction tx) async {
    await _txRepo.save(tx.toMap(), userId ?? 'local_user');
    final index = transactions.indexWhere((t) => t.id == tx.id);
    if (index != -1) {
      transactions[index] = tx;
    }
  }

  List<AccountTransaction> forAccount(String accountId) =>
      transactions.where((t) => t.accountId == accountId).toList();

  Future<void> deleteTransaction(String id) async {
    transactions.removeWhere((t) => t.id == id);
    await _txRepo.delete(id, userId ?? 'local_user');
  }

  Future<void> clearByAccountId(String accountId) async {
    final toDelete = transactions.where((t) => t.accountId == accountId).toList();
    transactions.removeWhere((t) => t.accountId == accountId);
    for (final tx in toDelete) {
      await _txRepo.delete(tx.id, userId ?? 'local_user');
    }
  }
}
