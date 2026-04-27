import 'package:candle_ledger/core/constants/app_colors.dart';
import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/models/trade.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:flutter/material.dart';
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
                  _buildCalendarCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
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
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.year,
        helpText: "SELECT START DATE",
      );
      if (picked != null) {
        controller.selectedDate.value = picked;
      }
    } else if (controller.filterType.value == "Month") {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
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
        initialDate: DateTime.now(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              _buildPeriodDropdown(),
            ],
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

  Widget _buildPeriodDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.filterType.value,
          dropdownColor: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white38,
            size: 16,
          ),
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          items: periods.map((period) {
            return DropdownMenuItem(
              value: period,
              child: Text(period),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) controller.filterType.value = val;
          },
        ),
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
              color: (isProfit ? AppColors.profitGreen : AppColors.lossRed)
                  .withValues(alpha: 0.07),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            trade != null ? currencyFormat.format(trade.pnl) : "₹0",
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
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

  Widget _buildCalendarCard() {
    final DateTime now = controller.selectedDate.value;
    final int daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    // Group trades by day for the selected month
    final Map<int, double> dailyPnl = {};
    for (var trade in controller.trades) {
      if (trade.date.month == now.month && trade.date.year == now.year) {
        final day = trade.date.day;
        dailyPnl[day] = (dailyPnl[day] ?? 0) + trade.pnl;
      }
    }

    final List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MONTHLY CALENDAR",
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                DateFormat('MMMM').format(now).toUpperCase(),
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((day) {
              return SizedBox(
                width: 32,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            padding: EdgeInsets.zero,
            itemCount: daysInMonth + (firstWeekday - 1),
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) {
                return const SizedBox.shrink();
              }

              final int day = index - (firstWeekday - 1) + 1;
              final double? pnl = dailyPnl[day];
              Color? bgColor;
              Color textColor = Colors.white;

              if (pnl != null) {
                if (pnl > 0) {
                  bgColor = AppColors.profitGreen.withValues(alpha: 0.2);
                  textColor = AppColors.profitGreen;
                } else if (pnl < 0) {
                  bgColor = AppColors.lossRed.withValues(alpha: 0.2);
                  textColor = AppColors.lossRed;
                }
              }

              final bool isToday =
                  DateTime.now().day == day &&
                  DateTime.now().month == now.month &&
                  DateTime.now().year == now.year;

              return Container(
                decoration: BoxDecoration(
                  color: bgColor ?? Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(color: Colors.white.withValues(alpha: 0.2))
                      : null,
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: GoogleFonts.outfit(
                      color: textColor.withValues(
                        alpha: pnl != null ? 1.0 : 0.4,
                      ),
                      fontSize: 13,
                      fontWeight: pnl != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCalendarLegend("Profit", AppColors.profitGreen),
              const SizedBox(width: 16),
              _buildCalendarLegend("Loss", AppColors.lossRed),
              const SizedBox(width: 16),
              _buildCalendarLegend(
                "No Trade",
                Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
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
}
