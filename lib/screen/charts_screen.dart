import 'dart:ui';
import 'package:flutter/material.dart';

class ScreenCharts extends StatefulWidget {
  const ScreenCharts({super.key});

  @override
  State<ScreenCharts> createState() => _ScreenChartsState();
}

class _ScreenChartsState extends State<ScreenCharts> {
  int selectedPeriod = 0; // 0=Week, 1=Month, 2=Year, 3=Custom
  final List<String> periods = ['Week', 'Month', 'Year', 'Custom'];

  // Simulated week navigation
  int weekOffset = 0;

  String get dateRangeLabel {
    // For demo: show a shifting week range based on offset
    final now = DateTime.now();
    final start = now.subtract(
      Duration(days: now.weekday - 1 + (weekOffset * 7) * -1),
    );
    final end = start.add(const Duration(days: 6));

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (weekOffset == 0) {
      return '${start.day} ${months[start.month - 1]} – ${end.day} ${months[end.month - 1]}';
    } else if (weekOffset < 0) {
      final s = start.subtract(Duration(days: weekOffset.abs() * 7));
      final e = s.add(const Duration(days: 6));
      return '${s.day} ${months[s.month - 1]} – ${e.day} ${months[e.month - 1]}';
    } else {
      final s = start.add(Duration(days: weekOffset * 7));
      final e = s.add(const Duration(days: 6));
      return '${s.day} ${months[s.month - 1]} – ${e.day} ${months[e.month - 1]}';
    }
  }

  // Demo P&L data per period
  final double profit = 0;
  final double loss = 0;
  final int trades = 0;
  double get netPnl => profit - loss;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              /// TITLE
              const Text(
                "Analysis",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// PERIOD SELECTOR
              _PeriodSelector(
                periods: periods,
                selectedIndex: selectedPeriod,
                onSelect: (i) => setState(() => selectedPeriod = i),
              ),

              const SizedBox(height: 16),

              /// DATE RANGE NAVIGATOR (shown only for Week/Month/Year)
              if (selectedPeriod != 3)
                _DateNavigator(
                  label: dateRangeLabel,
                  onPrev: () => setState(() => weekOffset--),
                  onNext: () => setState(() => weekOffset++),
                ),

              const SizedBox(height: 16),

              /// NET P&L CARD
              _NetPnlCard(
                netPnl: netPnl,
                profit: profit,
                loss: loss,
                trades: trades,
              ),

              const SizedBox(height: 16),

              /// PLACEHOLDER for chart area
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: const Center(
                      child: Text(
                        "Chart Coming Soon",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              /// TRADING SUMMARY
              const Text(
                "Trading Summary",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              _TradingSummaryCard(
                totalTrades: trades,
                winRate: 0.0,
                totalWin: profit,
                totalLoss: loss,
                avgWin: 0.0,
                avgLoss: 0.0,
                maxDrawdown: 0.0,
              ),

              const SizedBox(height: 28),

              /// DETAILED REPORTS
              const Text(
                "Detailed Reports",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              _DetailedReportsGrid(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── PERIOD SELECTOR ───────────────────────────────────────────────────────
class _PeriodSelector extends StatelessWidget {
  final List<String> periods;
  final int selectedIndex;
  final Function(int) onSelect;

  const _PeriodSelector({
    required this.periods,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF161C2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: List.generate(periods.length, (i) {
          final isSelected = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2A2F3E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  periods[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// ─── DATE NAVIGATOR ────────────────────────────────────────────────────────
class _DateNavigator extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _DateNavigator({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161C2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavArrow(icon: Icons.chevron_left, onTap: onPrev),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          _NavArrow(icon: Icons.chevron_right, onTap: onNext),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

/// ─── NET P&L CARD ──────────────────────────────────────────────────────────
class _NetPnlCard extends StatelessWidget {
  final double netPnl;
  final double profit;
  final double loss;
  final int trades;

  const _NetPnlCard({
    required this.netPnl,
    required this.profit,
    required this.loss,
    required this.trades,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = netPnl >= 0;
    final pnlColor = isProfit ? const Color(0xFF00C853) : Colors.red;
    final sign = isProfit ? '+' : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isProfit ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isProfit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            ),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "NET P&L",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          /// BIG P&L NUMBER
          Center(
            child: Text(
              '$sign₹${netPnl.abs().toStringAsFixed(0)}',
              style: TextStyle(
                color: pnlColor,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Divider(color: Colors.white.withOpacity(0.08)),

          const SizedBox(height: 12),

          /// STATS ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PnlStat(
                title: "PROFIT",
                value: "₹${profit.toStringAsFixed(0)}",
                valueColor: const Color(0xFF00C853),
              ),
              _PnlStat(
                title: "TRADES",
                value: "$trades",
                valueColor: Colors.white,
              ),
              _PnlStat(
                title: "LOSS",
                value: "₹${loss.toStringAsFixed(0)}",
                valueColor: Colors.red,
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

class _PnlStat extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _PnlStat({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// ─── TRADING SUMMARY CARD ──────────────────────────────────────────────────
class _TradingSummaryCard extends StatelessWidget {
  final int totalTrades;
  final double winRate;
  final double totalWin;
  final double totalLoss;
  final double avgWin;
  final double avgLoss;
  final double maxDrawdown;

  const _TradingSummaryCard({
    required this.totalTrades,
    required this.winRate,
    required this.totalWin,
    required this.totalLoss,
    required this.avgWin,
    required this.avgLoss,
    required this.maxDrawdown,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
      child: Column(
        children: [
          _SummaryRow(
            label: "Total Trades",
            value: "$totalTrades",
            valueColor: Colors.white,
            isFirst: true,
          ),
          _SummaryRow(
            label: "Win Rate (%)",
            value: "${winRate.toStringAsFixed(1)}%",
            valueColor: const Color(0xFF00C853),
          ),
          _SummaryRow(
            label: "Total Win",
            value: "+₹${totalWin.toStringAsFixed(0)}",
            valueColor: const Color(0xFF00C853),
          ),
          _SummaryRow(
            label: "Total Loss",
            value: "-₹${totalLoss.toStringAsFixed(0)}",
            valueColor: Colors.red,
          ),
          _SummaryRow(
            label: "Average Win",
            value: "₹${avgWin.toStringAsFixed(0)}",
            valueColor: const Color(0xFF00C853),
          ),
          _SummaryRow(
            label: "Average Loss",
            value: "₹${avgLoss.toStringAsFixed(0)}",
            valueColor: Colors.red,
          ),
          _SummaryRow(
            label: "Max Drawdown",
            value: "₹${maxDrawdown.toStringAsFixed(0)}",
            valueColor: Colors.red,
            isLast: true,
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool isFirst;
  final bool isLast;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isFirst)
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.06),
            indent: 16,
            endIndent: 16,
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ─── DETAILED REPORTS GRID ─────────────────────────────────────────────────
class _DetailedReportsGrid extends StatelessWidget {
  const _DetailedReportsGrid();

  @override
  Widget build(BuildContext context) {
    final reports = [
      {'label': 'Weekly', 'icon': Icons.calendar_view_week},
      {'label': 'Monthly', 'icon': Icons.calendar_month},
      {'label': 'Quarterly', 'icon': Icons.bar_chart},
      {'label': 'Yearly', 'icon': Icons.calendar_today},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.8,
      children: reports.map((r) {
        return GestureDetector(
          onTap: () {
            // TODO: Navigate to detailed report
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(r['icon'] as IconData, color: Colors.white54, size: 18),
                const SizedBox(width: 8),
                Text(
                  r['label'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
