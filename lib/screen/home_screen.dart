import 'dart:ui';

import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/controllers/user_controller.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/screen/profile_screen.dart';
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
  final UserController userController = Get.find<UserController>();

  final currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
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
                        _buildQuickStatsRow(),
                        const SizedBox(height: 24),
                        // _buildWinRateAnalyticsCard(),
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
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF1A1A1A),
                child: Icon(Icons.person_outline_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello,",
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  Obx(
                    () => Text(
                      userController.userName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildMainPnlCard() {
    final pnl = controller.currentMonthPnl;
    final isProfit = pnl >= 0;

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "MONTHLY NET P&L",
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(pnl),
            style: GoogleFonts.outfit(
              color: isProfit ? Colors.greenAccent : Colors.redAccent,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 100, child: _buildPnlGraph(isProfit)),
        ],
      ),
    );
  }

  Widget _buildPnlGraph(bool isProfit) {
    final data = controller.cumulativePnlData;

    if (data.isEmpty || data.length < 2) {
      return Center(
        child: Text(
          "No data",
          style: GoogleFonts.outfit(color: Colors.white24),
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
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
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
            Icons.today,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGlassStatCard(
            "Drawdown",
            currencyFormat.format(controller.maxDrawdown),
            Colors.orangeAccent,
            Icons.warning,
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
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: GoogleFonts.outfit(color: Colors.white54)),
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ FIXED BOTTOM SHEET
  void _showAllTradesModal() {
    final groupedTrades = _groupTradesByMonth();

    Get.bottomSheet(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: SizedBox(
          height: Get.height * 0.9,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: groupedTrades.isEmpty
                ? Center(
                    child: Text(
                      "No trades",
                      style: GoogleFonts.outfit(color: Colors.white),
                    ),
                  )
                : ListView(
                    children: groupedTrades.entries.map((entry) {
                      final trades = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: GoogleFonts.outfit(color: Colors.white54),
                          ),
                          ...trades.map(
                            (t) => ListTile(
                              title: Text(
                                t.symbol,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                DateFormat('dd MMM').format(t.date),
                                style: const TextStyle(color: Colors.white54),
                              ),
                              trailing: Text(
                                currencyFormat.format(t.pnl),
                                style: TextStyle(
                                  color: t.pnl >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ),
      ),
    );
  }

  /// ✅ FIXED TYPE
  Map<String, List<dynamic>> _groupTradesByMonth() {
    final Map<String, List<dynamic>> grouped = {};
    for (var trade in controller.trades) {
      final month = DateFormat('MMMM yyyy').format(trade.date);
      grouped.putIfAbsent(month, () => []);
      grouped[month]!.add(trade);
    }
    return grouped;
  }

  Widget _buildRecentTradesList() {
    final trades = controller.trades.reversed.take(5).toList();

    if (trades.isEmpty) {
      return Text(
        "No trades",
        style: GoogleFonts.outfit(color: Colors.white24),
      );
    }

    return Column(
      children: trades
          .map(
            (t) => ListTile(
              title: Text(
                t.symbol,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Text(
                currencyFormat.format(t.pnl),
                style: TextStyle(color: t.pnl >= 0 ? Colors.green : Colors.red),
              ),
            ),
          )
          .toList(),
    );
  }
}
