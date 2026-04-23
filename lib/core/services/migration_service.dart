import 'package:candle_ledger/core/repositories/account_repository.dart';
import 'package:candle_ledger/core/repositories/trade_repository.dart';
import 'package:candle_ledger/core/repositories/transaction_repository.dart';
import 'package:candle_ledger/core/widgets/app_snackbar.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class MigrationService extends GetxService {
  late Box _settingsBox;

  @override
  void onInit() {
    super.onInit();
    _settingsBox = Hive.box('settings');
  }

  /// Performs a one-time migration of local Hive data to Firestore.
  /// Triggered after login.
  Future<void> checkAndMigrate(String userId) async {
    final bool isMigrated = _settingsBox.get(
      'isMigrated_$userId',
      defaultValue: false,
    );

    if (isMigrated) {
      return;
    }

    // Get repositories
    final accountRepo = Get.find<AccountRepository>();
    final tradeRepo = Get.find<TradeRepository>();
    final transactionRepo = Get.find<TransactionRepository>();

    AppSnackbar.info(
      "Syncing Data",
      "Uploading your local ledger to the cloud...",
    );

    try {
      // 1. Migrate Accounts
      final accounts = accountRepo.getAllLocal();
      for (var account in accounts) {
        await accountRepo.save(account, userId);
      }

      // 2. Migrate Trades
      final trades = tradeRepo.getAllLocal();
      for (var trade in trades) {
        await tradeRepo.save(trade, userId);
      }

      // 3. Migrate Transactions
      final transactions = transactionRepo.getAllLocal();
      for (var tx in transactions) {
        await transactionRepo.save(tx, userId);
      }

      // Mark as migrated for this user
      await _settingsBox.put('isMigrated_$userId', true);

      AppSnackbar.success(
        "Cloud Sync Complete",
        "All your local data has been successfully backed up to Firestore.",
      );
    } catch (e) {
      // We don't set the flag to true so it can retry on next login
      AppSnackbar.error(
        "Sync Partial",
        "Some data could not be synced to the cloud. We will try again later.",
      );
    }
  }
}
