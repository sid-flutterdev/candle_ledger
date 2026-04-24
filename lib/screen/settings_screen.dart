import 'package:candle_ledger/core/constants/app_colors.dart';
import 'package:candle_ledger/core/constants/app_constants.dart';
import 'package:candle_ledger/core/controllers/account_controller.dart';
import 'package:candle_ledger/core/controllers/trade_controller.dart';
import 'package:candle_ledger/core/controllers/user_controller.dart';
import 'package:candle_ledger/core/services/firebase_auth_service.dart';
import 'package:candle_ledger/core/widgets/app_snackbar.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenSettings extends StatelessWidget {
  const ScreenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuthService authService = Get.find<FirebaseAuthService>();

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Settings",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSectionHeader("ACCOUNT"),
                    _buildSettingsItem(
                      icon: Icons.person_outline_rounded,
                      title: "Account Information",
                      subtitle: "View and manage your profile",
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Icons.notifications_none_rounded,
                      title: "Notifications",
                      subtitle: "Configure alerts and reminders",
                      onTap: () {},
                    ),

                    const SizedBox(height: 24),
                    _buildSectionHeader("SECURITY"),
                    _buildSettingsItem(
                      icon: Icons.lock_outline_rounded,
                      title: "Privacy Policy",
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Icons.delete_forever_rounded,
                      title: "Delete Account",
                      titleColor: AppColors.lossRed,
                      subtitle: "Permanently wipe all your data",
                      onTap: () =>
                          _showDeleteConfirmation(context, authService),
                    ),

                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        "Version ${AppConstants.appVersion}",
                        style: GoogleFonts.outfit(
                          color: Colors.white24,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12, top: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white38,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          borderRadius: 20,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (titleColor ?? Colors.white).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: titleColor ?? Colors.white70,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: titleColor ?? Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, FirebaseAuthService auth) {
    bool isChecked = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {

          return Material(
            type: MaterialType.transparency,
            child: Center(
              child: GlassContainer(
                width: Get.width * 0.85,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lossRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        color: AppColors.lossRed,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Delete Account?",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "This will permanently wipe all your data (Trades, Accounts, Settings) and delete your login credentials. This cannot be undone.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => setDialogState(() => isChecked = !isChecked),
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        borderRadius: 12,
                        child: Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (val) => setDialogState(() => isChecked = val ?? false),
                              activeColor: AppColors.lossRed,
                              checkColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                            ),
                            Expanded(
                              child: Text(
                                "I understand that all my data will be permanently deleted.",
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.outfit(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (isChecked) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: isChecked ? 1.0 : 0.0,
                              child: ElevatedButton(
                                onPressed: () async {
                                  Get.back(); // Close dialog
                                  HapticFeedback.heavyImpact();

                                  // Show loading overlay
                                  Get.dialog(
                                    const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.lossRed,
                                      ),
                                    ),
                                    barrierDismissible: false,
                                  );

                                  final success = await auth.deleteAccount();
                                  Get.back(); // Close loading

                                  if (success) {
                                    // Clear all local controllers
                                    Get.find<TradeController>().trades.clear();
                                    Get.find<AccountController>().accounts.clear();
                                    Get.find<UserController>().reset();

                                    Get.offAll(() => const ScreenSplash());
                                    AppSnackbar.success(
                                      "Account Deleted",
                                      "Your data and credentials have been wiped.",
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lossRed.withValues(alpha: 0.8),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Delete",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
