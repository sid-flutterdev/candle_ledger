import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenExplore extends StatefulWidget {
  const ScreenExplore({super.key});

  @override
  State<ScreenExplore> createState() => _ScreenExploreState();
}

class _ScreenExploreState extends State<ScreenExplore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.black),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Explore",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Tools, learning & community",
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                _buildPremiumBanner(),
                const SizedBox(height: 30),
                _buildQuickToolsRow(),
                const SizedBox(height: 30),
                Text(
                  "Trading Education",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildEducationGrid(),
                const SizedBox(height: 30),
                Text(
                  "Market Insights",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInsightTile("Market Psychology", "Master your trading mind", Icons.psychology_rounded, Colors.purpleAccent),
                const SizedBox(height: 12),
                _buildInsightTile("Technical Analysis", "Advanced chart patterns", Icons.analytics_rounded, Colors.blueAccent),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      color: Colors.amber.withOpacity(0.05),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Go Premium",
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Unlock advanced risk analytics",
                  style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
        ],
      ),
    );
  }

  Widget _buildQuickToolsRow() {
    return Row(
      children: [
        _buildToolItem(Icons.rule_rounded, "Rules", Colors.greenAccent),
        const SizedBox(width: 12),
        _buildToolItem(Icons.track_changes_rounded, "Goals", Colors.blueAccent),
        const SizedBox(width: 12),
        _buildToolItem(Icons.calculate_rounded, "Calc", Colors.orangeAccent),
        const SizedBox(width: 12),
        _buildToolItem(Icons.history_rounded, "Backtest", Colors.redAccent),
      ],
    );
  }

  Widget _buildToolItem(IconData icon, String label, Color color) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildEduCard("Basics", "12 Lessons", Icons.menu_book_rounded, Colors.tealAccent),
        _buildEduCard("Advanced", "8 Lessons", Icons.stars_rounded, Colors.indigoAccent),
        _buildEduCard("Strategies", "15 Setups", Icons.lightbulb_rounded, Colors.orangeAccent),
        _buildEduCard("Risk Mgmt", "5 Guides", Icons.security_rounded, Colors.redAccent),
      ],
    );
  }

  Widget _buildEduCard(String title, String subtitle, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.5), size: 20),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            subtitle,
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightTile(String title, String subtitle, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
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
          const Icon(Icons.play_circle_outline_rounded, color: Colors.white24),
        ],
      ),
    );
  }
}
