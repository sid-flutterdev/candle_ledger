import 'dart:async';
import 'package:candle_ledger/core/controllers/navigation_controller.dart';
import 'package:candle_ledger/core/controllers/user_controller.dart';
import 'package:candle_ledger/core/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:candle_ledger/core/widgets/app_snackbar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:candle_ledger/core/widgets/app_loading_dialog.dart';

class FirebaseAuthService extends GetxService {
  @override
  void onInit() {
    super.onInit();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize();
    } catch (e) {
      debugPrint("Error initializing Google Sign In: $e");
    }
  }

  FirebaseAuth get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      throw "Firebase not initialized. Please check your configuration.";
    }
  }

  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (e) {
      return const Stream.empty();
    }
  }

  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  bool get hasPasswordProvider {
    final user = currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'password');
  }

  Future<User?> signUpWithEmail(
    String name,
    String email,
    String password, {
    String role = 'user',
  }) async {
    try {
      UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 15));
      await credential.user
          ?.updateDisplayName(name)
          .timeout(const Duration(seconds: 5));
      await credential.user?.reload().timeout(const Duration(seconds: 5));

      final user = _auth.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'uid': user.uid,
                'name': name,
                'email': email,
                'role': role,
                'createdAt': FieldValue.serverTimestamp(),
                'lastActive': FieldValue.serverTimestamp(),
              })
              .timeout(const Duration(seconds: 10));
        } catch (e) {
          debugPrint("Firestore user creation failed or timed out: $e");
        }

        // Update local controller state without hitting Firestore again
        Get.find<UserController>().updateUserDataLocally(
          name: name,
          email: email,
          role: role,
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      await _handleAuthError(e);
      return null;
    } catch (e) {
      await AppLoadingDialog.hide();
      if (e is TimeoutException) {
        AppSnackbar.error(
          "Connection Timeout",
          "The signup request timed out. Please check your internet connection.",
        );
      } else {
        AppSnackbar.error("Error", e.toString());
      }
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 15));
      final user = credential.user;
      if (user != null) {
        String name = user.displayName ?? "Trader";
        String role = "user";

        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get()
              .timeout(const Duration(seconds: 10));

          if (doc.exists) {
            name = doc.data()?['name'] ?? name;
            role = doc.data()?['role'] ?? "user";

            // Update last active status
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'lastActive': FieldValue.serverTimestamp()})
                .timeout(const Duration(seconds: 5));
          } else {
            // If auth exists but Firestore doc is missing, create it
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
                  'uid': user.uid,
                  'name': name,
                  'email': email,
                  'role': role,
                  'createdAt': FieldValue.serverTimestamp(),
                  'lastActive': FieldValue.serverTimestamp(),
                })
                .timeout(const Duration(seconds: 5));
          }
        } catch (e) {
          debugPrint("Firestore user read/write failed: $e");
        }

        // Update local controller state
        Get.find<UserController>().updateUserDataLocally(
          name: name,
          email: email,
          role: role,
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      await AppLoadingDialog.hide();
      if (e.code == 'user-not-found') {
        AppLoadingDialog.showError(
          "Account Not Found",
          "This email is not registered. Please sign up to create an account.",
        );
      } else if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        AppLoadingDialog.showError(
          "Login Failed",
          "Incorrect email or password. Please try again.",
        );
      } else {
        await _handleAuthError(e);
      }
      return null;
    } catch (e) {
      await AppLoadingDialog.hide();
      if (e is TimeoutException) {
        AppSnackbar.error(
          "Connection Timeout",
          "The login request timed out. Please check your internet connection.",
        );
      } else {
        AppSnackbar.error("Error", "An unexpected error occurred: $e");
      }
      return null;
    }
  }

  Future<void> signOut() async {
    Get.find<UserController>().reset();
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().reset();
    }
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final authorizedUser = await googleUser.authorizationClient
          .authorizeScopes(['email', 'profile']);

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorizedUser.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth
          .signInWithCredential(credential)
          .timeout(const Duration(seconds: 15));
      final user = userCredential.user;

      if (user != null) {
        String name = user.displayName ?? 'Trader';
        String role = 'user';

        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get()
              .timeout(const Duration(seconds: 10));

          if (!doc.exists) {
            // New Account Creation
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
                  'uid': user.uid,
                  'name': name,
                  'email': user.email ?? '',
                  'role': role,
                  'createdAt': FieldValue.serverTimestamp(),
                  'lastActive': FieldValue.serverTimestamp(),
                });
          } else {
            // Existing Account - Update Last Active
            role = doc.data()?['role'] ?? 'user';
            name = doc.data()?['name'] ?? name;
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'lastActive': FieldValue.serverTimestamp()});
          }
        } catch (e) {
          debugPrint("Firestore Google signin sync failed: $e");
        }

        // Update local controller immediately
        Get.find<UserController>().updateUserDataLocally(
          name: name,
          email: user.email,
          role: role,
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      await _handleAuthError(e);
      return null;
    } catch (e) {
      await AppLoadingDialog.hide();
      AppSnackbar.error("Error", "Google Sign-In failed: ${e.toString()}");
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth
          .sendPasswordResetEmail(email: email)
          .timeout(const Duration(seconds: 15));
    } on FirebaseAuthException catch (e) {
      await _handleAuthError(e);
      rethrow;
    } catch (e) {
      await AppLoadingDialog.hide();
      if (e is TimeoutException) {
        AppSnackbar.error(
          "Connection Timeout",
          "Sending reset link timed out. Please check your internet connection.",
        );
      } else {
        AppSnackbar.error("Error", "Could not send reset email: $e");
      }
      rethrow;
    }
  }

  Future<bool> deleteUserAccount() async {
    return await deleteAccount();
  }

  Future<bool> deleteAccount({String? password}) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      // 1. Attempt to re-authenticate first to satisfy "requires-recent-login"
      // This allows the user to delete their account WITHOUT logging out and back in.
      await reauthenticateUser(password: password);

      final userId = user.uid;
      final firestore = FirebaseFirestore.instance;

      // 2. Delete Firestore Data (Subcollections)
      final collections = [
        'accounts',
        'trades',
        'transactions',
        'settings',
        'logs',
        'notifications',
      ];
      for (var coll in collections) {
        final snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection(coll)
            .get();
        if (snapshot.docs.isNotEmpty) {
          final batch = firestore.batch();
          for (var doc in snapshot.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }
      }

      // 3. Delete main user document
      await firestore.collection('users').doc(userId).delete();

      // 4. Delete Storage Data (Screenshots)
      await Get.find<StorageService>().deleteAllUserMedia(userId);

      // 5. Delete Auth User
      await user.delete();

      // 6. Final sign out
      await signOut();

      return true;
    } on FirebaseAuthException catch (e) {
      await AppLoadingDialog.hide();
      if (e.code == 'requires-recent-login') {
        AppSnackbar.error(
          "Security Re-auth Required",
          "Please enter your password or re-login with Google to confirm your identity.",
        );
      } else {
        await _handleAuthError(e);
      }
      return false;
    } catch (e) {
      await AppLoadingDialog.hide();
      AppSnackbar.error("Error", "Failed to wipe data: $e");
      return false;
    }
  }

  Future<bool> reauthenticateUser({String? password}) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      AuthCredential? credential;

      if (user.providerData.any((p) => p.providerId == 'google.com')) {
        final GoogleSignInAccount googleUser = await GoogleSignIn.instance
            .authenticate();

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final authorizedUser = await googleUser.authorizationClient
            .authorizeScopes(['email', 'profile']);

        credential = GoogleAuthProvider.credential(
          accessToken: authorizedUser.accessToken,
          idToken: googleAuth.idToken,
        );
      } else if (password != null) {
        credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
      }

      if (credential != null) {
        await user.reauthenticateWithCredential(credential);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Re-auth error: $e");
      return false;
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // Re-authenticate user before updating password
      await user
          .reauthenticateWithCredential(credential)
          .timeout(const Duration(seconds: 15));
      await user
          .updatePassword(newPassword)
          .timeout(const Duration(seconds: 15));
      return true;
    } on FirebaseAuthException catch (e) {
      await _handleAuthError(e);
      return false;
    } catch (e) {
      await AppLoadingDialog.hide();
      if (e is TimeoutException) {
        AppSnackbar.error(
          "Connection Timeout",
          "Updating password timed out. Please check your internet connection.",
        );
      } else {
        AppSnackbar.error("Error", "Could not update password: $e");
      }
      return false;
    }
  }

  Future<bool> setInitialPassword(String newPassword) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      // For Google users setting a password for the first time
      await user
          .updatePassword(newPassword)
          .timeout(const Duration(seconds: 15));
      return true;
    } on FirebaseAuthException catch (e) {
      await AppLoadingDialog.hide();
      if (e.code == 'requires-recent-login') {
        AppSnackbar.error(
          "Security Re-auth Required",
          "For your security, please log out and log back in with Google before setting a password.",
        );
      } else {
        await _handleAuthError(e);
      }
      return false;
    } catch (e) {
      await AppLoadingDialog.hide();
      if (e is TimeoutException) {
        AppSnackbar.error(
          "Connection Timeout",
          "Setting password timed out. Please check your internet connection.",
        );
      } else {
        AppSnackbar.error("Error", "Could not set password: $e");
      }
      return false;
    }
  }

  Future<bool> updateEmail(String newEmail, {String? currentPassword}) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      // 1. Re-authenticate first to ensure session is fresh for sensitive operation
      if (hasPasswordProvider &&
          currentPassword != null &&
          currentPassword.isNotEmpty) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user
            .reauthenticateWithCredential(credential)
            .timeout(const Duration(seconds: 15));
      } else if (!hasPasswordProvider) {
        // If Google user, they might need re-auth too, but updateEmail for Google users is tricky.
        // Assuming password-based users for now as per "ask password" requirement.
        final success = await reauthenticateUser();
        if (!success) return false;
      }

      // 2. Attempt update
      // Note: In firebase_auth 5.0+, updateEmail() was removed in favor of verifyBeforeUpdateEmail()
      // for security. This sends a verification link to the NEW email.
      await user
          .verifyBeforeUpdateEmail(newEmail)
          .timeout(const Duration(seconds: 15));

      // 3. Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'email': newEmail})
          .timeout(const Duration(seconds: 10));

      // 4. Update local controller
      Get.find<UserController>().updateUserData(email: newEmail);

      AppSnackbar.info(
        "Verification Sent",
        "A link has been sent to $newEmail. The update is applied in-app, but you must verify the link to make it permanent.",
      );
      return true;
    } on FirebaseAuthException catch (e) {
      await AppLoadingDialog.hide();
      if (e.code == 'requires-recent-login') {
        AppSnackbar.error(
          "Security Check",
          "Please log out and log back in to confirm your identity before changing email.",
        );
      } else {
        await _handleAuthError(e);
      }
      return false;
    } catch (e) {
      await AppLoadingDialog.hide();
      if (e is TimeoutException) {
        AppSnackbar.error(
          "Connection Timeout",
          "Updating email timed out. Please check your internet connection.",
        );
      } else {
        AppSnackbar.error("Error", "Could not update email: $e");
      }
      return false;
    }
  }

  Future<void> _handleAuthError(FirebaseAuthException e) async {
    await AppLoadingDialog.hide();
    String message = "An error occurred";
    switch (e.code) {
      case 'user-not-found':
        message = "No account found with this email.";
        break;
      case 'wrong-password':
      case 'invalid-credential':
        message = "Incorrect email or password. Please try again.";
        break;
      case 'email-already-in-use':
        message = "This email is already registered. Try signing in instead.";
        break;
      case 'invalid-email':
        message = "The email address is badly formatted.";
        break;
      case 'weak-password':
        message = "The password must be at least 6 characters.";
        break;
      case 'too-many-requests':
        message = "Too many attempts. Please try again later.";
        break;
      case 'user-disabled':
        message = "This account has been disabled by an administrator.";
        break;
      case 'operation-not-allowed':
        message = "This sign-in method is currently disabled.";
        break;
      case 'network-request-failed':
        message = "No internet connection. Please check your network.";
        break;
      default:
        message = e.message ?? "Authentication failed. Please try again.";
    }
    AppLoadingDialog.showError("Auth Error", message);
  }
}
