import 'package:candle_ledger/core/controllers/navigation_controller.dart';
import 'package:candle_ledger/core/controllers/user_controller.dart';
import 'package:candle_ledger/core/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:candle_ledger/core/widgets/app_snackbar.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService extends GetxService {
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
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();

      // Update local controller immediately for instant UI
      Get.find<UserController>().updateUserData(
        name: name,
        email: email,
        role: role,
      );

      // Create user document in Firestore
      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      AppSnackbar.error("Error", e.toString());
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        String name = user.displayName ?? "";
        String role = "user";

        // Always fetch from Firestore to get the latest role and name
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          name = doc.data()?['name'] ?? name;
          role = doc.data()?['role'] ?? "user";
        }

        if (name.isEmpty) name = "Trader";

        Get.find<UserController>().updateUserData(
          name: name,
          email: email,
          role: role,
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        AppSnackbar.info(
          "Account Not Found",
          "This email is not registered yet. Please click on 'Sign Up' to create a new account.",
        );
      } else if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        AppSnackbar.error(
          "Login Failed",
          "Incorrect password. If you signed up with Google, please use 'Continue with Google'.",
        );
      } else {
        _handleAuthError(e);
      }
      return null;
    } catch (e) {
      AppSnackbar.error("Error", "An unexpected error occurred: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    Get.find<UserController>().reset();
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().reset();
    }
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        final name = user.displayName ?? 'Trader';
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': user.email ?? '',
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Fetch current role
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final role = doc.data()?['role'] ?? 'user';

        // Update local controller immediately
        Get.find<UserController>().updateUserData(
          name: name,
          email: user.email,
          role: role,
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      AppSnackbar.error("Error", e.toString());
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      rethrow;
    } catch (e) {
      AppSnackbar.error("Error", "Could not send reset email: $e");
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
      final collections = ['accounts', 'trades', 'transactions', 'settings', 'logs', 'notifications'];
      for (var coll in collections) {
        final snapshot = await firestore.collection('users').doc(userId).collection(coll).get();
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
      if (e.code == 'requires-recent-login') {
        AppSnackbar.error(
          "Security Re-auth Required",
          "Please enter your password or re-login with Google to confirm your identity.",
        );
      } else {
        _handleAuthError(e);
      }
      return false;
    } catch (e) {
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
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

        if (googleAuth == null) return false;

        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
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

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // Re-authenticate user before updating password
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      AppSnackbar.error("Error", "Could not update password: $e");
      return false;
    }
  }

  Future<bool> setInitialPassword(String newPassword) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      // For Google users setting a password for the first time
      await user.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        AppSnackbar.error(
          "Security Re-auth Required",
          "For your security, please log out and log back in with Google before setting a password.",
        );
      } else {
        _handleAuthError(e);
      }
      return false;
    } catch (e) {
      AppSnackbar.error("Error", "Could not set password: $e");
      return false;
    }
  }

  Future<bool> updateEmail(String newEmail, {String? currentPassword}) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      // 1. Re-authenticate first to ensure session is fresh for sensitive operation
      if (hasPasswordProvider && currentPassword != null && currentPassword.isNotEmpty) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
      } else if (!hasPasswordProvider) {
        // If Google user, they might need re-auth too, but updateEmail for Google users is tricky.
        // Assuming password-based users for now as per "ask password" requirement.
        final success = await reauthenticateUser();
        if (!success) return false;
      }

      // 2. Attempt update
      // Note: In firebase_auth 5.0+, updateEmail() was removed in favor of verifyBeforeUpdateEmail()
      // for security. This sends a verification link to the NEW email.
      await user.verifyBeforeUpdateEmail(newEmail);
      
      // 3. Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'email': newEmail});

      // 4. Update local controller
      Get.find<UserController>().updateUserData(email: newEmail);

      AppSnackbar.info("Verification Sent", "A link has been sent to $newEmail. The update is applied in-app, but you must verify the link to make it permanent.");
      return true;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        AppSnackbar.error("Security Check", "Please log out and log back in to confirm your identity before changing email.");
      } else {
        _handleAuthError(e);
      }
      return false;
    } catch (e) {
      AppSnackbar.error("Error", "Could not update email: $e");
      return false;
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message = "An error occurred";
    switch (e.code) {
      case 'user-not-found':
        message = "Email not available. Try create a new account.";
        break;
      case 'wrong-password':
      case 'invalid-credential':
        message = "Email not found or incorrect password. If you don't have an account, please Sign Up first.";
        break;
      case 'email-already-in-use':
        message = "This email is already registered. Try signing in instead.";
        break;
      case 'invalid-email':
        message = "Invalid email format.";
        break;
      case 'weak-password':
        message = "The password is too weak.";
        break;
      case 'too-many-requests':
        message = "Too many failed attempts. Please try again later.";
        break;
      case 'user-disabled':
        message = "This account has been disabled.";
        break;
      case 'requires-recent-login':
        message = "For security, please log out and log back in before performing this action.";
        break;
      default:
        message = e.message ?? message;
    }
    AppSnackbar.error("Authentication Error", message);
  }
}
