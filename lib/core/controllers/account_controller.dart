import 'package:candle_ledger/core/models/account.dart';
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

  Future<void> deleteAccount(int index) async {
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
