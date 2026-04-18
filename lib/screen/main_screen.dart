import 'package:candle_ledger/bottomnavbar.dart';
import 'package:candle_ledger/screen/add_screen.dart';
import 'package:candle_ledger/screen/charts_screen.dart';
import 'package:candle_ledger/screen/explore_screen.dart';
import 'package:candle_ledger/screen/home_screen.dart';
import 'package:candle_ledger/screen/protfolio_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    const SizedBox.shrink(), // Placeholder for Add
    const ScreenPortfolio(),
    const ScreenExplore(),
  ];

  void onItemTapped(int index) {
    if (index == 2) {
      Get.to(() => const ScreenAdd());
      return;
    }
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pages[selectedIndex],
      bottomNavigationBar: GlassBottomNavBar(
        selectedIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
