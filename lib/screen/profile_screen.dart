import 'dart:io';
import 'package:candle_ledger/core/controllers/user_controller.dart';
import 'package:candle_ledger/core/services/firebase_auth_service.dart';
import 'package:candle_ledger/core/widgets/app_snackbar.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:candle_ledger/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
  bool _isEditingName = false;
  bool _hasChanges = false;
  String? _newLocalImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: displayName);
    _nameController.addListener(() {
      if (_nameController.text != displayName) {
        if (!_hasChanges) setState(() => _hasChanges = true);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get displayName {
    if (userController.userName.isNotEmpty && userController.userName != "Trader") {
      return userController.userName;
    }
    return authService.currentUser?.displayName ?? "Trader";
  }

  String get email => authService.currentUser?.email ?? "No email provided";

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newLocalImagePath = image.path;
        _hasChanges = true;
      });
    }
  }

  Future<void> _handleSave() async {
    try {
      if (_newLocalImagePath != null) {
        await userController.updateUserData(profilePath: _newLocalImagePath);
      }
      final newName = _nameController.text.trim();
      if (newName != displayName && newName.isNotEmpty) {
        await userController.updateUserData(name: newName);
        await authService.currentUser?.updateDisplayName(newName);
      }
      setState(() {
        _hasChanges = false;
        _isEditingName = false;
        _newLocalImagePath = null;
      });
      AppSnackbar.success("Success", "Profile updated successfully");
    } catch (e) {
      AppSnackbar.error("Error", "Could not update profile");
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileImage(),
            const SizedBox(height: 32),
            _buildInfoCard(),
            const SizedBox(height: 40),
            if (_hasChanges)
              GlassButton(
                onPressed: _handleSave,
                color: Colors.greenAccent.withOpacity(0.2),
                child: Text("SAVE CHANGES",
                    style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 12),
            GlassButton(
              onPressed: () => _handleDeleteAccount(),
              color: Colors.redAccent.withOpacity(0.1),
              child: Text("Delete Account",
                  style: GoogleFonts.outfit(
                      color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _pickImage,
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
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 4),
                  image: DecorationImage(image: image, fit: BoxFit.cover),
                ),
              );
            }),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
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
          _buildInfoRow(Icons.email_outlined, "Email", email),
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
        const Icon(Icons.person_outline_rounded, color: Colors.white30, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Name",
                style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12),
              ),
              if (_isEditingName)
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => setState(() => _isEditingName = false),
                )
              else
                GestureDetector(
                  onTap: () => setState(() => _isEditingName = true),
                  child: Obx(() => Text(
                    displayName,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  )),
                ),
            ],
          ),
        ),
        if (!_isEditingName)
          IconButton(
            onPressed: () => setState(() => _isEditingName = true),
            icon: const Icon(Icons.edit_rounded, color: Colors.white24, size: 18),
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
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
              const Icon(Icons.lock_reset_rounded, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Update Password",
                  style: GoogleFonts.outfit(color: Colors.blueAccent, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordUpdateSheet() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.bottomSheet(
      GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Update Password",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildBottomSheetField(currentPasswordController, "Current Password", Icons.lock_outline),
            const SizedBox(height: 16),
            _buildBottomSheetField(newPasswordController, "New Password", Icons.lock_open_rounded),
            const SizedBox(height: 16),
            _buildBottomSheetField(confirmPasswordController, "Confirm New Password", Icons.check_circle_outline),
            const SizedBox(height: 32),
            GlassButton(
              onPressed: () {
                Get.back();
                AppSnackbar.success("Demo", "Password updated successfully!");
              },
              color: Colors.blueAccent.withOpacity(0.1),
              child: Text("UPDATE PASSWORD", style: GoogleFonts.outfit(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Get.back();
                AppSnackbar.info("Demo", "Password reset link sent to your email!");
              },
              child: Text("Forgot Password?", style: GoogleFonts.outfit(color: Colors.white30)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBottomSheetField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller,
        obscureText: true,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.3), size: 20),
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: Colors.white30, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  void _handleDeleteAccount() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Delete Account?",
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("This will permanently delete your account and data.",
            style: GoogleFonts.outfit(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel",
                  style: GoogleFonts.outfit(color: Colors.white30))),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await authService.deleteUserAccount();
                Get.offAll(() => const ScreenSplash());
              } catch (e) {
                AppSnackbar.error("Error", "Failed to delete account");
              }
            },
            child: Text("Delete", style: GoogleFonts.outfit(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
