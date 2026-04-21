import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/controllers/navigation_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
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

  Future<void> _deleteAccountData() async {
    bool confirm =
        await Get.dialog(
          AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Delete Account?",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "This will permanently delete your account, including all your accounts, trades, and settings. The app will be reset to its initial state. This action cannot be undone.",
              style: GoogleFonts.outfit(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.outfit(color: Colors.white54),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
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
      await Hive.box('settings').clear();

      // 2. Reset in-memory state for all controllers
      userController.reset();

      // For AccountController and TradeController, we explicitly clear their lists
      accountController.accounts.clear();
      tradeController.trades.clear();

      // 3. Force reload just in case
      accountController.loadAccounts();
      tradeController.loadTrades();

      Get.offAll(() => const ScreenSplash());

      AppSnackbar.error(
        "Application Reset",
        "All local data has been permanently deleted.",
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
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF1A1A1A),
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
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
                color: Colors.white.withOpacity(0.4),
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
              color: Colors.white.withOpacity(0.2),
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
              color: Colors.white.withOpacity(0.05),
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
      color: Colors.greenAccent.withOpacity(0.1),
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
        Get.offAll(() => const ScreenSplash());
      },
      color: Colors.redAccent.withOpacity(0.05),
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
