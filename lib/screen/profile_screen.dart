import 'dart:io';
import 'package:candle_ledger/core/controllers/user_controller.dart';
import 'package:candle_ledger/core/services/firebase_auth_service.dart';
import 'package:candle_ledger/core/widgets/app_snackbar.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:candle_ledger/core/widgets/app_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenProfile extends StatefulWidget {
  const ScreenProfile({super.key});

  @override
  State<ScreenProfile> createState() => _ScreenProfileState();
}

class _ScreenProfileState extends State<ScreenProfile> {
  final UserController userController = Get.find<UserController>();
  final FirebaseAuthService authService = Get.find<FirebaseAuthService>();

  late TextEditingController _nameController;
  String? _newLocalImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: displayName);
    // Sync data (detect verified email changes)
    userController.fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get displayName {
    if (userController.userName.isNotEmpty &&
        userController.userName != "Trader") {
      return userController.userName;
    }
    return authService.currentUser?.displayName ?? "Trader";
  }

  String get email => userController.userEmail.isNotEmpty
      ? userController.userEmail
      : (authService.currentUser?.email ?? "No email provided");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileImage(),
            const SizedBox(height: 32),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Obx(() {
        final path = _newLocalImagePath ?? userController.profilePicturePath;
        final photoUrl = authService.currentUser?.photoURL;

        ImageProvider image;
        if (path.isNotEmpty) {
          image = FileImage(File(path));
        } else if (photoUrl != null) {
          image = NetworkImage(photoUrl);
        } else {
          image = const AssetImage('lib/assets/logo.png');
        }

        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 4,
            ),
            image: DecorationImage(image: image, fit: BoxFit.cover),
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      borderRadius: 24,
      child: Column(
        children: [
          _buildEditableNameRow(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10, height: 1),
          ),
          Obx(() => _buildInfoRow(Icons.email_outlined, "Email", email)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10, height: 1),
          ),
          _buildUpdatePasswordTile(),
        ],
      ),
    );
  }

  Widget _buildEditableNameRow() {
    return Row(
      children: [
        const Icon(
          Icons.person_outline_rounded,
          color: Colors.white30,
          size: 20,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Name",
                style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12),
              ),
              Obx(
                () => Text(
                  displayName,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white30, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12),
              ),
              Text(
                value,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdatePasswordTile() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showPasswordUpdateSheet,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(
                Icons.lock_reset_rounded,
                color: Colors.blueAccent,
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Update Password",
                  style: GoogleFonts.outfit(
                    color: Colors.blueAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white24,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
    Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onChanged: onChanged,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.3),
            size: 20,
          ),
          suffixIcon: suffixIcon,
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: Colors.white30, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementIndicator(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          color: isMet ? Colors.greenAccent : Colors.redAccent,
          size: 14,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.outfit(
            color: isMet ? Colors.greenAccent : Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  void _showPasswordUpdateSheet() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final bool hasPassword = authService.hasPasswordProvider;

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return GlassContainer(
            padding: const EdgeInsets.all(24),
            borderRadius: 32,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasPassword ? "Update Password" : "Set Account Password",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!hasPassword) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blueAccent.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blueAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "No password exists for this account. Add a new password to enable email login alongside Google.",
                              style: GoogleFonts.outfit(
                                color: Colors.blueAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else
                    Text(
                      "Enter your current and new password below.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white30,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (hasPassword) ...[
                    _buildSheetField(
                      currentPasswordController,
                      "Current Password",
                      Icons.lock_outline,
                      obscure: obscureCurrent,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrent
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white30,
                        ),
                        onPressed: () => setSheetState(
                          () => obscureCurrent = !obscureCurrent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildSheetField(
                    newPasswordController,
                    "New Password",
                    Icons.lock_open_rounded,
                    obscure: obscureNew,
                    onChanged: (_) => setSheetState(() {}),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white30,
                      ),
                      onPressed: () =>
                          setSheetState(() => obscureNew = !obscureNew),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRequirementIndicator(
                    "At least 6 characters",
                    newPasswordController.text.length >= 6,
                  ),
                  const SizedBox(height: 4),
                  _buildRequirementIndicator(
                    "At least 1 number",
                    RegExp(r'[0-9]').hasMatch(newPasswordController.text),
                  ),
                  const SizedBox(height: 16),
                  _buildSheetField(
                    confirmPasswordController,
                    "Confirm New Password",
                    Icons.check_circle_outline,
                    obscure: obscureConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white30,
                      ),
                      onPressed: () =>
                          setSheetState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GlassButton(
                    onPressed: () async {
                      final newPass = newPasswordController.text.trim();
                      final confirmPass = confirmPasswordController.text.trim();
                      final currentPass = currentPasswordController.text.trim();

                      if (newPass.isEmpty ||
                          confirmPass.isEmpty ||
                          (hasPassword && currentPass.isEmpty)) {
                        AppSnackbar.error("Required", "Please fill all fields");
                        return;
                      }

                      final hasMinLength = newPass.length >= 6;
                      final hasNumber = RegExp(r'[0-9]').hasMatch(newPass);

                      if (!hasMinLength || !hasNumber) {
                        AppSnackbar.error(
                          "Invalid Password",
                          "Please meet all requirements",
                        );
                        return;
                      }

                      if (newPass != confirmPass) {
                        AppSnackbar.error(
                          "Mismatch",
                          "New passwords do not match",
                        );
                        return;
                      }

                      AppLoadingDialog.show(
                        "Securing Account",
                        subtitle: "Updating your password...",
                      );
                      bool success = false;
                      if (hasPassword) {
                        success = await authService.changePassword(
                          currentPass,
                          newPass,
                        );
                      } else {
                        success = await authService.setInitialPassword(newPass);
                      }
                      await AppLoadingDialog.hide();

                      if (success) {
                        Get.back();
                        AppSnackbar.success(
                          "Success",
                          hasPassword
                              ? "Password updated!"
                              : "Password added successfully!",
                        );
                      }
                    },
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    child: Text(
                      hasPassword ? "UPDATE PASSWORD" : "ADD PASSWORD",
                      style: GoogleFonts.outfit(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      authService.sendPasswordResetEmail(email);
                      AppSnackbar.info(
                        "Reset Email",
                        "A password reset link has been sent to $email",
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: GoogleFonts.outfit(color: Colors.white30),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}
