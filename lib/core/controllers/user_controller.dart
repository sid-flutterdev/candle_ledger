import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final _userName = "Trader".obs;
  final _userEmail = "".obs;
  final _profilePicturePath = "".obs;

  String get userName => _userName.value;
  String get userEmail => _userEmail.value;
  String get profilePicturePath => _profilePicturePath.value;


  Future<void> updateUserData({String? name, String? email, String? profilePath}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{
      'lastActive': FieldValue.serverTimestamp(),
    };

    if (name != null) {
      _userName.value = name;
      updates['name'] = name;
    }
    if (email != null) {
      _userEmail.value = email;
      updates['email'] = email;
    }
    if (profilePath != null) {
      _profilePicturePath.value = profilePath;
      updates['profilePicturePath'] = profilePath;
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      updates,
      SetOptions(merge: true),
    );
  }

  Future<void> updateOnlineStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveFcmToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }

  void reset() {
    _userName.value = "Trader";
    _userEmail.value = "";
    _profilePicturePath.value = "";
  }
}
