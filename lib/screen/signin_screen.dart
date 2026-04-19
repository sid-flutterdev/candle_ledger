import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:candle_ledger/screen/signup_screen.dart';
import 'package:candle_ledger/screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenSignIn extends StatefulWidget {
  const ScreenSignIn({super.key});

  @override
  State<ScreenSignIn> createState() => _ScreenSignInState();
}

class _ScreenSignInState extends State<ScreenSignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String _validEmail = "apptester@candleledger.in";
  final String _validPassword = "teamsupport";

  final String _validEmail2 = "sid@in";
  final String _validPassword2 = "sid";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Authentication Error",
        "Please enter both email and password.",
        backgroundColor: Colors.orangeAccent.withOpacity(0.8),
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
      );
      return;
    }

    if ((email == _validEmail && password == _validPassword) ||
        (email == _validEmail2 && password == _validPassword2)) {
      Get.offAll(
        () => const ScreenMain(),
        routeName: '/ScreenMain',
        transition: Transition.rightToLeftWithFade,
      );
    } else {
      Get.snackbar(
        "Invalid Credentials",
        "The email or password you entered is incorrect. Please try again.",
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.black),
        child: Stack(
          children: [
            // Background Decorative Elements
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.1),
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
                  color: Colors.blue.withOpacity(0.1),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
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
                      "Sign in to continue your trading journey",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 40),

                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            hint: "Email Address",
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _passwordController,
                            hint: "Password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Forgot Password?",
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          GlassButton(
                            onPressed: _handleLogin,
                            color: Colors.white.withOpacity(0.1),
                            child: Text(
                              "LOGIN",
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.1)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(Icons.g_mobiledata_rounded),
                        const SizedBox(width: 20),
                        _buildSocialButton(Icons.apple),
                      ],
                    ),

                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "New to Candle Ledger? ",
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Get.to(
                              () => const ScreenSignUp(),
                              transition: Transition.rightToLeftWithFade,
                            );
                          },
                          child: Text(
                            "Create Account",
                            style: GoogleFonts.outfit(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Version 0.2.0-dev-20260419",
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.1),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5)),
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return GlassContainer(
      width: 60,
      height: 60,
      borderRadius: 15,
      padding: EdgeInsets.zero,
      child: Center(child: Icon(icon, color: Colors.white, size: 30)),
    );
  }
}
