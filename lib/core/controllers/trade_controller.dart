import 'package:candle_ledger/core/models/trade.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class TradeController extends GetxController {
  final Box<Trade> _tradeBox = Hive.box<Trade>('trades');

  var trades = <Trade>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTrades();
  }

  var selectedDate = DateTime.now().obs;
  var filterType = "Month".obs; // "Week", "Month", "Year", "Custom"
  var customStartDate = DateTime.now().subtract(const Duration(days: 7)).obs;
  var customEndDate = DateTime.now().obs;

  void loadTrades() {
    trades.assignAll(_tradeBox.values.toList());
  }

  void setFilter(String type, DateTime date) {
    filterType.value = type;
    selectedDate.value = date;
  }

  Future<void> addTrade(Trade trade) async {
    await _tradeBox.add(trade);
    loadTrades();
  }

  Future<void> updateTrade(Trade trade) async {
    final key = _tradeBox.keys.firstWhere((k) {
      final t = _tradeBox.get(k);
      return t?.id == trade.id;
    }, orElse: () => null);

    if (key != null) {
      await _tradeBox.put(key, trade);
      loadTrades();
    }
  }

  List<Trade> get filteredTrades {
    return trades.where((t) {
      if (filterType.value == "Week") {
        // 7 day window starting from selectedDate
        final start = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day);
        final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end);
      } else if (filterType.value == "Month") {
        return t.date.month == selectedDate.value.month &&
            t.date.year == selectedDate.value.year;
      } else if (filterType.value == "Year") {
        return t.date.year == selectedDate.value.year;
      } else if (filterType.value == "Custom") {
        final start = DateTime(customStartDate.value.year, customStartDate.value.month, customStartDate.value.day);
        final end = DateTime(customEndDate.value.year, customEndDate.value.month, customEndDate.value.day, 23, 59, 59);
        return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end);
      }
      return true;
    }).toList();
  }

  // ================== STATS ==================

  double get allTimePnl => trades.fold(0.0, (sum, item) => sum + item.pnl);

  double get currentMonthPnl {
    final now = DateTime.now();
    return trades
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.pnl);
  }

  double get filteredTotalPnl => filteredTrades.fold(0.0, (sum, item) => sum + item.pnl);

  double get dailyPnl {
    final today = DateTime.now();
    return trades
        .where(
          (t) =>
              t.date.day == today.day &&
              t.date.month == today.month &&
              t.date.year == today.year,
        )
        .fold(0.0, (sum, t) => sum + t.pnl);
  }

  double get todayCharges => 0.0; // Placeholder as per screenshot

  double get todayRoi {
    final today = DateTime.now();
    final todayTrades = trades.where(
      (t) =>
          t.date.day == today.day &&
          t.date.month == today.month &&
          t.date.year == today.year,
    );
    if (todayTrades.isEmpty) return 0.0;

    double totalInvestment = todayTrades.fold(0.0, (sum, t) => sum + (t.buyPrice * t.quantity));
    if (totalInvestment == 0) return 0.0;

    return (dailyPnl / totalInvestment) * 100;
  }

  int get todayWins {
    final today = DateTime.now();
    return trades.where((t) => 
      t.date.day == today.day && 
      t.date.month == today.month && 
      t.date.year == today.year && 
      t.isWin
    ).length;
  }

  int get todayLosses {
    final today = DateTime.now();
    return trades.where((t) => 
      t.date.day == today.day && 
      t.date.month == today.month && 
      t.date.year == today.year && 
      !t.isWin
    ).length;
  }

  // Filtered stats for Win Rate card
  int get filteredWins => filteredTrades.where((t) => t.isWin).length;
  int get filteredLosses => filteredTrades.where((t) => !t.isWin).length;
  int get filteredTotalTrades => filteredTrades.length;

  double get profitFactor {
    double grossProfit = trades
        .where((t) => t.pnl > 0)
        .fold(0.0, (sum, t) => sum + t.pnl);

    double grossLoss = trades
        .where((t) => t.pnl < 0)
        .fold(0.0, (sum, t) => sum + t.pnl)
        .abs();

    if (grossLoss == 0) return grossProfit > 0 ? 100 : 0;

    return grossProfit / grossLoss;
  }

  double get winRate {
    if (filteredTrades.isEmpty) return 0;
    final wins = filteredTrades.where((t) => t.isWin).length;
    return (wins / filteredTrades.length) * 100;
  }

  double get currentMonthWinRate {
    final now = DateTime.now();
    final monthTrades = trades
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();

    if (monthTrades.isEmpty) return 0;

    final wins = monthTrades.where((t) => t.isWin).length;
    return (wins / monthTrades.length) * 100;
  }

  double get lastMonthWinRate {
    final now = DateTime.now();
    final lastMonth = now.month == 1 ? 12 : now.month - 1;
    final lastMonthYear = now.month == 1 ? now.year - 1 : now.year;

    final monthTrades = trades
        .where((t) => t.date.month == lastMonth && t.date.year == lastMonthYear)
        .toList();

    if (monthTrades.isEmpty) return 0;

    final wins = monthTrades.where((t) => t.isWin).length;
    return (wins / monthTrades.length) * 100;
  }

  List<double> get cumulativePnlData {
    double current = 0;
    return trades.map((t) {
      current += t.pnl;
      return current;
    }).toList();
  }

  List<double> get filteredCumulativePnlData {
    double current = 0;
    return filteredTrades.map((t) {
      current += t.pnl;
      return current;
    }).toList();
  }

  Trade? get bestTrade {
    if (filteredTrades.isEmpty) return null;
    return filteredTrades.reduce((a, b) => a.pnl > b.pnl ? a : b);
  }

  Trade? get worstTrade {
    if (filteredTrades.isEmpty) return null;
    return filteredTrades.reduce((a, b) => a.pnl < b.pnl ? a : b);
  }

  double get totalWin =>
      filteredTrades.where((t) => t.isWin).fold(0.0, (sum, t) => sum + t.pnl);

  double get totalLoss =>
      filteredTrades.where((t) => t.pnl < 0).fold(0.0, (sum, t) => sum + t.pnl);

  double get avgWin {
    final wins = filteredTrades.where((t) => t.isWin).length;
    return wins == 0 ? 0 : totalWin / wins;
  }

  double get avgLoss {
    final losses = filteredTrades.where((t) => t.pnl < 0).length;
    return losses == 0 ? 0 : totalLoss / losses;
  }

  double get maxDrawdown {
    if (filteredTrades.isEmpty) return 0;

    double maxPnl = 0;
    double currentPnl = 0;
    double maxDD = 0;

    for (var trade in filteredTrades) {
      currentPnl += trade.pnl;

      if (currentPnl > maxPnl) {
        maxPnl = currentPnl;
      }

      double dd = maxPnl - currentPnl;

      if (dd > maxDD) {
        maxDD = dd;
      }
    }

    return maxDD;
  }

  Future<void> deleteTrade(String tradeId) async {
    final key = _tradeBox.keys.firstWhere((k) {
      final trade = _tradeBox.get(k);
      return trade?.id == tradeId;
    }, orElse: () => null);

    if (key != null) {
      await _tradeBox.delete(key);
      loadTrades();
    }
  }

  Future<void> deleteTradesByAccountId(String accountId) async {
    final keysToDelete = _tradeBox.keys.where((key) {
      final trade = _tradeBox.get(key);
      return trade?.accountId == accountId;
    }).toList();

    for (var key in keysToDelete) {
      await _tradeBox.delete(key);
    }
    loadTrades();
  }
}
