import 'package:candle_ledger/core/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<User?> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();

      // Create user document in Firestore
      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
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
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'invalid-credential' ||
          e.code == 'wrong-password') {
        AppSnackbar.error(
          "Login Failed",
          "Invalid email or password. If you signed up with Google, please use 'Continue with Google'.",
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
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? 'Trader',
          'email': user.email ?? '',
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
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

  Future<bool> deleteAccount() async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final userId = user.uid;
      final firestore = FirebaseFirestore.instance;

      // 1. Delete Firestore Data (Subcollections)
      // Note: Client-side recursive delete requires fetching IDs
      final collections = ['accounts', 'trades', 'transactions'];
      for (var coll in collections) {
        final snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection(coll)
            .get();

        final batch = firestore.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // 2. Delete main user document
      await firestore.collection('users').doc(userId).delete();

      // 3. Delete Storage Data (Screenshots)
      await Get.find<StorageService>().deleteAllUserMedia(userId);

      // 4. Delete Auth User
      await user.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        AppSnackbar.error(
          "Security Re-auth Required",
          "For your security, please log out and log back in before deleting your account.",
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

  void _handleAuthError(FirebaseAuthException e) {
    String message = "An error occurred";
    switch (e.code) {
      case 'user-not-found':
        message = "No user found with this email.";
        break;
      case 'wrong-password':
        message = "Incorrect password.";
        break;
      case 'email-already-in-use':
        message = "This email is already registered.";
        break;
      case 'invalid-email':
        message = "Invalid email format.";
        break;
      case 'weak-password':
        message = "The password is too weak.";
        break;
      default:
        message = e.message ?? message;
    }
    AppSnackbar.error("Authentication Error", message);
  }
}
