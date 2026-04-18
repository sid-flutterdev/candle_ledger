import 'package:candle_ledger/bottomnavbar.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/screen/add_screen.dart';
import 'package:candle_ledger/screen/charts_screen.dart';
import 'package:candle_ledger/screen/home_screen.dart';
import 'package:candle_ledger/screen/explore_screen.dart';
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
    const ScreenExplore(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pages[selectedIndex],
      floatingActionButton: GestureDetector(
        onTap: () => onItemTapped(2),
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Colors.greenAccent, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.black, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: GlassBottomNavBar(
        selectedIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
