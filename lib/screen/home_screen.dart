import 'dart:ui';
import 'package:candle_ledger/core/constants/app_colors.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:candle_ledger/screen/explore_screen.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  final double pnl = 3200.50; 
  String selectedAsset = 'Stocks';

  @override
  Widget build(BuildContext context) {
    final bool isProfit = pnl >= 0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                /// 🔥 TOP BAR
                _buildTopBar(),

                const SizedBox(height: 30),

                /// 🔥 MAIN DASHBOARD
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildMainPortfolioCard(isProfit),
                        const SizedBox(height: 24),
                        _buildQuickStatsRow(),
                        const SizedBox(height: 24),
                        _buildWinRateCard(),
                        const SizedBox(height: 24),
                        _buildRecentTradesHeader(),
                        const SizedBox(height: 16),
                        _buildRecentTradesList(),
                        const SizedBox(height: 24),
                        _buildRiskManagement(),
                        const SizedBox(height: 30),
                      ],
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 2),
              ),
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3"),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello,",
                  style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
                Text(
                  "Sidharth",
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
        Row(
          children: [
            _buildIconButton(Icons.notifications_none_rounded, () {}),
            const SizedBox(width: 12),
            _buildIconButton(Icons.settings_outlined, () => Get.to(() => const ScreenExplore())),
          ],
        ),
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

  Widget _buildMainPortfolioCard(bool isProfit) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                    "₹ ${pnl.toStringAsFixed(2)}",
                    style: GoogleFonts.outfit(
                      color: isProfit ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isProfit ? Colors.greenAccent : Colors.redAccent).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isProfit ? "+12.5%" : "-5.2%",
                  style: GoogleFonts.outfit(
                    color: isProfit ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 80,
            width: double.infinity,
            child: CustomPaint(
              painter: _ChartPainter(isProfit: isProfit),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat("Trades", "128", Icons.swap_horiz_rounded),
              _buildMiniStat("Win Rate", "68%", Icons.bolt_rounded),
              _buildMiniStat("Profit Factor", "2.4", Icons.trending_up_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.3), size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 10),
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
            "+₹450",
            Colors.greenAccent,
            Icons.today_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGlassStatCard(
            "Max Drawdown",
            "-₹1,200",
            Colors.redAccent,
            Icons.warning_amber_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassStatCard(String label, String value, Color color, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.5), size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(color: color, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWinRateCard() {
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
                  value: 0.68,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  color: Colors.greenAccent,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                "68%",
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "You're performing 12% better than last week",
                  style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12),
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
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          "View All",
          style: GoogleFonts.outfit(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildRecentTradesList() {
    return Column(
      children: [
        _buildTradeItem("NIFTY 50", "Intraday", "+₹2,400", true),
        const SizedBox(height: 12),
        _buildTradeItem("RELIANCE", "Swing", "-₹800", false),
        const SizedBox(height: 12),
        _buildTradeItem("BANKNIFTY", "Scalp", "+₹3,200", true),
      ],
    );
  }

  Widget _buildTradeItem(String title, String type, String amount, bool isProfit) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isProfit ? Colors.greenAccent : Colors.redAccent).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
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
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  type,
                  style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
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

  Widget _buildRiskManagement() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Risk Management",
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRiskIndicator("Daily Limit", "₹5,000", 0.4, Colors.orangeAccent),
              _buildRiskIndicator("Max Loss", "₹1,500", 0.8, Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 120,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.05),
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final bool isProfit;
  _ChartPainter({required this.isProfit});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isProfit ? Colors.greenAccent : Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);

    final random = math.Random(42);
    for (var i = 1; i <= 10; i++) {
      path.lineTo(
        size.width * (i / 10),
        size.height * (0.3 + random.nextDouble() * 0.6),
      );
    }

    // Add shadow
    canvas.drawPath(path, paint);
    
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isProfit ? Colors.greenAccent : Colors.redAccent).withOpacity(0.2),
          (isProfit ? Colors.greenAccent : Colors.redAccent).withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, gradientPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
