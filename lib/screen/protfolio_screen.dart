import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenPortfolio extends StatefulWidget {
  const ScreenPortfolio({super.key});

  @override
  State<ScreenPortfolio> createState() => _ScreenPortfolioState();
}

class _ScreenPortfolioState extends State<ScreenPortfolio> {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Capital",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildAddAccountButton(),
                  ],
                ),
                const SizedBox(height: 30),
                _buildTotalCapitalCard(),
                const SizedBox(height: 30),
                Text(
                  "My Accounts",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAccountTile("Zerodha", "₹4,50,000", Colors.blueAccent),
                const SizedBox(height: 12),
                _buildAccountTile("Angel One", "₹2,30,000", Colors.orangeAccent),
                const SizedBox(height: 12),
                _buildAccountTile("Forex", "₹1,25,000", Colors.purpleAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddAccountButton() {
    return GlassContainer(
      width: 44,
      height: 44,
      borderRadius: 12,
      padding: EdgeInsets.zero,
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
    );
  }

  Widget _buildTotalCapitalCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TOTAL ASSETS",
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "₹8,05,000",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.arrow_upward_rounded, color: Colors.greenAccent, size: 16),
              const SizedBox(width: 4),
              Text(
                "+₹15,200 (2.4%)",
                style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                "this month",
                style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat("Liquid", "₹2,50k"),
              _buildMiniStat("Invested", "₹5,55k"),
              _buildMiniStat("Allocated", "70%"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildAccountTile(String name, String balance, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.account_balance_wallet_rounded, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Active Account",
                  style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            balance,
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
