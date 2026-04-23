import 'package:candle_ledger/core/constants/app_colors.dart';
import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/models/trade.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/trade_detail_sheet.dart';
import 'package:candle_ledger/screen/add_trade_screen.dart';
import 'package:candle_ledger/screen/all_trades_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ScreenAnalytics extends StatefulWidget {
  const ScreenAnalytics({super.key});

  @override
  State<ScreenAnalytics> createState() => _ScreenAnalyticsState();
}

class _ScreenAnalyticsState extends State<ScreenAnalytics> {
  final TradeController controller = Get.find<TradeController>();
  final AccountController accountController = Get.find<AccountController>();
  final currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  final List<String> periods = ['Week', 'Month', 'Year', 'Custom'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          bottom: false,
          child: Obx(
            () => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Analytics",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPeriodSelector(),
                  const SizedBox(height: 20),
                  _buildDateNavigator(),
                  const SizedBox(height: 24),
                  _buildPnlCard(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBestWorstCard(
                          "Best Trade",
                          controller.bestTrade,
                          AppColors.profitGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBestWorstCard(
                          "Worst Trade",
                          controller.worstTrade,
                          AppColors.lossRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  Row(
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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
                  ),
                  const SizedBox(height: 16),
                  _buildRecentTradesList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      borderRadius: 12,
      child: Row(
        children: periods.map((period) {
          bool isSelected = controller.filterType.value == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.filterType.value = period,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showDatePicker() async {
    if (controller.filterType.value == "Custom") {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(
          start: controller.customStartDate.value,
          end: controller.customEndDate.value,
        ),
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 1)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.profitGreen,
                onPrimary: Colors.black,
                surface: Color(0xFF1A1A1A),
                onSurface: Colors.white,
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: const Color(0xFF121212),
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        controller.customStartDate.value = picked.start;
        controller.customEndDate.value = picked.end;
      }
    } else if (controller.filterType.value == "Week") {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: controller.selectedDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        helpText: "SELECT START DATE",
      );
      if (picked != null) {
        controller.selectedDate.value = picked;
      }
    } else if (controller.filterType.value == "Month") {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: controller.selectedDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.year,
        helpText: "SELECT MONTH",
      );
      if (picked != null) {
        controller.selectedDate.value = DateTime(picked.year, picked.month);
      }
    } else if (controller.filterType.value == "Year") {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: controller.selectedDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.year,
        helpText: "SELECT YEAR",
      );
      if (picked != null) {
        controller.selectedDate.value = DateTime(picked.year);
      }
    }
  }

  Widget _buildDateNavigator() {
    String label = "";
    if (controller.filterType.value == "Week") {
      final start = controller.selectedDate.value;
      final end = start.add(const Duration(days: 6));
      label =
          "${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM').format(end)}";
    } else if (controller.filterType.value == "Month") {
      label = DateFormat('MMMM yyyy').format(controller.selectedDate.value);
    } else if (controller.filterType.value == "Year") {
      label = DateFormat('yyyy').format(controller.selectedDate.value);
    } else {
      label =
          "${DateFormat('dd MMM').format(controller.customStartDate.value)} - ${DateFormat('dd MMM').format(controller.customEndDate.value)}";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNavButton(Icons.chevron_left_rounded, () => _navigateDate(-1)),
        const SizedBox(width: 16),
        InkWell(
          onTap: _showDatePicker,
          borderRadius: BorderRadius.circular(30),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            borderRadius: 30,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildNavButton(Icons.chevron_right_rounded, () => _navigateDate(1)),
      ],
    );
  }

  void _navigateDate(int offset) {
    DateTime current = controller.selectedDate.value;
    if (controller.filterType.value == "Week") {
      controller.selectedDate.value = current.add(Duration(days: offset * 7));
    } else if (controller.filterType.value == "Month") {
      controller.selectedDate.value = DateTime(
        current.year,
        current.month + offset,
      );
    } else if (controller.filterType.value == "Year") {
      controller.selectedDate.value = DateTime(current.year + offset);
    }
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildPnlCard() {
    final double pnl = controller.filteredTotalPnl;
    final bool isProfit = pnl >= 0;

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PERIOD PERFORMANCE",
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(pnl),
            style: GoogleFonts.outfit(
              color: isProfit ? AppColors.profitGreen : AppColors.lossRed,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: _buildPnlGraph(isProfit),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat(
                "Trades",
                controller.filteredTrades.length.toString(),
              ),
              _buildMiniStat(
                "Win Rate",
                "${controller.winRate.toStringAsFixed(1)}%",
              ),
              _buildMiniStat(
                "Profit Factor",
                controller.profitFactor.toStringAsFixed(2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPnlGraph(bool isProfit) {
    final data = controller.filteredCumulativePnlData;
    if (data.isEmpty) {
      return Center(
        child: Text(
          "No data for graph",
          style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.2)),
        ),
      );
    }

    return LineChart(
      LineChartData(
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
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  (isProfit ? AppColors.profitGreen : AppColors.lossRed)
                      .withValues(alpha: 0.2),
                  (isProfit ? AppColors.profitGreen : AppColors.lossRed)
                      .withValues(alpha: 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildBestWorstCard(String title, Trade? trade, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trade != null ? currencyFormat.format(trade.pnl) : "₹0",
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trade != null ? trade.symbol : "N/A",
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TRADING SUMMARY",
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(
            "Total Trades",
            controller.filteredTrades.length.toString(),
          ),
          _buildSummaryRow(
            "Win Rate",
            "${controller.winRate.toStringAsFixed(1)}%",
          ),
          _buildSummaryRow(
            "Total Win",
            currencyFormat.format(controller.totalWin),
            color: AppColors.profitGreen,
          ),
          _buildSummaryRow(
            "Total Loss",
            currencyFormat.format(controller.totalLoss),
            color: AppColors.lossRed,
          ),
          _buildSummaryRow("Avg Win", currencyFormat.format(controller.avgWin)),
          _buildSummaryRow(
            "Avg Loss",
            currencyFormat.format(controller.avgLoss),
          ),
          _buildSummaryRow(
            "Max Drawdown",
            currencyFormat.format(controller.maxDrawdown),
            color: Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: color ?? Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTradesList() {
    final trades = controller.filteredTrades.reversed.take(5).toList();
    if (trades.isEmpty) {
      return Center(
        child: Text(
          "No trades found for this period",
          style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.2)),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trades.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trade = trades[index];
        return Dismissible(
          key: Key(trade.id),
          direction: DismissDirection.horizontal,
          background: Container(
            margin: const EdgeInsets.only(bottom: 0),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.edit, color: AppColors.secondary, size: 24),
          ),
          secondaryBackground: Container(
            margin: const EdgeInsets.only(bottom: 0),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.lossRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
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
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trade.symbol,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM').format(trade.date),
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    currencyFormat.format(trade.pnl),
                    style: GoogleFonts.outfit(
                      color: trade.pnl >= 0
                          ? AppColors.profitGreen
                          : AppColors.lossRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                          backgroundColor: AppColors.lossRed.withValues(
                            alpha: 0.8,
                          ),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Delete",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
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
