import 'dart:io';
import 'package:candle_ledger/core/controllers/user_controller.dart';
import 'package:candle_ledger/core/services/firebase_auth_service.dart';
import 'package:candle_ledger/core/widgets/app_snackbar.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:candle_ledger/core/widgets/app_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:candle_ledger/screen/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> _handleSave() async {
    try {
      AppLoadingDialog.show("Updating Profile", subtitle: "Saving your changes...");
      if (_newLocalImagePath != null) {
        await userController.updateUserData(profilePath: _newLocalImagePath);
      }
      final newName = _nameController.text.trim();
      if (newName != displayName && newName.isNotEmpty) {
        await userController.updateUserData(name: newName);
        await authService.currentUser?.updateDisplayName(newName);
      }
      setState(() {
        _newLocalImagePath = null;
      });
      AppSnackbar.success("Success", "Profile updated successfully");
    } catch (e) {
      AppSnackbar.error("Error", "Could not update profile");
    } finally {
      AppLoadingDialog.hide();
    }
  }

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
            const SizedBox(height: 32),
            GlassButton(
              onPressed: _showEditProfileSheet,
              color: Colors.blueAccent.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Edit Profile",
                    style: GoogleFonts.outfit(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassButton(
              onPressed: () => _handleDeleteAccount(),
              color: Colors.redAccent.withValues(alpha: 0.1),
              child: Text(
                "Delete Account",
                style: GoogleFonts.outfit(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 4),
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

  void _showEditProfileSheet() {
    final String initialEmail = email;
    final String initialName = displayName;
    
    final nameCtrl = TextEditingController(text: initialName);
    final emailCtrl = TextEditingController(text: initialEmail);
    final passwordCtrl = TextEditingController();
    String? localImagePath = _newLocalImagePath;

    bool obscureCurrentPassword = true;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> pickImageInSheet() async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              setSheetState(() => localImagePath = image.path);
            }
          }

          final bool isEmailChanged = emailCtrl.text.trim() != initialEmail;

          return GlassContainer(
            padding: const EdgeInsets.all(24),
            borderRadius: 32,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Edit Profile",
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  
                  // Profile Preview
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 4),
                            image: DecorationImage(
                              image: localImagePath != null 
                                ? FileImage(File(localImagePath!)) 
                                : (authService.currentUser?.photoURL != null 
                                    ? NetworkImage(authService.currentUser!.photoURL!) as ImageProvider
                                    : const AssetImage('lib/assets/logo.png')),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: pickImageInSheet,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: pickImageInSheet,
                    child: Text("Change Photo", style: GoogleFonts.outfit(color: Colors.blueAccent)),
                  ),
                  const SizedBox(height: 24),
                  
                  // Name Field
                  _buildSheetField(nameCtrl, "Name", Icons.person_outline_rounded),
                  const SizedBox(height: 16),
                  
                  // Email Field
                  _buildSheetField(
                    emailCtrl, 
                    "Email", 
                    Icons.email_outlined,
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field (only shown if email is changed AND user has a password)
                  if (isEmailChanged && authService.hasPasswordProvider) ...[
                    Text(
                      "To change your email, please enter your password",
                      style: GoogleFonts.outfit(color: Colors.orangeAccent, fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    _buildSheetField(
                      passwordCtrl, 
                      "Current Password", 
                      Icons.lock_outline_rounded,
                      obscure: obscureCurrentPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white30,
                        ),
                        onPressed: () => setSheetState(() => obscureCurrentPassword = !obscureCurrentPassword),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  const SizedBox(height: 16),
                  GlassButton(
                    onPressed: () async {
                      final newName = nameCtrl.text.trim();
                      final newEmail = emailCtrl.text.trim();
                      final password = passwordCtrl.text.trim();

                      // 1. Validate if anything changed
                      final bool isEmailReallyChanged = newEmail != initialEmail;
                      final bool isNameReallyChanged = newName != initialName;
                      final bool isPhotoReallyChanged = localImagePath != _newLocalImagePath;

                      if (!isEmailReallyChanged && !isNameReallyChanged && !isPhotoReallyChanged) {
                        Get.back();
                        return;
                      }

                      // 2. Handle Email Change (Direct update as requested)
                      if (isEmailReallyChanged) {
                        if (authService.hasPasswordProvider && password.isEmpty) {
                          AppSnackbar.error("Security", "Password required to change email");
                          return;
                        }
                        
                        AppLoadingDialog.show("Updating Email", subtitle: "Please wait...");
                        final emailSuccess = await authService.updateEmail(
                          newEmail, 
                          currentPassword: authService.hasPasswordProvider ? password : null,
                        );
                        AppLoadingDialog.hide();
                        if (!emailSuccess) return; 
                        
                        // If ONLY email was changed, we are done as per "dont do anything else"
                        if (!isNameReallyChanged && !isPhotoReallyChanged) {
                          Get.back();
                          return;
                        }
                      }

                      // 3. Handle Name and Photo updates
                      if (isNameReallyChanged || isPhotoReallyChanged) {
                        setState(() {
                          _newLocalImagePath = localImagePath;
                          _nameController.text = newName;
                        });
                        await _handleSave();
                      }
                      
                      Get.back();
                    },
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    child: Text("SAVE CHANGES", style: GoogleFonts.outfit(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
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
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (!hasPassword) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Colors.blueAccent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "No password exists for this account. Add a new password to enable email login alongside Google.",
                              style: GoogleFonts.outfit(color: Colors.blueAccent, fontSize: 12),
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
                      style: GoogleFonts.outfit(color: Colors.white30, fontSize: 13),
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
                          obscureCurrent ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white30,
                        ),
                        onPressed: () => setSheetState(() => obscureCurrent = !obscureCurrent),
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
                      onPressed: () => setSheetState(() => obscureNew = !obscureNew),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRequirementIndicator("At least 6 characters", newPasswordController.text.length >= 6),
                  const SizedBox(height: 4),
                  _buildRequirementIndicator("At least 1 number", RegExp(r'[0-9]').hasMatch(newPasswordController.text)),
                  const SizedBox(height: 16),
                  _buildSheetField(
                    confirmPasswordController, 
                    "Confirm New Password", 
                    Icons.check_circle_outline,
                    obscure: obscureConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white30,
                      ),
                      onPressed: () => setSheetState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GlassButton(
                    onPressed: () async {
                      final newPass = newPasswordController.text.trim();
                      final confirmPass = confirmPasswordController.text.trim();
                      final currentPass = currentPasswordController.text.trim();

                      if (newPass.isEmpty || confirmPass.isEmpty || (hasPassword && currentPass.isEmpty)) {
                        AppSnackbar.error("Required", "Please fill all fields");
                        return;
                      }

                      final hasMinLength = newPass.length >= 6;
                      final hasNumber = RegExp(r'[0-9]').hasMatch(newPass);

                      if (!hasMinLength || !hasNumber) {
                        AppSnackbar.error("Invalid Password", "Please meet all requirements");
                        return;
                      }

                      if (newPass != confirmPass) {
                        AppSnackbar.error("Mismatch", "New passwords do not match");
                        return;
                      }

                      AppLoadingDialog.show("Securing Account", subtitle: "Updating your password...");
                      bool success = false;
                      if (hasPassword) {
                        success = await authService.changePassword(currentPass, newPass);
                      } else {
                        success = await authService.setInitialPassword(newPass);
                      }
                      AppLoadingDialog.hide();

                      if (success) {
                        Get.back();
                        AppSnackbar.success("Success", hasPassword ? "Password updated!" : "Password added successfully!");
                      }
                    },
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    child: Text(
                      hasPassword ? "UPDATE PASSWORD" : "ADD PASSWORD", 
                      style: GoogleFonts.outfit(color: Colors.blueAccent, fontWeight: FontWeight.bold)
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      authService.sendPasswordResetEmail(email);
                      AppSnackbar.info("Reset Email", "A password reset link has been sent to $email");
                    },
                    child: Text("Forgot Password?", style: GoogleFonts.outfit(color: Colors.white30)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }
      ),
      isScrollControlled: true,
    );
  }


  void _handleDeleteAccount() {
    bool confirm = false;
    final passwordController = TextEditingController();
    final bool hasPassword = authService.hasPasswordProvider;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Delete Account?",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "This action is permanent and will wipe all your trade data and settings.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (hasPassword) ...[
                      _buildSheetField(
                        passwordController, 
                        "Enter Password to Confirm", 
                        Icons.lock_outline,
                        obscure: true,
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Checkbox(
                          value: confirm,
                          onChanged: (v) => setDialogState(() => confirm = v ?? false),
                          activeColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.white24),
                        ),
                        Expanded(
                          child: Text(
                            "I understand and want to delete everything.",
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 12,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
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
                          onPressed: (!confirm || (hasPassword && passwordController.text.isEmpty)) 
                            ? null 
                            : () async {
                              Get.back(); // Close confirm dialog
                              AppLoadingDialog.show("Deleting Account", subtitle: "Wiping all data and settings...");
                              final success = await authService.deleteAccount(
                                password: hasPassword ? passwordController.text : null,
                              );
                              if (success) {
                                AppLoadingDialog.hide();
                                Get.offAll(() => const ScreenSplash(), transition: Transition.fade);
                              } else {
                                AppLoadingDialog.hide();
                              }
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: confirm ? Colors.redAccent.withValues(alpha: 0.1) : Colors.transparent,
                            foregroundColor: Colors.redAccent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            "DELETE",
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
