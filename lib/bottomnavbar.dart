import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:flutter/material.dart';

class GlassBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const GlassBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GlassContainer(
        height: 75,
        borderRadius: 25,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.dashboard_rounded, "Home", 0),
            _navItem(Icons.bar_chart_rounded, "Charts", 1),
            const SizedBox(width: 40), // FAB Space
            _navItem(Icons.account_balance_wallet_rounded, "Assets", 3),
            _navItem(Icons.explore_rounded, "Explore", 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.greenAccent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.greenAccent : Colors.white.withOpacity(0.4),
              size: 24,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.top(4),
                height: 4,
                width: 4,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
