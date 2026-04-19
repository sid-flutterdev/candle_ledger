import 'package:candle_ledger/core/models/account.dart';
import 'package:candle_ledger/core/models/trade.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class AccountController extends GetxController {
  final Box<Account> _accountBox = Hive.box<Account>('accounts');

  var accounts = <Account>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
  }

  void loadAccounts() {
    accounts.assignAll(_accountBox.values.toList());
  }

  Future<void> addAccount(Account account) async {
    await _accountBox.add(account);
    loadAccounts();
  }

  /// ✅ SINGLE updateBalance method (fixed)
  Future<void> updateBalance(
    String accountId,
    double amount,
    bool isRemoval,
  ) async {
    final index = accounts.indexWhere((acc) => acc.id == accountId);

    if (index != -1) {
      final account = accounts[index];

      final updatedAccount = Account(
        id: account.id,
        name: account.name,
        broker: account.broker,
        initialBalance: account.initialBalance,
        liquidBalance: account.liquidBalance + (isRemoval ? -amount : amount),
        investedBalance: account.investedBalance,
        iconIndex: account.iconIndex,
        colorHex: account.colorHex,
      );

      await _accountBox.putAt(index, updatedAccount);
      loadAccounts();
    }
  }

  Future<void> editAccount(
    String accountId, {
    required String name,
    required String broker,
    required int colorHex,
    required double initialBalance,
  }) async {
    final accountIndex = accounts.indexWhere((acc) => acc.id == accountId);

    if (accountIndex != -1) {
      final account = accounts[accountIndex];

      final diff = initialBalance - account.initialBalance;

      final updatedAccount = Account(
        id: account.id,
        name: name,
        broker: broker,
        initialBalance: initialBalance,
        liquidBalance: account.liquidBalance + diff,
        investedBalance: account.investedBalance,
        iconIndex: account.iconIndex,
        colorHex: colorHex,
      );

      await _accountBox.putAt(accountIndex, updatedAccount);
      loadAccounts();
    }
  }

  Future<void> addDeposit(String accountId, double amount) async {
    final accountIndex = accounts.indexWhere((acc) => acc.id == accountId);

    if (accountIndex != -1) {
      final account = accounts[accountIndex];

      final updatedAccount = Account(
        id: account.id,
        name: account.name,
        broker: account.broker,
        initialBalance: account.initialBalance + amount,
        liquidBalance: account.liquidBalance + amount,
        investedBalance: account.investedBalance,
        iconIndex: account.iconIndex,
        colorHex: account.colorHex,
      );

      await _accountBox.putAt(accountIndex, updatedAccount);
      loadAccounts();
    }
  }

  Future<void> addWithdrawal(String accountId, double amount) async {
    final accountIndex = accounts.indexWhere((acc) => acc.id == accountId);

    if (accountIndex != -1) {
      final account = accounts[accountIndex];

      final updatedAccount = Account(
        id: account.id,
        name: account.name,
        broker: account.broker,
        initialBalance: account.initialBalance - amount,
        liquidBalance: account.liquidBalance - amount,
        investedBalance: account.investedBalance,
        iconIndex: account.iconIndex,
        colorHex: account.colorHex,
      );

      await _accountBox.putAt(accountIndex, updatedAccount);
      loadAccounts();
    }
  }

  Future<void> deleteAccount(int index) async {
    final accountId = accounts[index].id;

    /// Delete trades
    if (Get.isRegistered<TradeController>()) {
      await Get.find<TradeController>().deleteTradesByAccountId(accountId);
    } else {
      final tradeBox = Hive.box<Trade>('trades');

      final keysToDelete = tradeBox.keys.where((key) {
        final trade = tradeBox.get(key);
        return trade?.accountId == accountId;
      }).toList();

      for (var key in keysToDelete) {
        await tradeBox.delete(key);
      }
    }

    /// Delete transactions
    try {
      final txBox = Hive.box('transactions');

      final keysToDelete = txBox.keys.where((k) {
        final v = txBox.get(k);
        return v is Map && v['accountId'] == accountId;
      }).toList();

      for (final k in keysToDelete) {
        await txBox.delete(k);
      }
    } catch (_) {}

    await _accountBox.deleteAt(index);
    loadAccounts();
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
