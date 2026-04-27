import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final _userName = "Trader".obs;
  final _userEmail = "".obs;
  final _userRole = "user".obs;
  final _profilePicturePath = "".obs;

  String get userName => _userName.value;
  String get userEmail => _userEmail.value;
  String get userRole => _userRole.value;
  String get profilePicturePath => _profilePicturePath.value;

  @override
  void onInit() {
    super.onInit();
    // Update status every 3 minutes while app is open
    _startStatusUpdates();
  }

  void _startStatusUpdates() {
    Stream.periodic(const Duration(minutes: 3)).listen((_) {
      updateOnlineStatus();
    });
  }

  Future<void> updateUserData({
    String? name,
    String? email,
    String? role,
    String? profilePath,
  }) async {
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
    if (role != null) {
      _userRole.value = role;
      updates['role'] = role;
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

  void updateUserDataLocally({
    String? name,
    String? email,
    String? role,
    String? profilePath,
  }) {
    if (name != null) _userName.value = name;
    if (email != null) _userEmail.value = email;
    if (role != null) _userRole.value = role;
    if (profilePath != null) _profilePicturePath.value = profilePath;
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Reload user to get the latest email status (in case they just clicked the verification link)
      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;
      if (updatedUser == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.uid)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _userName.value = data['name'] ?? _userName.value;
          _userRole.value = data['role'] ?? 'user';
          _profilePicturePath.value =
              data['profilePicturePath'] ?? _profilePicturePath.value;

          // Email Sync Logic: Check if Auth email is newer than Firestore email
          final firestoreEmail = data['email'];
          final authEmail = updatedUser.email;

          if (authEmail != null && authEmail != firestoreEmail) {
            debugPrint("Verified email detected: $authEmail. Syncing to Firestore.");
            await updateUserData(email: authEmail);
            _userEmail.value = authEmail;
          } else {
            _userEmail.value = firestoreEmail ?? authEmail ?? _userEmail.value;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  Future<void> updateOnlineStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void reset() {
    _userName.value = "Trader";
    _userEmail.value = "";
    _userRole.value = "user";
    _profilePicturePath.value = "";
  }
}
