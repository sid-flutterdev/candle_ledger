import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenCharts extends StatefulWidget {
  const ScreenCharts({super.key});

  @override
  State<ScreenCharts> createState() => _ScreenChartsState();
}

class _ScreenChartsState extends State<ScreenCharts> {
  int selectedPeriod = 0; 
  final List<String> periods = ['Week', 'Month', 'Year', 'Custom'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.black),
        child: SafeArea(
          child: SingleChildScrollView(
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
                const SizedBox(height: 30),
                _buildMainChartCard(),
                const SizedBox(height: 24),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildReportSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return GlassContainer(
      padding: const EdgeInsets.all(6),
      borderRadius: 16,
      child: Row(
        children: List.generate(periods.length, (index) {
          bool isSelected = selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedPeriod = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.greenAccent.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  periods[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.greenAccent : Colors.white.withOpacity(0.4),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMainChartCard() {
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
                    "PERFORMANCE",
                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "+₹12,450.00",
                    style: GoogleFonts.outfit(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Icon(Icons.show_chart_rounded, color: Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.greenAccent.withOpacity(0.1), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Icon(Icons.auto_graph_rounded, color: Colors.white10, size: 60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem("Best Trade", "+₹4,200", Colors.greenAccent),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem("Worst Trade", "-₹1,100", Colors.redAccent),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Detailed Reports",
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildReportTile("Trade Distribution", "Analyze your trade types", Icons.pie_chart_outline_rounded),
        const SizedBox(height: 12),
        _buildReportTile("Time Analysis", "Best time to trade for you", Icons.timer_outlined),
      ],
    );
  }

  Widget _buildReportTile(String title, String subtitle, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white30),
        ],
      ),
    );
  }
}
