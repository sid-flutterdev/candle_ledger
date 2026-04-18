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

  Future<void> updateBalance(String accountId, double amount, bool isInvested) async {
    final accountIndex = accounts.indexWhere((acc) => acc.id == accountId);
    if (accountIndex != -1) {
      final account = accounts[accountIndex];
      // When a trade is saved, we adjust liquid and invested balances.
      // amount is the P&L if closing, or trade cost if opening.
      // This is a simplified logic for now.
      
      final updatedAccount = Account(
        id: account.id,
        name: account.name,
        broker: account.broker,
        initialBalance: account.initialBalance,
        liquidBalance: account.liquidBalance + amount,
        investedBalance: account.investedBalance, // logic for invested vs liquid can be refined
        iconIndex: account.iconIndex,
        colorHex: account.colorHex,
      );
      
      await _accountBox.putAt(accountIndex, updatedAccount);
      loadAccounts();
    }
  }

  Future<void> deleteAccount(int index) async {
    final accountId = accounts[index].id;
    
    // Delete trades first
    if (Get.isRegistered<TradeController>()) {
      await Get.find<TradeController>().deleteTradesByAccountId(accountId);
    } else {
      // If controller not active, we still need to clean up the box
      final tradeBox = Hive.box<Trade>('trades');
      final keysToDelete = tradeBox.keys.where((key) {
        final trade = tradeBox.get(key);
        return trade?.accountId == accountId;
      }).toList();
      for (var key in keysToDelete) {
        await tradeBox.delete(key);
      }
    }

    await _accountBox.deleteAt(index);
    loadAccounts();
  }

  double get totalAssets => accounts.fold(0, (sum, item) => sum + item.totalBalance);
  double get totalLiquid => accounts.fold(0, (sum, item) => sum + item.liquidBalance);
  double get totalInvested => accounts.fold(0, (sum, item) => sum + item.investedBalance);
  
  double get allocationPercentage {
    if (totalAssets == 0) return 0;
    return (totalInvested / totalAssets) * 100;
  }
}
