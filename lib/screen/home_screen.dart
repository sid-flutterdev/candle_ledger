import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  final TradeController controller = Get.find<TradeController>();
  final currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.black),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          _buildQuickStatsRow(),
                          const SizedBox(height: 24),
                          _buildWinRateAnalyticsCard(),
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
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.greenAccent.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF1A1A1A),
                child: Icon(Icons.person_outline_rounded, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello,",
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                Text(
                  "Trader",
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
        _buildIconButton(Icons.notifications_none_rounded, () {}),
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
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildMainPnlCard() {
    final double totalPnl = controller.allTimePnl;
    final bool isProfit = totalPnl >= 0;

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TOTAL NET P&L",
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(totalPnl),
            style: GoogleFonts.outfit(
              color: isProfit ? Colors.greenAccent : Colors.redAccent,
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
          Divider(color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat(
                "Total Trades",
                controller.trades.length.toString(),
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
    final data = controller.cumulativePnlData;
    if (data.isEmpty) {
      return Center(
        child: Text(
          "No data for graph",
          style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.2)),
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
            color: isProfit ? Colors.greenAccent : Colors.redAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  (isProfit ? Colors.greenAccent : Colors.redAccent)
                      .withOpacity(0.2),
                  (isProfit ? Colors.greenAccent : Colors.redAccent)
                      .withOpacity(0),
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
            color: Colors.white.withOpacity(0.4),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildGlassStatCard(
            "Daily P&L",
            currencyFormat.format(controller.dailyPnl),
            controller.dailyPnl >= 0 ? Colors.greenAccent : Colors.redAccent,
            Icons.today_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGlassStatCard(
            "Max Drawdown",
            currencyFormat.format(controller.maxDrawdown),
            Colors.orangeAccent,
            Icons.warning_amber_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.5), size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinRateAnalyticsCard() {
    final currentWinRate = controller.currentMonthWinRate;
    final lastWinRate = controller.lastMonthWinRate;
    final diff = currentWinRate - lastWinRate;
    final isBetter = diff >= 0;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: currentWinRate / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  color: Colors.greenAccent,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                "${currentWinRate.toStringAsFixed(0)}%",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Win Rate Analytics",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isBetter
                      ? "Performing ${diff.abs().toStringAsFixed(0)}% better than last month"
                      : "Performing ${diff.abs().toStringAsFixed(0)}% lower than last month",
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTradesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Recent Performance",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: _showAllTradesModal,
          child: Text(
            "View All",
            style: GoogleFonts.outfit(
              color: Colors.greenAccent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showAllTradesModal() {
    final groupedTrades = _groupTradesByMonth();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Text(
              "Complete Trades",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: groupedTrades.keys.length,
                itemBuilder: (context, index) {
                  final month = groupedTrades.keys.elementAt(index);
                  final trades = groupedTrades[month]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          month,
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...trades.map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildTradeItem(t.symbol, t.date, t.pnl),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Map<String, List> _groupTradesByMonth() {
    final Map<String, List> grouped = {};
    for (var trade in controller.trades.reversed) {
      final month = DateFormat('MMMM yyyy').format(trade.date);
      if (!grouped.containsKey(month)) {
        grouped[month] = [];
      }
      grouped[month]!.add(trade);
    }
    return grouped;
  }

  Widget _buildRecentTradesList() {
    final recentTrades = controller.trades.reversed.take(5).toList();
    if (recentTrades.isEmpty) {
      return Center(
        child: Text(
          "No trades yet",
          style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.2)),
        ),
      );
    }
    return Column(
      children: recentTrades
          .map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTradeItem(t.symbol, t.date, t.pnl),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTradeItem(String title, DateTime date, double pnl) {
    final bool isProfit = pnl >= 0;
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isProfit ? Colors.greenAccent : Colors.redAccent)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isProfit
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: isProfit ? Colors.greenAccent : Colors.redAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormat('dd MMM, yyyy').format(date),
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(pnl),
            style: GoogleFonts.outfit(
              color: isProfit ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
