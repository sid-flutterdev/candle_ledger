import 'package:candle_ledger/core/services/firebase_auth_service.dart';
import 'package:candle_ledger/core/widgets/app_snackbar.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenSignUp extends StatefulWidget {
  const ScreenSignUp({super.key});

  @override
  State<ScreenSignUp> createState() => _ScreenSignUpState();
}

class _ScreenSignUpState extends State<ScreenSignUp> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = Get.find<FirebaseAuthService>();

  bool _isLoading = false;
  int _currentStep = 0; // 0: Name/Email, 1: Password
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {});
    });
    _confirmPasswordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _hasSpecialChar =>
      RegExp(r'[!@#\$&*~]').hasMatch(_passwordController.text);

  bool get _isPasswordValid =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSpecialChar;

  void _handleNext() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      AppSnackbar.error("Required", "Please enter both name and email");
      return;
    }

    if (!email.endsWith("@gmail.com")) {
      AppSnackbar.error(
        "Invalid Email",
        "Please use a valid @gmail.com address",
      );
      return;
    }

    setState(() {
      _currentStep = 1;
    });
  }

  void _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (!_isPasswordValid) return;

    if (password != confirmPassword) {
      AppSnackbar.error("Error", "Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);
    final name = _nameController.text.trim();
    final user = await _authService.signUpWithEmail(name, email, password);
    setState(() => _isLoading = false);

    if (user != null) {
      Get.offAll(() => const ScreenMain());
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final user = await _authService.signInWithGoogle();
    setState(() => _isLoading = false);

    if (user != null) {
      Get.offAll(() => const ScreenMain());
    }
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          color: isMet ? Colors.greenAccent : Colors.redAccent,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.outfit(
            color: isMet ? Colors.greenAccent : Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withValues(alpha: 0.05),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/logo.png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Create Account",
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Start your precision trading journey",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 40),

                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: _currentStep == 0
                        ? _buildStepOne()
                        : _buildStepTwo(),
                  ),

                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Text(
                          "Sign In",
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

  Widget _buildStepOne() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          hint: "Full Name",
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          hint: "Email Address",
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 30),
        GlassButton(
          onPressed: _handleNext,
          color: Colors.greenAccent.withValues(alpha: 0.1),
          child: Text(
            "NEXT",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
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
        _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : GlassButton(
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
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => setState(() => _currentStep = 0),
            ),
            Text(
              "Set Password",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          hint: "Password",
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildRequirement("At least 8 characters", _hasMinLength),
        const SizedBox(height: 4),
        _buildRequirement("At least 1 uppercase letter", _hasUppercase),
        const SizedBox(height: 4),
        _buildRequirement("At least 1 lowercase letter", _hasLowercase),
        const SizedBox(height: 4),
        _buildRequirement("At least 1 number", _hasNumber),
        const SizedBox(height: 4),
        _buildRequirement("At least 1 special character", _hasSpecialChar),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          hint: "Confirm Password",
          icon: Icons.lock_clock_outlined,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ),
        const SizedBox(height: 30),
        if (_isPasswordValid &&
            _passwordController.text == _confirmPasswordController.text &&
            _passwordController.text.isNotEmpty)
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : GlassButton(
                  onPressed: _handleSignUp,
                  color: Colors.greenAccent.withValues(alpha: 0.1),
                  child: Center(
                    child: Text(
                      "GET STARTED",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                )
        else
          Center(
            child: Text(
              "Please meet all password requirements",
              style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
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
          hintStyle: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.3)),
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
