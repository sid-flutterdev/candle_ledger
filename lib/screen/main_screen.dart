import 'package:candle_ledger/bottomnavbar.dart';
import 'package:candle_ledger/core/controllers/navigation_controller.dart';
import 'package:candle_ledger/screen/capital_screen.dart';
import 'package:candle_ledger/screen/analytics_screen.dart';
import 'package:candle_ledger/screen/explore/explore_screen.dart';
import 'package:candle_ledger/screen/home_screen.dart';
import 'package:candle_ledger/core/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenMain extends StatefulWidget {
  const ScreenMain({super.key});

  @override
  State<ScreenMain> createState() => _ScreenMainState();
}

class _ScreenMainState extends State<ScreenMain> {
  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  void _updateStatus() {
    if (Get.isRegistered<UserController>()) {
      Get.find<UserController>().updateOnlineStatus();
    }
  }

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
