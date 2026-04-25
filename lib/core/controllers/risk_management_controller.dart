import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'trade_controller.dart';
import '../services/firebase_auth_service.dart';

class RiskManagementController extends GetxController {
  FirebaseAuthService get _auth => Get.find<FirebaseAuthService>();
  TradeController get _tradeController => Get.find<TradeController>();

  // Selected period: Daily | Weekly | Monthly
  var selectedPeriod = "Daily".obs;

  // Max loss limits per period (0 = not set)
  var dailyMaxLoss = 0.0.obs;
  var weeklyMaxLoss = 0.0.obs;
  var monthlyMaxLoss = 0.0.obs;

  String? get userId => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges.listen((user) {
      if (user != null) _loadLimits();
    });
    if (userId != null) _loadLimits();
  }

  Future<void> _loadLimits() async {
    if (userId == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('risk_management')
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        dailyMaxLoss.value = (data['dailyMaxLoss'] ?? 0.0).toDouble();
        weeklyMaxLoss.value = (data['weeklyMaxLoss'] ?? 0.0).toDouble();
        monthlyMaxLoss.value = (data['monthlyMaxLoss'] ?? 0.0).toDouble();
      }
    } catch (_) {}
  }

  Future<void> saveLimits() async {
    if (userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('risk_management')
          .set({
        'dailyMaxLoss': dailyMaxLoss.value,
        'weeklyMaxLoss': weeklyMaxLoss.value,
        'monthlyMaxLoss': monthlyMaxLoss.value,
      });
    } catch (_) {}
  }

  double get currentMaxLoss {
    switch (selectedPeriod.value) {
      case "Weekly":
        return weeklyMaxLoss.value;
      case "Monthly":
        return monthlyMaxLoss.value;
      default:
        return dailyMaxLoss.value;
    }
  }

  /// Returns the NET LOSS (positive number) for the selected period.
  /// If the user is in profit, it returns 0.0.
  double get currentPeriodLoss {
    final now = DateTime.now();
    final trades = _tradeController.trades;
    double netPnl = 0.0;

    switch (selectedPeriod.value) {
      case "Daily":
        netPnl = trades
            .where((t) =>
                t.date.day == now.day &&
                t.date.month == now.month &&
                t.date.year == now.year)
            .fold(0.0, (sum, t) => sum + t.pnl);
        break;

      case "Weekly":
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final weekStart = DateTime(
            startOfWeek.year, startOfWeek.month, startOfWeek.day);
        netPnl = trades
            .where((t) =>
                t.date.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
                t.date.isBefore(weekStart.add(const Duration(days: 7))))
            .fold(0.0, (sum, t) => sum + t.pnl);
        break;

      case "Monthly":
        netPnl = trades
            .where((t) =>
                t.date.month == now.month &&
                t.date.year == now.year)
            .fold(0.0, (sum, t) => sum + t.pnl);
        break;

      default:
        netPnl = 0.0;
    }

    // If netPnl is negative (e.g. -200), we lost 200. Return 200.
    // If netPnl is positive (e.g. 100), we lost 0. Return 0.0.
    return netPnl < 0 ? netPnl.abs() : 0.0;
  }

  /// 0.0 → 1.0+ (clamped to display max)
  double get usageRatio {
    if (currentMaxLoss <= 0) return 0.0;
    return currentPeriodLoss / currentMaxLoss;
  }

  /// safe | warning | exceeded
  String get status {
    final r = usageRatio;
    if (r >= 1.0) return "exceeded";
    if (r >= 0.75) return "warning";
    return "safe";
  }

  void setLimit(String period, double value) {
    switch (period) {
      case "Daily":
        dailyMaxLoss.value = value;
        break;
      case "Weekly":
        weeklyMaxLoss.value = value;
        break;
      case "Monthly":
        monthlyMaxLoss.value = value;
        break;
    }
    saveLimits();
  }
}
