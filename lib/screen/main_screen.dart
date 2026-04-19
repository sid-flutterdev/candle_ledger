import 'package:candle_ledger/bottomnavbar.dart';
import 'package:candle_ledger/core/controllers/navigation_controller.dart';
import 'package:candle_ledger/screen/capital_screen.dart';
import 'package:candle_ledger/screen/analytics_screen.dart';
import 'package:candle_ledger/screen/explore_screen.dart';
import 'package:candle_ledger/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenMain extends StatelessWidget {
  const ScreenMain({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<NavigationController>();

    final List<Widget> pages = [
      const ScreenHome(),
      const ScreenAnalytics(),
      const SizedBox.shrink(), // Placeholder for Add
      const ScreenCapital(),
      const ScreenExplore(),
    ];

    return Obx(
      () => Scaffold(
        extendBody: true,
        body: pages[nav.selectedIndex],
        bottomNavigationBar: GlassBottomNavBar(
          selectedIndex: nav.selectedIndex,
          onTap: nav.changeIndex,
        ),
      ),
    );
  }
}
