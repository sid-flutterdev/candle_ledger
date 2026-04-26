import 'package:candle_ledger/screen/add_trade_screen.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  static NavigationController get to => Get.find();

  final _selectedIndex = 0.obs;
  int get selectedIndex => _selectedIndex.value;

  void changeIndex(int index) {
    if (index == 2) {
      // If we are already on the Add screen, don't open it again
      if (Get.currentRoute != '/ScreenAdd') {
        Get.to(() => const ScreenAddTrade(), routeName: '/ScreenAdd');
      }
      return;
    }

    _selectedIndex.value = index;

    // If we are not on the main screen, go back to it
    if (Get.currentRoute != '/ScreenMain' && Get.currentRoute != '/') {
      Get.back();
    }
  }

  void setIndex(int index) {
    _selectedIndex.value = index;
  }

  void reset() {
    _selectedIndex.value = 0;
  }
}
