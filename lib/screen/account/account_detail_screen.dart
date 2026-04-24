import 'dart:ui';
import 'package:candle_ledger/core/constants/app_colors.dart';
import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/controllers/transaction_controller.dart';
import 'package:candle_ledger/core/models/account.dart';
import 'package:candle_ledger/core/models/trade.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:candle_ledger/core/widgets/app_snackbar.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/trade_detail_sheet.dart';
import 'package:candle_ledger/screen/account/add_account_model.dart';
import 'package:candle_ledger/screen/add_trade_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AccountDetailScreen extends StatefulWidget {
  final Account account;
  final int accountIndex;
  const AccountDetailScreen({
    super.key,
    required this.account,
    required this.accountIndex,
  });

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  final AccountController accountController = Get.find<AccountController>();
  final TradeController tradeController = Get.find<TradeController>();
  final TransactionController txController = Get.find<TransactionController>();

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

  final List<Color> _colors = [
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.cyanAccent,
    Colors.pinkAccent,
    Colors.tealAccent,
    Colors.amberAccent,
    Colors.indigoAccent,
    Colors.limeAccent,
    Colors.deepOrangeAccent,
    Colors.deepPurpleAccent,
    Colors.yellowAccent,
  ];

  Account get _account =>
      accountController.accounts.firstWhereOrNull(
        (a) => a.id == widget.account.id,
      ) ??
      widget.account;

  List<Trade> get _trades => tradeController.trades
      .where((t) => t.accountId == widget.account.id)
      .toList();

  double get _yearlyPnl {
    final year = DateTime.now().year;
    return _trades
        .where((t) => t.date.year == year)
        .fold(0.0, (s, t) => s + t.pnl);
  }

  List<AccountTransaction> get _txHistory {
    final list = txController.forAccount(widget.account.id);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<Trade> get _sortedTrades {
    final list = List<Trade>.from(_trades);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        final account = _account;
        final accentColor = Color(account.colorHex);

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(account, accentColor),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildSummaryCard(account, accentColor),
                      const SizedBox(height: 14),
                      _buildFundsRow(account),
                      const SizedBox(height: 28),
                      _buildTransactionHistoryCard(),
                      const SizedBox(height: 20),
                      _buildTradeHistoryCard(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(Account account, Color accentColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: GlassContainer(
                  width: 40,
                  height: 40,
                  borderRadius: 10,
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        AddAccountModal(accountToEdit: account),
                  );
                },
                child: GlassContainer(
                  width: 40,
                  height: 40,
                  borderRadius: 10,
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _icons[account.iconIndex],
                  color: accentColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.broker,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (account.name != account.broker)
                    Text(
                      account.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Account account, Color accentColor) {
    final yearlyPnl = _yearlyPnl;
    final isYearProfit = yearlyPnl >= 0;
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Centered "TOTAL BALANCE" label
          Text(
            'TOTAL BALANCE',
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          // Big centered balance amount
          Text(
            currencyFormat.format(account.liquidBalance),
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.07)),
          const SizedBox(height: 14),
          // Below divider: Yearly P&L | separator | Total Trades
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statCell(
                'Yearly P&L (${DateTime.now().year})',
                currencyFormat.format(yearlyPnl),
                isYearProfit ? AppColors.profitGreen : AppColors.lossRed,
                isYearProfit
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
              ),
              Container(
                width: 1,
                height: 48,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              _statCell(
                'Total Trades',
                '${_trades.length}',
                accentColor,
                Icons.swap_horiz_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCell(
    String label,
    String value,
    Color valueColor,
    IconData icon, {
    bool fullWidth = false,
  }) {
    final cell = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: valueColor.withValues(alpha: 0.6), size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
    return fullWidth ? cell : Expanded(child: cell);
  }

  Widget _buildFundsRow(Account account) {
    return Row(
      children: [
        Expanded(
          child: _fundButton(
            'Deposit',
            Icons.add_circle_outline_rounded,
            Colors.greenAccent,
            () => _showFundsModal(account, isDeposit: true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _fundButton(
            'Withdrawal',
            Icons.remove_circle_outline_rounded,
            Colors.orangeAccent,
            () => _showFundsModal(account, isDeposit: false),
          ),
        ),
      ],
    );
  }

  Widget _fundButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onViewAll != null)
          ElevatedButton(
            onPressed: onViewAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'View All',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionHistoryCard() {
    final txList = _txHistory;
    final preview = txList.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Transaction History',
          onViewAll: () => _showAllTxModal(txList),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: txList.isEmpty
              ? _buildEmptyRow('No deposits or withdrawals yet')
              : Column(
                  children: preview
                      .map((tx) => _buildTxCard(tx.type, tx))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildTradeHistoryCard() {
    final tradeList = _sortedTrades;
    final preview = tradeList.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Trade History',
          onViewAll: () => _showAllTradesModal(tradeList),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: tradeList.isEmpty
              ? _buildEmptyRow('No trades recorded yet')
              : Column(
                  children: preview.map((t) => _buildTradeCard(t)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyRow(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.outfit(color: Colors.white24, fontSize: 14),
        ),
      ),
    );
  }

  void _showAllTxModal(List<AccountTransaction> txList) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 20),
            Text(
              'All Transactions',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: txList
                    .map((tx) => _buildTxCard(tx.type, tx))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void _showAllTradesModal(List<Trade> tradeList) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 20),
            Text(
              'All Trades',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: tradeList.map((t) => _buildTradeCard(t)).toList(),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildTradeCard(Trade t) {
    final isWin = t.pnl >= 0;
    final color = isWin ? AppColors.profitGreen : AppColors.lossRed;
    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.edit, color: AppColors.secondary),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.lossRed.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
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
                    color: color.withValues(alpha: 0.1),
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
      ),
    );
  }

  Widget _buildTxCard(String type, AccountTransaction tx) {
    final isDeposit = type == 'deposit';
    final color = isDeposit ? AppColors.profitGreen : Colors.orangeAccent;
    final icon = isDeposit
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
    final label = isDeposit ? 'Deposit' : 'Withdrawal';

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.lossRed.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.lossRed,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          HapticFeedback.lightImpact();
          _showFundsModal(
            accountController.accounts.firstWhere((a) => a.id == tx.accountId),
            isDeposit: tx.type == 'deposit',
            txToEdit: tx,
          );
          return false;
        }
        return await _showDeleteTxConfirmation(tx);
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          if (isDeposit) {
            await accountController.addWithdrawal(tx.accountId, tx.amount);
          } else {
            await accountController.addDeposit(tx.accountId, tx.amount);
          }
          await txController.deleteTransaction(tx.id);
        }
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy · hh:mm a').format(tx.date),
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    if (tx.note != null && tx.note!.isNotEmpty)
                      Text(
                        tx.note!,
                        style: GoogleFonts.outfit(
                          color: Colors.white24,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${isDeposit ? '+' : '-'}${currencyFormat.format(tx.amount)}',
                style: GoogleFonts.outfit(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Funds Modal ─────────────────────────────────────────────────────────────

  void _showFundsModal(Account account, {required bool isDeposit, AccountTransaction? txToEdit}) {
    final amountCtrl = TextEditingController(
      text: txToEdit != null ? txToEdit.amount.toString() : '',
    );
    final noteCtrl = TextEditingController(
      text: txToEdit != null ? txToEdit.note ?? '' : '',
    );
    final color = isDeposit ? Colors.greenAccent : Colors.orangeAccent;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  txToEdit != null 
                    ? (isDeposit ? 'Edit Deposit' : 'Edit Withdrawal')
                    : (isDeposit ? 'Add Deposit' : 'Record Withdrawal'),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isDeposit
                      ? 'Enter the amount deposited into ${account.name}'
                      : 'Enter the amount withdrawn from ${account.name}',
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                // Amount field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: TextField(
                    controller: amountCtrl,
                    autofocus: txToEdit == null,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixText: '₹ ',
                      prefixStyle: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 20,
                      ),
                      hintText: '0',
                      hintStyle: GoogleFonts.outfit(
                        color: Colors.white24,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Note field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: TextField(
                    controller: noteCtrl,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Note (optional)',
                      hintStyle: GoogleFonts.outfit(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GlassButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountCtrl.text) ?? 0;
                    if (amount <= 0) {
                      AppSnackbar.error("Error", "Please enter an amount");
                      return;
                    }
                    if (!isDeposit && amount > account.liquidBalance + (txToEdit?.amount ?? 0)) {
                      AppSnackbar.error(
                        'Insufficient Funds',
                        'Withdrawal exceeds available balance',
                      );
                      return;
                    }

                    if (txToEdit != null) {
                      // Edit existing
                      final diff = amount - txToEdit.amount;
                      if (diff != 0) {
                        if (isDeposit) {
                          await accountController.addDeposit(account.id, diff);
                        } else {
                          await accountController.addWithdrawal(account.id, diff);
                        }
                      }
                      
                      final updatedTx = AccountTransaction(
                        id: txToEdit.id,
                        accountId: txToEdit.accountId,
                        type: txToEdit.type,
                        amount: amount,
                        date: txToEdit.date,
                        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                      );
                      await txController.updateTransaction(updatedTx);
                    } else {
                      // Add new
                      if (isDeposit) {
                        await accountController.addDeposit(account.id, amount);
                      } else {
                        await accountController.addWithdrawal(account.id, amount);
                      }
                      await txController.addTransaction(
                        accountId: account.id,
                        type: isDeposit ? 'deposit' : 'withdrawal',
                        amount: amount,
                        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                      );
                    }

                    Get.back();
                    AppSnackbar.success(
                      txToEdit != null ? 'Transaction Updated' : (isDeposit ? 'Deposit Added' : 'Withdrawal Recorded'),
                      txToEdit != null 
                        ? 'Changes saved successfully'
                        : '${currencyFormat.format(amount)} ${isDeposit ? 'added to' : 'withdrawn from'} ${account.name}',
                    );
                  },
                  color: color.withValues(alpha: 0.12),
                  child: Text(
                    txToEdit != null ? 'SAVE CHANGES' : (isDeposit ? 'CONFIRM DEPOSIT' : 'CONFIRM WITHDRAWAL'),
                    style: GoogleFonts.outfit(
                      color: color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Edit Modal ───────────────────────────────────────────────────────────────

  Future<bool?> _showDeleteTradeConfirmation(Trade t) {
    return _showConfirmationDialog(
      title: "Delete Trade?",
      content:
          "Are you sure you want to delete this trade? This will also revert the balance. This action cannot be undone.",
    );
  }

  Future<bool?> _showDeleteTxConfirmation(AccountTransaction tx) {
    final label = tx.type == 'deposit' ? 'Deposit' : 'Withdrawal';
    return _showConfirmationDialog(
      title: "Delete $label?",
      content:
          "Are you sure you want to delete this ${tx.type}? This will also reverse the balance change. This action cannot be undone.",
    );
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
  }) {
    return Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
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
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
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
    );
  }
}
