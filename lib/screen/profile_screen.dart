import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/controllers/navigation_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/controllers/user_controller.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/glass_button.dart';
import 'package:candle_ledger/core/models/account.dart';
import 'package:candle_ledger/core/models/trade.dart';
import 'package:candle_ledger/screen/signin_screen.dart';
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

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: userController.userName);
    _emailController = TextEditingController(text: userController.userEmail);
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
      Get.snackbar(
        "Success",
        "Profile updated successfully",
        backgroundColor: Colors.greenAccent.withOpacity(0.8),
        colorText: Colors.black,
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
              "Clear All Data?",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "This will permanently delete all your accounts, trades, and settings. The app will be reset to its initial state.",
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
                  "Clear Everything",
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

      Get.offAll(() => const ScreenSignIn());

      Get.snackbar(
        "Application Reset",
        "All local data has been permanently deleted.",
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
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
              if (_isEditing) _buildSaveButton() else _buildLogoutButton(),
              if (!_isEditing) ...[
                const SizedBox(height: 12),
                _buildDeleteDataButton(),
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
              userController.userName,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              userController.userEmail.isEmpty
                  ? "No email provided"
                  : userController.userEmail,
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
      onPressed: () {
        Get.offAll(() => ScreenSignIn());
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

  Widget _buildDeleteDataButton() {
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
