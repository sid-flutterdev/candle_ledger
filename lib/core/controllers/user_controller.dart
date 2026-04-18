import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserController extends GetxController {
  late Box _settingsBox;
  
  final _userName = "Trader".obs;
  final _userEmail = "".obs;

  String get userName => _userName.value;
  String get userEmail => _userEmail.value;

  @override
  void onInit() {
    super.onInit();
    _settingsBox = Hive.box('settings');
    _loadUserData();
  }

  void _loadUserData() {
    _userName.value = _settingsBox.get('userName', defaultValue: "Trader");
    _userEmail.value = _settingsBox.get('userEmail', defaultValue: "");
  }

  Future<void> updateUserData({String? name, String? email}) async {
    if (name != null) {
      _userName.value = name;
      await _settingsBox.put('userName', name);
    }
    if (email != null) {
      _userEmail.value = email;
      await _settingsBox.put('userEmail', email);
    }
  }

  void reset() {
    _userName.value = "Trader";
    _userEmail.value = "";
  }
}
