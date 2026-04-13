import 'package:candle_ledger/bottomnavbar.dart';
import 'package:candle_ledger/screen/add_screen.dart';
import 'package:candle_ledger/screen/charts_screen.dart';
import 'package:candle_ledger/screen/home_screen.dart';
import 'package:candle_ledger/screen/more_screen.dart';
import 'package:candle_ledger/screen/protfolio_screen.dart';
import 'package:flutter/material.dart';

class ScreenMain extends StatefulWidget {
  const ScreenMain({super.key});

  @override
  State<ScreenMain> createState() => _ScreenMainState();
}

class _ScreenMainState extends State<ScreenMain> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const ScreenHome(),
    const ScreenCharts(),
    const ScreenAdd(),
    const ScreenPortfolio(),
    const ScreenMore(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),

      /// BODY
      body: pages[selectedIndex],

      /// CENTER ADD BUTTON (LOWERED)
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 18), // 👈 lowered here
        child: GestureDetector(
          onTap: () => onItemTapped(2),
          child: Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 15),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.black, size: 32),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// GLASS NAV BAR
      bottomNavigationBar: GlassBottomNavBar(
        selectedIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
