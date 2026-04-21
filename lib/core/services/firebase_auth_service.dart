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

  Future<User?> signUpWithEmail(String name, String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
      return _auth.currentUser;
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
      _handleAuthError(e);
      return null;
    } catch (e) {
      AppSnackbar.error("Error", e.toString());
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

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      AppSnackbar.error("Error", e.toString());
      return null;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      await currentUser?.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        AppSnackbar.error(
          "Error",
          "Please log out and log back in to delete your account.",
        );
      } else {
        _handleAuthError(e);
      }
      return false;
    } catch (e) {
      AppSnackbar.error("Error", e.toString());
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
