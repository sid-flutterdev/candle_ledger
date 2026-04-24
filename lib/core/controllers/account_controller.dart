import 'dart:async';
import '../models/account.dart';
import 'trade_controller.dart';
import '../repositories/account_repository.dart';
import '../services/firebase_auth_service.dart';
import 'package:get/get.dart';

class AccountController extends GetxController {
  final AccountRepository _accountRepo = Get.find<AccountRepository>();
  final FirebaseAuthService _auth = Get.find<FirebaseAuthService>();

  var accounts = <Account>[].obs;
  StreamSubscription? _accountSub;

  @override
  void onInit() {
    super.onInit();
    // ✅ Re-sync and restart listener whenever Auth state changes
    _auth.authStateChanges.listen((user) {
      if (user != null) {
        _startListening();
        loadAccounts();
      } else {
        _accountSub?.cancel();
        accounts.clear();
      }
    });

    // Initial load
    if (userId != null) {
      _startListening();
      loadAccounts();
    }
  }

  @override
  void onClose() {
    _accountSub?.cancel();
    super.onClose();
  }

  void _startListening() {
    _accountSub?.cancel();
    _accountSub = _accountRepo.snapshots(userId ?? 'local_user').listen((data) {
      accounts.assignAll(data);
    });
  }

  String? get userId => _auth.currentUser?.uid;

  Future<void> loadAccounts() async {
    if (userId != null) {
      final remoteAccounts = await _accountRepo.syncFromFirestore(userId!);
      accounts.assignAll(remoteAccounts);
    }
  }

  Future<void> addAccount(Account account) async {
    await _accountRepo.save(account, userId ?? 'local_user');
    // Add locally for instant UI update
    if (!accounts.any((acc) => acc.id == account.id)) {
      accounts.add(account);
    }
  }

  Future<void> updateBalance(String accountId, double amount, bool isRemoval) async {
    final index = accounts.indexWhere((acc) => acc.id == accountId);
    if (index != -1) {
      final account = accounts[index];
      final updatedAccount = account.copyWith(
        liquidBalance: account.liquidBalance + (isRemoval ? -amount : amount),
      );
      await _accountRepo.save(updatedAccount, userId ?? 'local_user');
      accounts[index] = updatedAccount;
    }
  }

  Future<void> editAccount(String accountId, {
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
      accounts[index] = updatedAccount;
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
      accounts[index] = updatedAccount;
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
      accounts[index] = updatedAccount;
    }
  }

  Future<void> deleteAccount(String accountId) async {
    if (Get.isRegistered<TradeController>()) {
      await Get.find<TradeController>().deleteTradesByAccountId(accountId);
    }
    await _accountRepo.delete(accountId, userId ?? 'local_user');
    accounts.removeWhere((acc) => acc.id == accountId);
  }

  double get totalAssets => accounts.fold(0, (sum, item) => sum + item.totalBalance);
  double get totalLiquid => accounts.fold(0, (sum, item) => sum + item.liquidBalance);
  double get totalInvested => accounts.fold(0, (sum, item) => sum + item.investedBalance);
  double get allocationPercentage {
    if (totalAssets == 0) return 0;
    return (totalInvested / totalAssets) * 100;
  }
}
