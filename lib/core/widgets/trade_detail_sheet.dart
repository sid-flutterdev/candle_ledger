import 'dart:ui';
import 'package:candle_ledger/core/constants/app_colors.dart';
import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/models/trade.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/screen/add_trade_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TradeDetailSheet extends StatelessWidget {
  final Trade trade;

  const TradeDetailSheet({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    final AccountController accountController = Get.find<AccountController>();
    final account = accountController.accounts.isEmpty
        ? null
        : accountController.accounts.firstWhere(
            (acc) => acc.id == trade.accountId,
            orElse: () => accountController.accounts.first,
          );

    final isWin = trade.pnl >= 0;
    final accentColor = isWin ? AppColors.profitGreen : AppColors.lossRed;
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    
    // Points calculation based on direction
    double points = trade.sellPrice - trade.buyPrice;
    if (trade.direction == TradeDirection.short) {
      points = trade.buyPrice - trade.sellPrice;
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
    
              // Header: Symbol and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trade.symbol,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${trade.segment.name.capitalizeFirst} Trade · ${account?.name ?? 'Unknown'}',
                        style: GoogleFonts.outfit(
                          color: accentColor.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.back();
                          Get.to(() => ScreenAddTrade(tradeToEdit: trade));
                        },
                        child: GlassContainer(
                          padding: const EdgeInsets.all(8),
                          borderRadius: 12,
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        borderRadius: 12,
                        child: Column(
                          children: [
                            Text(
                              DateFormat('dd MMM').format(trade.date),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat('yyyy').format(trade.date),
                              style: GoogleFonts.outfit(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
    
              // P&L and Points Card
              GlassContainer(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NET P&L',
                              style: GoogleFonts.outfit(
                                color: Colors.white38,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(trade.pnl),
                              style: GoogleFonts.outfit(
                                color: accentColor,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isWin
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                color: accentColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isWin ? 'PROFIT' : 'LOSS',
                                style: GoogleFonts.outfit(
                                  color: accentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(color: Colors.white.withValues(alpha: 0.05)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem("Points", "${points >= 0 ? '+' : ''}${points.toStringAsFixed(2)}", points >= 0 ? AppColors.profitGreen : AppColors.lossRed),
                        _buildSummaryItem("Charges", currencyFormat.format(trade.charges), Colors.orangeAccent),
                        _buildSummaryItem("R:R", trade.rrRatio, Colors.white70),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
    
              // Execution Details Grid
              Row(
                children: [
                  _buildInfoCell(
                    'Buy Price',
                    currencyFormat.format(trade.buyPrice),
                    Icons.add_circle_outline_rounded,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoCell(
                    'Sell Price',
                    currencyFormat.format(trade.sellPrice),
                    Icons.remove_circle_outline_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoCell('Quantity', trade.quantity.toString(), Icons.layers_outlined),
                  const SizedBox(width: 16),
                  _buildInfoCell(
                    'Direction',
                    trade.direction?.name.toUpperCase() ?? 'LONG',
                    trade.direction == TradeDirection.short ? Icons.south_rounded : Icons.north_rounded,
                    valueColor: trade.direction == TradeDirection.short ? AppColors.lossRed : AppColors.profitGreen,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Time & Segment row
              Row(
                children: [
                  _buildInfoCell(
                    'Time',
                    trade.startTime != null ? '${trade.startTime} - ${trade.endTime ?? '...'}' : 'Not Logged',
                    Icons.access_time_rounded,
                  ),
                  if (trade.segment == TradeSegment.options) ...[
                    const SizedBox(width: 16),
                    _buildInfoCell(
                      'Strike',
                      trade.script ?? 'N/A',
                      Icons.numbers_rounded,
                    ),
                  ] else if (trade.segment == TradeSegment.equity && trade.tradeType != null) ...[
                    const SizedBox(width: 16),
                    _buildInfoCell(
                      'Type',
                      trade.tradeType!.name.capitalizeFirst!,
                      Icons.category_outlined,
                    ),
                  ],
                ],
              ),
    
              const SizedBox(height: 32),
    
              // Notes Section
              Text(
                'NOTES',
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              GlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                child: Text(
                  (trade.note == null || trade.note!.isEmpty)
                      ? 'No notes added for this trade.'
                      : trade.note!,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoCell(String label, String value, IconData icon, {Color? valueColor}) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        borderRadius: 16,
        child: Row(
          children: [
            Icon(icon, color: Colors.white10, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: Colors.white24,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.outfit(
                      color: valueColor ?? Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
