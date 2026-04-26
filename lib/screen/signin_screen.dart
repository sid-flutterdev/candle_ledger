import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/controllers/transaction_controller.dart';
import 'package:candle_ledger/core/services/firebase_auth_service.dart';
import 'package:candle_ledger/core/widgets/app_snackbar.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/app_loading_dialog.dart';
import 'package:candle_ledger/screen/signup_screen.dart';
import 'package:candle_ledger/screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenSignIn extends StatefulWidget {
  const ScreenSignIn({super.key});

  @override
  State<ScreenSignIn> createState() => _ScreenSignInState();
}

class _ScreenSignInState extends State<ScreenSignIn> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = Get.put(FirebaseAuthService());
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.error("Required", "Please enter both email and password");
      return;
    }

    AppLoadingDialog.show("Logging In", subtitle: "Verifying your credentials...");
    final user = await _authService.signInWithEmail(email, password);

    if (user != null) {
      await _syncDataAndNavigate();
    } else {
      AppLoadingDialog.hide();
    }
  }

  void _handleGoogleSignIn() async {
    AppLoadingDialog.show("Google Sign-In", subtitle: "Connecting to your account...");
    final user = await _authService.signInWithGoogle();

    if (user != null) {
      await _syncDataAndNavigate();
    } else {
      AppLoadingDialog.hide();
    }
  }

  Future<void> _syncDataAndNavigate() async {
    final accountCtrl = Get.find<AccountController>();
    final tradeCtrl = Get.find<TradeController>();

    try {
      AppLoadingDialog.show("Syncing Data", subtitle: "Restoring your trading history...");
      // 1. Load and sync all data from cloud
      await accountCtrl.loadAccounts();
      await tradeCtrl.loadTrades();
      if (Get.isRegistered<TransactionController>()) {
        await Get.find<TransactionController>().loadTransactions();
      }

      AppLoadingDialog.hide();
      // Navigate
      Get.offAll(() => const ScreenMain());
    } catch (e) {
      AppLoadingDialog.hide();
      AppSnackbar.error(
        "Sync Error",
        "Could not restore your data. Please try again.",
      );
      Get.offAll(() => const ScreenMain());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withValues(alpha: 0.05),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/assets/logo.png', width: 80, height: 80),
                  const SizedBox(height: 24),
                  Text(
                    "Welcome Back",
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sign in to access your ledger",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 40),

                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    customBorderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                      topRight: Radius.zero,
                      bottomLeft: Radius.zero,
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _emailController,
                          hint: "Email Address",
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            hint: "Password",
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                final forgotEmailCtrl = TextEditingController(text: _emailController.text);
                                Get.dialog(
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 32),
                                      child: GlassContainer(
                                        borderRadius: 24,
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Reset Password",
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              "Enter your email address and we'll send you a link to reset your password.",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            _buildTextField(
                                              controller: forgotEmailCtrl,
                                              hint: "Email Address",
                                              icon: Icons.email_outlined,
                                            ),
                                            const SizedBox(height: 24),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () => Get.back(),
                                                  child: Text(
                                                    "Cancel",
                                                    style: GoogleFonts.outfit(color: Colors.white38),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    final email = forgotEmailCtrl.text.trim();
                                                    if (email.isEmpty) return;
                                                    
                                                    Get.back();
                                                    try {
                                                      AppLoadingDialog.show("Sending Reset Link", subtitle: "Checking your account...");
                                                      await _authService.sendPasswordResetEmail(email);
                                                      AppLoadingDialog.hide();
                                                      AppSnackbar.success("Email Sent", "Check your inbox at $email");
                                                    } catch (e) {
                                                      AppLoadingDialog.hide();
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.greenAccent.withValues(alpha: 0.1),
                                                    foregroundColor: Colors.greenAccent,
                                                    elevation: 0,
                                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  ),
                                                  child: Text(
                                                    "Send Link",
                                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Forgot Password?",
                                style: GoogleFonts.outfit(
                                  color: Colors.white38,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 30),
                        Column(
                          children: [
                            GlassButton(
                              onPressed: _handleSignIn,
                              color: Colors.white.withValues(alpha: 0.1),
                              child: Text(
                                "LOGIN",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "OR",
                              style: GoogleFonts.outfit(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GlassButton(
                              onPressed: _handleGoogleSignIn,
                              color: Colors.white.withValues(alpha: 0.05),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "G",
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Continue with Google",
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.to(() => const ScreenSignUp()),
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.outfit(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.5)),
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.3),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
