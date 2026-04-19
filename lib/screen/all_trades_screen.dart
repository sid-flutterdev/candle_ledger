import 'dart:ui';
import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/models/trade.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ScreenAllTrades extends StatefulWidget {
  const ScreenAllTrades({super.key});

  @override
  State<ScreenAllTrades> createState() => _ScreenAllTradesState();
}

class _ScreenAllTradesState extends State<ScreenAllTrades> {
  final TradeController tradeController = Get.find<TradeController>();
  final AccountController accountController = Get.find<AccountController>();

  final currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  Map<String, List<Trade>> _groupTradesByDate(List<Trade> trades) {
    final Map<String, List<Trade>> grouped = {};
    for (var trade in trades) {
      final dateStr = DateFormat('dd MMM yyyy').format(trade.date);
      grouped.putIfAbsent(dateStr, () => []);
      grouped[dateStr]!.add(trade);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "All Trades",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Filters Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_list_rounded,
                            color: Colors.white.withOpacity(0.6),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Filter",
                            style: GoogleFonts.outfit(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            color: Colors.white.withOpacity(0.6),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Sort",
                            style: GoogleFonts.outfit(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Trades List
            Expanded(
              child: Obx(() {
                if (tradeController.trades.isEmpty) {
                  return Center(
                    child: Text(
                      "No trades available",
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                final trades = tradeController.trades.toList();
                trades.sort((a, b) => b.date.compareTo(a.date));
                final grouped = _groupTradesByDate(trades);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final dateKey = grouped.keys.elementAt(index);
                    final dayTrades = grouped[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 12),
                          child: Text(
                            dateKey,
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        ...dayTrades.map((t) => _buildTradeCard(t)),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeCard(Trade t) {
    final isWin = t.pnl >= 0;
    final color = isWin ? Colors.greenAccent : Colors.redAccent;
    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
        ),
      ),
      confirmDismiss: (_) => _showDeleteTradeConfirmation(t),
      onDismissed: (_) async {
        await accountController.updateBalance(t.accountId, -t.pnl, false);
        await tradeController.deleteTrade(t.id);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
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
                      t.symbol,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${t.segment.name.capitalizeFirst} · ${DateFormat('dd MMM yyyy').format(t.date)}',
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
                    currencyFormat.format(t.pnl),
                    style: GoogleFonts.outfit(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Qty: ${t.quantity}',
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

  Future<bool?> _showDeleteTradeConfirmation(Trade t) {
    return Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orangeAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "Delete Trade?",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to delete this trade? This will also revert the balance. This action cannot be undone.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.outfit(color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Get.back(result: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
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
    );
  }
}
