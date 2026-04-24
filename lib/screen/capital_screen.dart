import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/models/account.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/screen/account/account_detail_screen.dart';
import 'package:candle_ledger/screen/account/add_account_model.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ScreenCapital extends StatefulWidget {
  const ScreenCapital({super.key});

  @override
  State<ScreenCapital> createState() => _ScreenCapitalState();
}

class _ScreenCapitalState extends State<ScreenCapital> {
  final AccountController controller = Get.find<AccountController>();
  final currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  final List<IconData> _icons = [
    Icons.account_balance_wallet_rounded,
    Icons.account_balance_rounded,
    Icons.show_chart_rounded,
    Icons.currency_bitcoin_rounded,
    Icons.language_rounded,
    Icons.pie_chart_rounded,
  ];

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
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildTotalCapitalCard(),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Accounts",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const AddAccountModal(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          "Create Account",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (controller.accounts.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.accounts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final account = controller.accounts[index];
                        return _buildAccountTile(account, index);
                      },
                    ),
                  const SizedBox(height: 100), // Space for FAB/BottomNav
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.white.withValues(alpha: 0.2),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            "No accounts added yet",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Click the + button to add your first trading account",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCapitalCard() {
    final tradeController = Get.find<TradeController>();
    final currentMonthPnl = tradeController.currentMonthPnl;
    final isProfit = currentMonthPnl >= 0;
    final totalAssets = controller.totalAssets;

    // Simple calculation for percentage
    final startingAssets = totalAssets - currentMonthPnl;
    double percentage = 0.0;
    if (startingAssets > 0) {
      percentage = (currentMonthPnl / startingAssets) * 100;
    } else if (totalAssets > 0) {
      // Edge case where starting balance was 0 but PnL exists
      percentage = 100.0;
    }

    final pnlFormatted = currencyFormat.format(currentMonthPnl.abs());
    final percentFormatted = percentage.abs().toStringAsFixed(1);
    final sign = isProfit ? '+' : '-';

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TOTAL CAPITAL",
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            currencyFormat.format(totalAssets),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                isProfit
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: isProfit ? Colors.greenAccent : Colors.redAccent,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                "$sign$pnlFormatted ($percentFormatted%)",
                style: GoogleFonts.outfit(
                  color: isProfit ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "this month",
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value, {
    Color? valueColor,
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: valueColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTile(Account account, int index) {
    final tradeController = Get.find<TradeController>();
    final accountTrades = tradeController.trades
        .where((t) => t.accountId == account.id)
        .toList();

    final year = DateTime.now().year;
    final yearlyPnl = accountTrades
        .where((t) => t.date.year == year)
        .fold(0.0, (s, t) => s + t.pnl);

    final totalTradesCount = accountTrades.length;
    final isYearProfit = yearlyPnl >= 0;

    return Dismissible(
      key: Key(account.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.edit, color: Colors.blueAccent),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          HapticFeedback.lightImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddAccountModal(accountToEdit: account),
          );
          return false;
        }
        return await _showDeleteConfirmation(account);
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          controller.deleteAccount(account.id);
        }
      },
      child: GestureDetector(
        onTap: () => Get.to(
          () => AccountDetailScreen(account: account, accountIndex: index),
          transition: Transition.rightToLeftWithFade,
        ),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(account.colorHex).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _icons[account.iconIndex],
                      color: Color(account.colorHex),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.broker,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (account.name != account.broker)
                          Text(
                            account.name,
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.4),
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
                        currencyFormat.format(account.liquidBalance),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat(
                    'Yearly P&L ($year)',
                    currencyFormat.format(yearlyPnl),
                    valueColor: isYearProfit
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                  _buildMiniStat(
                    'Total Trades',
                    '$totalTradesCount',
                    alignment: CrossAxisAlignment.end,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(Account account) {
    return Get.dialog<bool>(
      Material(
        type: MaterialType.transparency,
        child: Center(
          child: GlassContainer(
            width: Get.width * 0.85,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.redAccent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Delete Account?",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: "Are you sure you want to delete "),
                      TextSpan(
                        text: "'${account.name}'",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: "?\n\n"),
                      const TextSpan(
                        text:
                            "This will also delete EVERY trade added under this account. This action cannot be undone.",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(result: false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
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
                          backgroundColor: Colors.redAccent.withValues(
                            alpha: 0.8,
                          ),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
      ),
      barrierColor: Colors.black.withValues(alpha: 0.8),
    );
  }
}
