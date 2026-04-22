import 'package:candle_ledger/core/models/account.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/repositories/account_repository.dart';
import 'package:candle_ledger/core/services/firebase_auth_service.dart';
import 'package:get/get.dart';

class AccountController extends GetxController {
  final AccountRepository _accountRepo = Get.find<AccountRepository>();
  final FirebaseAuthService _auth = Get.find<FirebaseAuthService>();

  var accounts = <Account>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
  }

  String? get userId => _auth.currentUser?.uid;

  /// Loads accounts from local Hive cache first, then syncs from Firestore if logged in.
  Future<void> loadAccounts() async {
    // 1. Load from Hive for instant UI rendering
    accounts.assignAll(_accountRepo.getAllLocal());

    // 2. Sync from Firestore if user is authenticated
    if (userId != null) {
      final remoteAccounts = await _accountRepo.syncFromFirestore(userId!);
      accounts.assignAll(remoteAccounts);
    }
  }

  Future<void> addAccount(Account account) async {
    await _accountRepo.save(account, userId ?? 'local_user');
    accounts.add(account);
  }

  Future<void> updateBalance(
    String accountId,
    double amount,
    bool isRemoval,
  ) async {
    final index = accounts.indexWhere((acc) => acc.id == accountId);

    if (index != -1) {
      final account = accounts[index];
      final updatedAccount = account.copyWith(
        liquidBalance: account.liquidBalance + (isRemoval ? -amount : amount),
      );

      await _accountRepo.save(updatedAccount, userId ?? 'local_user');
      accounts[index] = updatedAccount; // Reactive update
    }
  }

  Future<void> editAccount(
    String accountId, {
    required String name,
    required String broker,
    required int colorHex,
    required double initialBalance,
  }) async {
    final index = accounts.indexWhere((acc) => acc.id == accountId);

    if (index != -1) {
      final account = accounts[index];
      final diff = initialBalance - account.initialBalance;

      final updatedAccount = account.copyWith(
        name: name,
        broker: broker,
        initialBalance: initialBalance,
        liquidBalance: account.liquidBalance + diff,
        colorHex: colorHex,
      );

      await _accountRepo.save(updatedAccount, userId ?? 'local_user');
      accounts[index] = updatedAccount; // Reactive update
    }
  }

  Future<void> addDeposit(String accountId, double amount) async {
    final index = accounts.indexWhere((acc) => acc.id == accountId);

    if (index != -1) {
      final account = accounts[index];
      final updatedAccount = account.copyWith(
        initialBalance: account.initialBalance + amount,
        liquidBalance: account.liquidBalance + amount,
      );

      await _accountRepo.save(updatedAccount, userId ?? 'local_user');
      accounts[index] = updatedAccount; // Reactive update
    }
  }

  Future<void> addWithdrawal(String accountId, double amount) async {
    final index = accounts.indexWhere((acc) => acc.id == accountId);

    if (index != -1) {
      final account = accounts[index];
      final updatedAccount = account.copyWith(
        initialBalance: account.initialBalance - amount,
        liquidBalance: account.liquidBalance - amount,
      );

      await _accountRepo.save(updatedAccount, userId ?? 'local_user');
      accounts[index] = updatedAccount; // Reactive update
    }
  }

  Future<void> deleteAccount(String accountId) async {
    // Delete linked trades
    if (Get.isRegistered<TradeController>()) {
      await Get.find<TradeController>().deleteTradesByAccountId(accountId);
    }

    // Delete account from repository (Firestore + Hive)
    await _accountRepo.delete(accountId, userId ?? 'local_user');

    // Remove from local list
    accounts.removeWhere((acc) => acc.id == accountId);
  }

  /// ── Aggregates ─────────────────────────────────────────────

  double get totalAssets =>
      accounts.fold(0, (sum, item) => sum + item.totalBalance);

  double get totalLiquid =>
      accounts.fold(0, (sum, item) => sum + item.liquidBalance);

  double get totalInvested =>
      accounts.fold(0, (sum, item) => sum + item.investedBalance);

  double get allocationPercentage {
    if (totalAssets == 0) return 0;
    return (totalInvested / totalAssets) * 100;
  }
}
