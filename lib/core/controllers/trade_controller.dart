import 'dart:async';
import '../models/trade.dart';
import '../repositories/trade_repository.dart';
import '../services/firebase_auth_service.dart';
import '../services/storage_service.dart';
import 'package:get/get.dart';

/// Controller to manage trades and analytics.
class TradeController extends GetxController {
  final TradeRepository _tradeRepo = Get.find<TradeRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  final FirebaseAuthService _auth = Get.find<FirebaseAuthService>();

  var trades = <Trade>[].obs;
  StreamSubscription? _tradeSub;

  @override
  void onInit() {
    super.onInit();
    // ✅ Re-sync and restart listener whenever Auth state changes
    _auth.authStateChanges.listen((user) {
      if (user != null) {
        _startListening();
        loadTrades();
      } else {
        _tradeSub?.cancel();
        trades.clear();
      }
    });

    // Initial load
    if (userId != null) {
      _startListening();
      loadTrades();
    }
  }

  @override
  void onClose() {
    _tradeSub?.cancel();
    super.onClose();
  }

  void _startListening() {
    _tradeSub?.cancel();
    _tradeSub = _tradeRepo.snapshots(userId ?? 'local_user').listen((data) {
      trades.assignAll(data);
    });
  }

  String? get userId => _auth.currentUser?.uid;

  var selectedDate = DateTime.now().obs;
  var filterType = "Month".obs;
  var customStartDate = DateTime.now().subtract(const Duration(days: 7)).obs;
  var customEndDate = DateTime.now().obs;

  // --- All Trades Screen State ---
  var allTradesSortType =
      "Newest First".obs; // Newest First, Oldest First, PnL High, PnL Low
  var allTradesSegmentFilter = "All".obs; // All, Equity, Options, Futures
  var allTradesResultFilter = "All".obs; // All, Wins, Losses
  var allTradesAccountFilter = "All".obs; // All, or accountId

  Future<void> loadTrades() async {
    if (userId != null) {
      final remoteTrades = await _tradeRepo.syncFromFirestore(userId!);
      trades.assignAll(remoteTrades);
    }
  }

  void setFilter(String type, DateTime date) {
    filterType.value = type;
    selectedDate.value = date;
  }

  Future<void> addTrade(Trade trade) async {
    String? cloudScreenshotUrl;
    if (userId != null &&
        trade.screenshotPath != null &&
        trade.screenshotPath!.isNotEmpty) {
      cloudScreenshotUrl = await _storageService.uploadTradeScreenshot(
        userId: userId!,
        tradeId: trade.id,
        localPath: trade.screenshotPath!,
      );
    }
    final tradeToSave = trade.copyWith(cloudScreenshotUrl: cloudScreenshotUrl);
    await _tradeRepo.save(tradeToSave, userId ?? 'local_user');
    // Add locally for instant UI update
    if (!trades.any((t) => t.id == tradeToSave.id)) {
      trades.add(tradeToSave);
    }
  }

  Future<void> updateTrade(Trade trade) async {
    await _tradeRepo.save(trade, userId ?? 'local_user');
    final index = trades.indexWhere((t) => t.id == trade.id);
    if (index != -1) {
      trades[index] = trade;
    }
  }

  List<Trade> get filteredTrades {
    return trades.where((t) {
      if (filterType.value == "Week") {
        final start = DateTime(
          selectedDate.value.year,
          selectedDate.value.month,
          selectedDate.value.day,
        );
        final end = start.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end);
      } else if (filterType.value == "Month") {
        return t.date.month == selectedDate.value.month &&
            t.date.year == selectedDate.value.year;
      } else if (filterType.value == "Year") {
        return t.date.year == selectedDate.value.year;
      } else if (filterType.value == "Custom") {
        final start = DateTime(
          customStartDate.value.year,
          customStartDate.value.month,
          customStartDate.value.day,
        );
        final end = DateTime(
          customEndDate.value.year,
          customEndDate.value.month,
          customEndDate.value.day,
          23,
          59,
          59,
        );
        return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end);
      }
      return true;
    }).toList();
  }

  List<Trade> get sortedAndFilteredAllTrades {
    List<Trade> result = trades.toList();

    // 1. Apply Segment Filter
    if (allTradesSegmentFilter.value != "All") {
      result = result.where((t) {
        return t.segment.name.toLowerCase() ==
            allTradesSegmentFilter.value.toLowerCase();
      }).toList();
    }

    // 2. Apply Result Filter
    if (allTradesResultFilter.value == "Wins") {
      result = result.where((t) => t.isWin).toList();
    } else if (allTradesResultFilter.value == "Losses") {
      result = result.where((t) => !t.isWin).toList();
    }

    // 3. Apply Account Filter
    if (allTradesAccountFilter.value != "All") {
      result = result
          .where((t) => t.accountId == allTradesAccountFilter.value)
          .toList();
    }

    // 4. Apply Sorting
    result.sort((a, b) {
      if (allTradesSortType.value == "Newest First") {
        // First sort by date
        int dateComp = b.date.compareTo(a.date);
        if (dateComp != 0) return dateComp;
        // Then sort by ID (which is the creation timestamp)
        return b.id.compareTo(a.id);
      } else if (allTradesSortType.value == "Oldest First") {
        int dateComp = a.date.compareTo(b.date);
        if (dateComp != 0) return dateComp;
        return a.id.compareTo(b.id);
      } else if (allTradesSortType.value == "PnL High") {
        return b.pnl.compareTo(a.pnl);
      } else if (allTradesSortType.value == "PnL Low") {
        return a.pnl.compareTo(b.pnl);
      }
      return 0;
    });

    return result;
  }

  double get allTimePnl => trades.fold(0.0, (sum, item) => sum + item.pnl);
  double get currentMonthPnl {
    final now = DateTime.now();
    return trades
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.pnl);
  }

  double get filteredTotalPnl =>
      filteredTrades.fold(0.0, (sum, item) => sum + item.pnl);
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

  double get todayCharges {
    final today = DateTime.now();
    return trades
        .where(
          (t) =>
              t.date.day == today.day &&
              t.date.month == today.month &&
              t.date.year == today.year,
        )
        .fold(0.0, (sum, t) => sum + t.charges);
  }

  double get todayRoi {
    final today = DateTime.now();
    final todayTrades = trades.where(
      (t) =>
          t.date.day == today.day &&
          t.date.month == today.month &&
          t.date.year == today.year,
    );
    if (todayTrades.isEmpty) return 0.0;
    double totalInvestment = todayTrades.fold(
      0.0,
      (sum, t) => sum + (t.buyPrice * t.quantity),
    );
    if (totalInvestment == 0) return 0.0;
    return (dailyPnl / totalInvestment) * 100;
  }

  int get todayWins {
    final today = DateTime.now();
    return trades
        .where(
          (t) =>
              t.date.day == today.day &&
              t.date.month == today.month &&
              t.date.year == today.year &&
              t.isWin,
        )
        .length;
  }

  int get todayLosses {
    final today = DateTime.now();
    return trades
        .where(
          (t) =>
              t.date.day == today.day &&
              t.date.month == today.month &&
              t.date.year == today.year &&
              !t.isWin,
        )
        .length;
  }

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
    return (filteredWins / filteredTotalTrades) * 100;
  }

  double get currentMonthWinRate {
    final now = DateTime.now();
    final monthTrades = trades
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();
    if (monthTrades.isEmpty) return 0;
    return (monthTrades.where((t) => t.isWin).length / monthTrades.length) *
        100;
  }

  double get lastMonthWinRate {
    final now = DateTime.now();
    final lastMonth = now.month == 1 ? 12 : now.month - 1;
    final lastMonthYear = now.month == 1 ? now.year - 1 : now.year;
    final monthTrades = trades
        .where((t) => t.date.month == lastMonth && t.date.year == lastMonthYear)
        .toList();
    if (monthTrades.isEmpty) return 0;
    return (monthTrades.where((t) => t.isWin).length / monthTrades.length) *
        100;
  }

  Trade? get bestTrade {
    final wins = filteredTrades.where((t) => t.pnl > 0).toList();
    if (wins.isEmpty) return null;
    return wins.reduce((a, b) => a.pnl > b.pnl ? a : b);
  }

  Trade? get worstTrade {
    final losses = filteredTrades.where((t) => t.pnl < 0).toList();
    if (losses.isEmpty) return null;
    return losses.reduce((a, b) => a.pnl < b.pnl ? a : b);
  }

  List<double> get cumulativePnlData {
    if (trades.isEmpty) return [];
    double currentPnl = 0;
    List<double> data = [0];
    final sortedTrades = trades.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    for (var trade in sortedTrades) {
      currentPnl += trade.pnl;
      data.add(currentPnl);
    }
    return data;
  }

  List<double> get filteredCumulativePnlData {
    if (filteredTrades.isEmpty) return [];
    double currentPnl = 0;
    List<double> data = [0];
    final sortedTrades = filteredTrades.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    for (var trade in sortedTrades) {
      currentPnl += trade.pnl;
      data.add(currentPnl);
    }
    return data;
  }

  double get totalWin =>
      trades.where((t) => t.pnl > 0).fold(0.0, (sum, t) => sum + t.pnl);
  double get totalLoss =>
      trades.where((t) => t.pnl < 0).fold(0.0, (sum, t) => sum + t.pnl).abs();

  double get avgWin {
    final wins = trades.where((t) => t.pnl > 0);
    if (wins.isEmpty) return 0;
    return totalWin / wins.length;
  }

  double get avgLoss {
    final losses = trades.where((t) => t.pnl < 0);
    if (losses.isEmpty) return 0;
    return totalLoss / losses.length;
  }

  double get maxDrawdown {
    if (trades.isEmpty) return 0;
    double maxPnl = 0;
    double currentPnl = 0;
    double maxDD = 0;
    final sortedTrades = trades.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    for (var trade in sortedTrades) {
      currentPnl += trade.pnl;
      if (currentPnl > maxPnl) maxPnl = currentPnl;
      double dd = maxPnl - currentPnl;
      if (dd > maxDD) maxDD = dd;
    }
    return maxDD;
  }

  Future<void> deleteTrade(String tradeId) async {
    trades.removeWhere((t) => t.id == tradeId);
    if (userId != null) {
      await _storageService.deleteScreenshot(userId!, tradeId);
    }
    await _tradeRepo.delete(tradeId, userId ?? 'local_user');
  }

  Future<void> deleteTradesByAccountId(String accountId) async {
    final keysToDelete = trades.where((t) => t.accountId == accountId).toList();
    trades.removeWhere((t) => t.accountId == accountId);
    for (var trade in keysToDelete) {
      if (userId != null) {
        await _storageService.deleteScreenshot(userId!, trade.id);
      }
      await _tradeRepo.delete(trade.id, userId ?? 'local_user');
    }
  }

  Future<void> clearAllTrades() async {
    for (var trade in trades) {
      if (userId != null) {
        await _storageService.deleteScreenshot(userId!, trade.id);
      }
      await _tradeRepo.delete(trade.id, userId ?? 'local_user');
    }
    trades.clear();
  }
}
