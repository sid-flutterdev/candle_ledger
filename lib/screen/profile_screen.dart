import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/controllers/navigation_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/controllers/transaction_controller.dart';
import 'package:candle_ledger/core/controllers/user_controller.dart';
import 'package:candle_ledger/core/widgets/app_snackbar.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:candle_ledger/core/models/account.dart';
import 'package:candle_ledger/core/models/trade.dart';
import 'package:candle_ledger/screen/splash_screen.dart';
import 'package:candle_ledger/core/services/firebase_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ScreenProfile extends StatefulWidget {
  const ScreenProfile({super.key});

  @override
  State<ScreenProfile> createState() => _ScreenProfileState();
}

class _ScreenProfileState extends State<ScreenProfile> {
  final UserController userController = Get.find<UserController>();
  final AccountController accountController = Get.find<AccountController>();
  final TradeController tradeController = Get.find<TradeController>();
  final NavigationController nav = Get.find<NavigationController>();
  final FirebaseAuthService authService = Get.find<FirebaseAuthService>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  bool _isEditing = false;

  String get _displayName {
    final user = authService.currentUser;
    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    return userController.userName.isNotEmpty ? userController.userName : "User";
  }

  String get _displayEmail {
    final user = authService.currentUser;
    if (user != null && user.email != null && user.email!.isNotEmpty) {
      return user.email!;
    }
    return userController.userEmail.isNotEmpty ? userController.userEmail : "No email provided";
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _displayName);
    _emailController = TextEditingController(text: _displayEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Save
      userController.updateUserData(
        name: _nameController.text,
        email: _emailController.text,
      );
      
      final user = authService.currentUser;
      if (user != null) {
        user.updateDisplayName(_nameController.text);
      }

      AppSnackbar.success(
        "Success",
        "Profile updated successfully",
      );
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      await userController.updateUserData(profilePath: image.path);
      setState(() {});
    }
  }

  Future<void> _deleteAccountData() async {
    final TextEditingController confirmController = TextEditingController();
    bool canDelete = false;

    bool confirm =
        await Get.dialog<bool>(
          StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: const Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.2)),
                ),
                title: Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      "Delete Everything?",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "This will permanently wipe all your data from our cloud and this device. This cannot be undone.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Type 'DELETE' to confirm",
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmController,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "DELETE",
                        hintStyle: GoogleFonts.outfit(color: Colors.white10),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          canDelete = val.trim().toUpperCase() == "DELETE";
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text(
                      "CANCEL",
                      style: GoogleFonts.outfit(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Opacity(
                    opacity: canDelete ? 1.0 : 0.3,
                    child: ElevatedButton(
                      onPressed: canDelete ? () => Get.back(result: true) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "DELETE ACCOUNT",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              );
            },
          ),
        ) ??
        false;

    if (confirm) {
      // 0. Delete Firebase Account
      bool isDeleted = await authService.deleteAccount();
      
      if (!isDeleted) {
        return; // Stop if Firebase deletion failed (e.g., requires recent login)
      }

      // 1. Clear persistent storage
      await Hive.box<Account>('accounts').clear();
      await Hive.box<Trade>('trades').clear();
      await Hive.box('transactions').clear();
      await Hive.box('settings').clear();

      // 2. Reset in-memory state for all controllers
      final localProfilePath = userController.profilePicturePath;
      if (localProfilePath.isNotEmpty) {
        final file = File(localProfilePath);
        if (await file.exists()) await file.delete();
      }
      
      userController.reset();
      accountController.accounts.clear();
      tradeController.trades.clear();
      if (Get.isRegistered<TransactionController>()) {
        Get.find<TransactionController>().transactions.clear();
      }

      Get.offAll(() => const ScreenSplash());

      AppSnackbar.error(
        "Application Reset",
        "All local and cloud data has been permanently deleted.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildProfileCard(),
              const SizedBox(height: 30),
              if (!_isEditing) _buildSettingsList(),
              const SizedBox(height: 40),
              if (_isEditing) _buildSaveButton(),
              if (!_isEditing) ...[
                const SizedBox(height: 12),
                _buildLogoutButton(),
                const SizedBox(height: 12),
                _buildDeleteAccountButton(),
              ],
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        Text(
          "Profile",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _toggleEdit();
          },
          icon: Icon(
            _isEditing ? Icons.check_rounded : Icons.edit_rounded,
            color: _isEditing ? Colors.greenAccent : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                  child: Obx(() {
                    final path = userController.profilePicturePath;
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF1A1A1A),
                      backgroundImage: path.isNotEmpty ? FileImage(File(path)) : null,
                      child: path.isEmpty
                          ? ClipOval(
                              child: Image.asset(
                                'lib/assets/logo.png',
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            )
                          : null,
                    );
                  }),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (!_isEditing) ...[
            Text(
              _displayName,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _displayEmail,
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
          ] else
            Column(
              children: [
                _buildEditField(_nameController, "Name", Icons.person_outline),
                const SizedBox(height: 16),
                _buildEditField(
                  _emailController,
                  "Email",
                  Icons.email_outlined,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 12,
      child: TextField(
        controller: controller,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white30, size: 20),
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: Colors.white30),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    return Column(
      children: [
        _buildSettingTile(
          "Subscription",
          "Free Plan",
          Icons.star_outline_rounded,
        ),
        const SizedBox(height: 12),
        _buildSettingTile(
          "Risk Settings",
          "Customized",
          Icons.security_rounded,
        ),
        const SizedBox(height: 12),
        _buildSettingTile(
          "Settings",
          "App Preferences",
          Icons.settings_outlined,
        ),
        const SizedBox(height: 12),
        _buildSettingTile("Help & Support", "FAQ", Icons.help_outline_rounded),
        const SizedBox(height: 30),
        Center(
          child: Text(
            "v0.5.0-beta",
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(String title, String subtitle, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: Colors.white30,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white24,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GlassButton(
      onPressed: _toggleEdit,
      color: Colors.greenAccent.withValues(alpha: 0.1),
      child: Text(
        "SAVE CHANGES",
        style: GoogleFonts.outfit(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GlassButton(
      onPressed: () async {
        await Get.find<FirebaseAuthService>().signOut();

        // Clear local cache on logout to prevent cross-user data viewing
        await Hive.box<Account>('accounts').clear();
        await Hive.box<Trade>('trades').clear();
        await Hive.box('transactions').clear();

        // Reset controllers
        accountController.accounts.clear();
        tradeController.trades.clear();
        if (Get.isRegistered<TransactionController>()) {
          Get.find<TransactionController>().transactions.clear();
        }
        userController.reset();

        Get.offAll(() => const ScreenSplash());
      },
      color: Colors.redAccent.withValues(alpha: 0.05),
      child: Text(
        "LOGOUT",
        style: GoogleFonts.outfit(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return Center(
      child: TextButton(
        onPressed: _deleteAccountData,
        child: Text(
          "Delete Account",
          style: GoogleFonts.outfit(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
