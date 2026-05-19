import 'dart:io';
import 'package:candle_ledger/core/constants/app_colors.dart';
import 'package:candle_ledger/core/constants/app_constants.dart';
import 'package:candle_ledger/core/controllers/notification_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/controllers/user_controller.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/models/trade.dart';
import 'package:candle_ledger/core/widgets/trade_detail_sheet.dart';
import 'package:candle_ledger/screen/all_trades_screen.dart';
import 'package:candle_ledger/screen/add_trade_screen.dart';
import 'package:candle_ledger/screen/more_screen.dart';
import 'package:candle_ledger/screen/notification_screen.dart';
import 'package:candle_ledger/screen/profile_screen.dart';
import 'package:candle_ledger/core/services/firebase_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:candle_ledger/core/widgets/risk_management_card.dart';
import 'package:fl_chart/fl_chart.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  final TradeController controller = Get.find<TradeController>();
  final UserController userController = Get.find<UserController>();
  final AccountController accountController = Get.find<AccountController>();
  final FirebaseAuthService authService = Get.find<FirebaseAuthService>();

  // 'Month' | 'Year' | 'All Time'
  String _pnlFilter = 'Month';
  String _summaryPeriod = 'Today';

  String get _displayName {
    // Priority 1: Local controller (instantly updated)
    if (userController.userName.isNotEmpty &&
        userController.userName != "Trader") {
      return userController.userName;
    }
    // Priority 2: Firebase Auth
    final user = authService.currentUser;
    if (user != null &&
        user.displayName != null &&
        user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    return "Trader";
  }

  final currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  double get _selectedPnl {
    switch (_pnlFilter) {
      case 'Year':
        return controller.trades
            .where((t) => t.date.year == DateTime.now().year)
            .fold(0.0, (sum, t) => sum + t.pnl);
      case 'All Time':
        return controller.allTimePnl;
      default: // Month
        return controller.currentMonthPnl;
    }
  }

  List<Trade> get _sortedSelectedTrades {
    final list = _selectedTrades;
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<double> get _selectedGraphData {
    final sorted = _sortedSelectedTrades;
    if (sorted.isEmpty) return [];
    double cum = 0;
    List<double> data = [0];
    for (var t in sorted) {
      cum += t.pnl;
      data.add(cum);
    }
    return data;
  }

  List<Trade> get _selectedTrades {
    switch (_pnlFilter) {
      case 'Year':
        return controller.trades
            .where((t) => t.date.year == DateTime.now().year)
            .toList();
      case 'All Time':
        return controller.trades.toList();
      default: // Month
        final now = DateTime.now();
        return controller.trades
            .where((t) => t.date.month == now.month && t.date.year == now.year)
            .toList();
    }
  }

  Map<String, double> get _summaryData {
    double pnl = 0.0;
    double roi = 0.0;
    double charges = 0.0;

    final now = DateTime.now();

    switch (_summaryPeriod) {
      case 'Month':
        pnl = controller.currentMonthPnl;
        final monthTrades = controller.trades
            .where((t) => t.date.month == now.month && t.date.year == now.year)
            .toList();
        if (monthTrades.isNotEmpty) {
          double totalInvestment = monthTrades.fold(
            0.0,
            (sum, t) => sum + (t.buyPrice * t.quantity),
          );
          if (totalInvestment > 0) {
            roi = (pnl / totalInvestment) * 100;
          }
          charges = monthTrades.fold(0.0, (sum, t) => sum + t.charges);
        }
        break;
      case 'Year':
        final yearTrades = controller.trades
            .where((t) => t.date.year == now.year)
            .toList();
        pnl = yearTrades.fold(0.0, (sum, t) => sum + t.pnl);
        if (yearTrades.isNotEmpty) {
          double totalInvestment = yearTrades.fold(
            0.0,
            (sum, t) => sum + (t.buyPrice * t.quantity),
          );
          if (totalInvestment > 0) {
            roi = (pnl / totalInvestment) * 100;
          }
          charges = yearTrades.fold(0.0, (sum, t) => sum + t.charges);
        }
        break;
      case 'All Time':
        pnl = controller.allTimePnl;
        final allTrades = controller.trades.toList();
        if (allTrades.isNotEmpty) {
          double totalInvestment = allTrades.fold(
            0.0,
            (sum, t) => sum + (t.buyPrice * t.quantity),
          );
          if (totalInvestment > 0) {
            roi = (pnl / totalInvestment) * 100;
          }
          charges = allTrades.fold(0.0, (sum, t) => sum + t.charges);
        }
        break;
      default: // Today
        pnl = controller.dailyPnl;
        roi = controller.todayRoi;
        charges = controller.todayCharges;
        break;
    }

    return {
      'pnl': pnl,
      'roi': roi,
      'charges': charges,
    };
  }

  String get _cardLabel {
    switch (_pnlFilter) {
      case 'Year':
        return 'YEARLY NET P&L';
      case 'All Time':
        return 'ALL TIME NET P&L';
      default:
        return 'MONTHLY NET P&L';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildTopBar(),
              const SizedBox(height: 30),
              Expanded(
                child: Obx(
                  () => SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildMainPnlCard(),
                        const SizedBox(height: 24),
                        _buildTodaySummaryCard(),
                        const SizedBox(height: 24),
                        _buildWinRateCard(),
                        const SizedBox(height: 24),
                        RiskManagementCard(),
                        const SizedBox(height: 24),
                        _buildRecentTradesHeader(),
                        const SizedBox(height: 16),
                        _buildRecentTradesList(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.to(
            () => const ScreenProfile(),
            transition: Transition.rightToLeftWithFade,
          ),
          child: Row(
            children: [
              Obx(() {
                final path = userController.profilePicturePath;
                final photoUrl = authService.currentUser?.photoURL;

                return CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  backgroundImage: path.isNotEmpty
                      ? FileImage(File(path)) as ImageProvider
                      : (photoUrl != null ? NetworkImage(photoUrl) : null),
                  child: (path.isEmpty && photoUrl == null)
                      ? ClipOval(
                          child: Image.asset(
                            'lib/assets/logo.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : null,
                );
              }),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello,",
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                  Obx(
                    () => Text(
                      _displayName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Obx(() {
          final unreadCount =
              Get.find<NotificationController>().unreadCount.value;
          return Row(
            children: [
              Stack(
                children: [
                  _buildIconButton(Icons.notifications_none_rounded, () {
                    Get.to(
                      () => NotificationScreen(),
                      transition: Transition.rightToLeftWithFade,
                    );
                  }),
                  if (unreadCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              _buildIconButton(Icons.settings_outlined, () {
                Get.to(
                  () => const ScreenMore(),
                  transition: Transition.rightToLeftWithFade,
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        width: 44,
        height: 44,
        borderRadius: 12,
        padding: EdgeInsets.zero,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildMainPnlCard() {
    final pnl = _selectedPnl;
    final isProfit = pnl >= 0;
    final graphData = _selectedGraphData;

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with label + dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _cardLabel,
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              _buildFilterDropdown(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pnl.toCurrencyStr,
            style: GoogleFonts.outfit(
              color: isProfit ? AppColors.profitGreen : AppColors.lossRed,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 100, child: _buildPnlGraph(isProfit, graphData)),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _pnlFilter,
          isDense: true,
          dropdownColor: const Color(0xFF0D0D0D).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white38,
            size: 16,
          ),
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          items: const [
            DropdownMenuItem(value: 'Month', child: Text('Month')),
            DropdownMenuItem(value: 'Year', child: Text('Year')),
            DropdownMenuItem(value: 'All Time', child: Text('All Time')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _pnlFilter = val);
          },
        ),
      ),
    );
  }

  Widget _buildSummaryFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _summaryPeriod,
          isDense: true,
          dropdownColor: const Color(0xFF0D0D0D).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white38,
            size: 16,
          ),
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          items: const [
            DropdownMenuItem(value: 'Today', child: Text('Today')),
            DropdownMenuItem(value: 'Month', child: Text('Month')),
            DropdownMenuItem(value: 'Year', child: Text('Year')),
            DropdownMenuItem(value: 'All Time', child: Text('All Time')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _summaryPeriod = val);
          },
        ),
      ),
    );
  }

  Widget _buildPnlGraph(bool isProfit, List<double> data) {
    if (data.isEmpty || data.length < 2) {
      return Center(
        child: Text(
          "No data",
          style: GoogleFonts.outfit(color: Colors.white24),
        ),
      );
    }

    final sortedTrades = _sortedSelectedTrades;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => const Color(0xFF1E293B).withValues(alpha: 0.9),
            tooltipBorderRadius: const BorderRadius.all(Radius.circular(8)),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final int index = touchedSpot.x.toInt();
                
                String text = "";
                if (index == 0) {
                  text = "Start: ₹0";
                } else if (index - 1 < sortedTrades.length) {
                  final trade = sortedTrades[index - 1];
                  final sign = trade.pnl >= 0 ? '+' : '';
                  text = "Trade P&L: $sign${trade.pnl.toPercentStr}";
                } else {
                  text = touchedSpot.y.toStringAsFixed(2);
                }
                
                return LineTooltipItem(
                  text,
                  GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
            isCurved: true,
            color: isProfit ? AppColors.profitGreen : AppColors.lossRed,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: isProfit ? AppColors.profitGreen : AppColors.lossRed,
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: (isProfit ? AppColors.profitGreen : AppColors.lossRed)
                  .withValues(alpha: 0.07),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummaryCard() {
    final data = _summaryData;
    final pnl = data['pnl'] ?? 0.0;
    final roi = data['roi'] ?? 0.0;
    final charges = data['charges'] ?? 0.0;

    final isPnlProfit = pnl >= 0;

    String headingText = "TODAY'S SUMMARY";
    if (_summaryPeriod == 'Month') {
      headingText = "MONTH'S SUMMARY";
    } else if (_summaryPeriod == 'Year') {
      headingText = "YEAR'S SUMMARY";
    } else if (_summaryPeriod == 'All Time') {
      headingText = "ALL TIME SUMMARY";
    }

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                headingText,
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              _buildSummaryFilterDropdown(),
            ],
          ),
          const SizedBox(height: 20),
          // P&L on Top (Centered & Hero style)
          Center(
            child: Column(
              children: [
                Text(
                  "P&L",
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${isPnlProfit ? '+' : ''}${pnl.toCurrencyStr}",
                  style: GoogleFonts.outfit(
                    color: isPnlProfit ? AppColors.profitGreen : AppColors.lossRed,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 16),
          // ROI & Charges on Bottom
          Row(
            children: [
              Expanded(
                child: _buildTodayMetric(
                  "ROI",
                  "${roi >= 0 ? '+' : ''}${roi.toPercentStr}%",
                  roi >= 0 ? AppColors.profitGreen : AppColors.lossRed,
                ),
              ),
              Container(
                height: 30,
                width: 1,
                color: Colors.white.withValues(alpha: 0.05),
              ),
              Expanded(
                child: _buildTodayMetric(
                  "Charges",
                  charges.toCurrencyStr,
                  Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWinRateCard() {
    final selectedTrades = _selectedTrades;
    final wins = selectedTrades.where((t) => t.isWin).length;
    final losses = selectedTrades.where((t) => !t.isWin).length;
    final total = selectedTrades.length;
    final winRate = total == 0 ? 0.0 : (wins / total) * 100;

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "WIN RATE (${_pnlFilter.toUpperCase()})",
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Left side: Pie Chart
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            color: AppColors.profitGreen,
                            value: wins.toDouble(),
                            radius: 12,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            color: AppColors.lossRed,
                            value: losses.toDouble(),
                            radius: 12,
                            showTitle: false,
                          ),
                          if (total == 0)
                            PieChartSectionData(
                              color: Colors.white.withValues(alpha: 0.05),
                              value: 1,
                              radius: 12,
                              showTitle: false,
                            ),
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        "${winRate.toPercentStr}%",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              // Right side: Legend
              Expanded(
                child: Column(
                  children: [
                    _buildWinRateLegendRow("Wins", wins, AppColors.profitGreen),
                    const SizedBox(height: 12),
                    _buildWinRateLegendRow("Losses", losses, AppColors.lossRed),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withValues(alpha: 0.05)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "TOTAL",
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$total trades",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWinRateLegendRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          "$count",
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTradesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Recent Trades",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton(
          onPressed: () => Get.to(
            () => const ScreenAllTrades(),
            transition: Transition.rightToLeftWithFade,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: Text(
            "View All",
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTradesList() {
    // Sort by date descending, then take 3
    final trades = controller.trades.toList();
    trades.sort((a, b) {
      int dateComp = b.date.compareTo(a.date);
      if (dateComp != 0) return dateComp;
      return b.id.compareTo(a.id);
    });

    final recentTrades = trades.take(3).toList();

    if (recentTrades.isEmpty) {
      return Center(
        child: Text(
          "No trades found",
          style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.2)),
        ),
      );
    }

    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < recentTrades.length; i++) ...[
            _buildRecentTradeItem(recentTrades[i]),
            if (i < recentTrades.length - 1)
              Divider(
                color: Colors.white.withValues(alpha: 0.05),
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentTradeItem(Trade trade) {
    final isWin = trade.pnl >= 0;
    final color = isWin ? AppColors.profitGreen : AppColors.lossRed;
    return Dismissible(
      key: Key(trade.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.15),
        ),
        child: const Icon(Icons.edit, color: AppColors.secondary, size: 24),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.lossRed.withValues(alpha: 0.15),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.lossRed,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          HapticFeedback.lightImpact();
          Get.to(() => ScreenAddTrade(tradeToEdit: trade));
          return false;
        }
        return await _showDeleteTradeConfirmation(trade);
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          HapticFeedback.heavyImpact();
          await accountController.updateBalance(
            trade.accountId,
            trade.pnl,
            true,
          );
          await controller.deleteTrade(trade.id);
        }
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Get.bottomSheet(
            TradeDetailSheet(trade: trade),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isWin
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trade.symbol,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${trade.segment.name.capitalizeFirst} · ${DateFormat('dd MMM yyyy').format(trade.date)}',
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    trade.pnl.toCurrencyStr,
                    style: GoogleFonts.outfit(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Qty: ${trade.quantity}',
                    style: GoogleFonts.outfit(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteTradeConfirmation(Trade trade) {
    return Get.dialog<bool>(
      Material(
        type: MaterialType.transparency,
        child: Center(
          child: GlassContainer(
            width: Get.width * 0.85,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lossRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: AppColors.lossRed,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Delete Trade?",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to delete this trade? This will also revert the balance. This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lossRed.withValues(alpha: 0.1),
                          foregroundColor: AppColors.lossRed,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Delete",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.8),
    );
  }
}
