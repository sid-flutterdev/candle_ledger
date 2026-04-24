import 'package:get/get.dart';

class UserController extends GetxController {
  final _userName = "Trader".obs;
  final _userEmail = "".obs;
  final _profilePicturePath = "".obs;

  String get userName => _userName.value;
  String get userEmail => _userEmail.value;
  String get profilePicturePath => _profilePicturePath.value;


  Future<void> updateUserData({String? name, String? email, String? profilePath}) async {
    if (name != null) {
      _userName.value = name;
    }
    if (email != null) {
      _userEmail.value = email;
    }
    if (profilePath != null) {
      _profilePicturePath.value = profilePath;
    }
  }

  void reset() {
    _userName.value = "Trader";
    _userEmail.value = "";
    _profilePicturePath.value = "";
  }
}
