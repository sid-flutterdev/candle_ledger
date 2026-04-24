import 'package:candle_ledger/core/constants/app_colors.dart';
import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/models/trade.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/trade_detail_sheet.dart';
import 'package:candle_ledger/screen/add_trade_screen.dart';
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
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
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
                    child: GestureDetector(
                      onTap: _showFilterSheet,
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
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Obx(() => Text(
                                  tradeController.allTradesSegmentFilter.value == "All" && 
                                  tradeController.allTradesResultFilter.value == "All"
                                      ? "Filter"
                                      : "Active",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showSortSheet,
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
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Sort",
                              style: GoogleFonts.outfit(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
                if (tradeController.sortedAndFilteredAllTrades.isEmpty) {
                  return Center(
                    child: Text(
                      "No trades found",
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                final trades = tradeController.sortedAndFilteredAllTrades;
                final sortType = tradeController.allTradesSortType.value;
                final isChronological = sortType == "Newest First" || sortType == "Oldest First";

                if (isChronological) {
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
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          GlassContainer(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                for (int i = 0; i < dayTrades.length; i++) ...[
                                  _buildTradeCard(dayTrades[i], isGrouped: true),
                                  if (i < dayTrades.length - 1)
                                    Divider(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      height: 1,
                                      indent: 16,
                                      endIndent: 16,
                                    ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: trades.length,
                  itemBuilder: (context, index) {
                    return _buildTradeCard(trades[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }  Widget _buildTradeCard(Trade t, {bool isGrouped = false}) {
    final isWin = t.pnl >= 0;
    final color = isWin ? AppColors.profitGreen : AppColors.lossRed;
    
    Widget cardContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isWin ? Icons.trending_up_rounded : Icons.trending_down_rounded,
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
                  '${accountController.accounts.firstWhere((a) => a.id == t.accountId, orElse: () => accountController.accounts.first).broker} · ${t.segment.name.capitalizeFirst!}',
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
    );

    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.15),
          borderRadius: isGrouped ? BorderRadius.zero : BorderRadius.circular(20),
        ),
        child: const Icon(Icons.edit, color: AppColors.secondary),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.lossRed.withValues(alpha: 0.2),
          borderRadius: isGrouped ? BorderRadius.zero : BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.lossRed,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          HapticFeedback.lightImpact();
          Get.to(() => ScreenAddTrade(tradeToEdit: t));
          return false;
        }
        return await _showDeleteTradeConfirmation(t);
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await accountController.updateBalance(t.accountId, t.pnl, true);
          await tradeController.deleteTrade(t.id);
        }
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Get.bottomSheet(
            TradeDetailSheet(trade: t),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          );
        },
        child: isGrouped 
          ? cardContent 
          : Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassContainer(
                padding: EdgeInsets.zero,
                child: cardContent,
              ),
            ),
      ),
    );
  }

  void _showSortSheet() {
    final sortOptions = ["Newest First", "Oldest First", "P&L High", "P&L Low"];

    Get.bottomSheet(
      GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sort By",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...sortOptions.map((option) {
              return Obx(() {
                final isSelected =
                    tradeController.allTradesSortType.value == option;
                return ListTile(
                  onTap: () {
                    tradeController.allTradesSortType.value = option;
                    Get.back();
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    option,
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.white)
                      : null,
                );
              });
            }),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void _showFilterSheet() {
    final segments = ["All", "Equity", "Options", "Futures"];
    final results = ["All", "Wins", "Losses"];

    Get.bottomSheet(
      GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filter Trades",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    tradeController.allTradesSortType.value = "Newest First";
                    tradeController.allTradesSegmentFilter.value = "All";
                    tradeController.allTradesResultFilter.value = "All";
                    tradeController.allTradesAccountFilter.value = "All";
                    Get.back();
                  },
                  child: Text(
                    "Reset",
                    style: GoogleFonts.outfit(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "BROKER ACCOUNT",
              style: GoogleFonts.outfit(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Obx(() {
                    final isSelected = tradeController.allTradesAccountFilter.value == "All";
                    return _buildFilterChip(
                      "All",
                      isSelected,
                      () => tradeController.allTradesAccountFilter.value = "All",
                    );
                  }),
                  ...accountController.accounts.map((acc) {
                    return Obx(() {
                      final isSelected = tradeController.allTradesAccountFilter.value == acc.id;
                      return _buildFilterChip(
                        acc.broker,
                        isSelected,
                        () => tradeController.allTradesAccountFilter.value = acc.id!,
                      );
                    });
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "SEGMENT",
              style: GoogleFonts.outfit(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: segments.map((s) {
                return Obx(() {
                  final isSelected =
                      tradeController.allTradesSegmentFilter.value == s;
                  return _buildFilterChip(
                    s,
                    isSelected,
                    () => tradeController.allTradesSegmentFilter.value = s,
                  );
                });
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              "RESULT",
              style: GoogleFonts.outfit(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: results.map((r) {
                return Obx(() {
                  final isSelected =
                      tradeController.allTradesResultFilter.value == r;
                  Color? selectedColor;
                  if (r == "Wins") selectedColor = AppColors.profitGreen;
                  if (r == "Losses") selectedColor = AppColors.lossRed;

                  return _buildFilterChip(
                    r,
                    isSelected,
                    () => tradeController.allTradesResultFilter.value = r,
                    activeColor: selectedColor,
                  );
                });
              }).toList(),
            ),
            const SizedBox(height: 30),
            GlassButton(
              onPressed: () => Get.back(),
              color: Colors.white.withValues(alpha: 0.1),
              child: Center(
                child: Text(
                  "APPLY FILTERS",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, {Color? activeColor}) {
    final color = activeColor ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? color : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
