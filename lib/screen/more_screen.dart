import 'dart:io';
import 'package:candle_ledger/core/constants/app_constants.dart';
import 'package:candle_ledger/core/controllers/user_controller.dart';
import 'package:candle_ledger/core/services/firebase_auth_service.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/app_snackbar.dart';
import 'package:candle_ledger/screen/admin_screen.dart';
import 'package:candle_ledger/screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenMore extends StatelessWidget {
  const ScreenMore({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        AppSnackbar.error("Error", "Could not launch link");
      }
    } catch (e) {
      AppSnackbar.error("Error", "Something went wrong opening the link");
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    final FirebaseAuthService authService = Get.find<FirebaseAuthService>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Settings",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildProfileCard(userController, authService),
                const SizedBox(height: 30),

                _buildSectionHeader("APP SETTINGS"),
                const SizedBox(height: 12),
                _buildSectionContainer([
                  Obx(() => userController.userRole == 'admin'
                      ? _buildMoreTile(
                          Icons.admin_panel_settings_rounded,
                          "Admin Portal",
                          () => Get.to(() => const AdminScreen()),
                          iconColor: Colors.purpleAccent,
                        )
                      : const SizedBox.shrink()),
                  _buildMoreTile(
                    Icons.workspace_premium_rounded,
                    "Subscriptions",
                    () {},
                    iconColor: Colors.amberAccent,
                  ),
                  _buildMoreTile(
                    Icons.notifications_none_rounded,
                    "Notifications",
                    () {},
                  ),
                  _buildMoreTile(
                    Icons.security_rounded,
                    "Risk Settings",
                    () {},
                  ),
                ]),

                const SizedBox(height: 32),
                _buildSectionHeader("COMMUNITY"),
                const SizedBox(height: 12),
                _buildJoinCommunity(),

                const SizedBox(height: 32),
                _buildSectionHeader("SUPPORT"),
                const SizedBox(height: 12),
                _buildSectionContainer([
                  _buildMoreTile(
                    Icons.description_outlined,
                    "Privacy Policy",
                    () {},
                  ),
                  _buildMoreTile(
                    Icons.help_outline_rounded,
                    "Help Center",
                    () {},
                  ),
                  _buildMoreTile(
                    Icons.mail_outline_rounded,
                    "Contact Us",
                    () {},
                  ),
                  _buildMoreTile(
                    Icons.info_outline_rounded,
                    "App Version",
                    null,
                    trailing: Text(
                      "v${AppConstants.appVersion}",
                      style: GoogleFonts.outfit(
                        color: Colors.white24,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ]),

                Center(
                  child: Text(
                    "Made with precision @ 2024",
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.1),
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    UserController userController,
    FirebaseAuthService authService,
  ) {
    return GestureDetector(
      onTap: () => Get.to(
        () => const ScreenProfile(),
        transition: Transition.rightToLeftWithFade,
      ),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        color: Colors.white.withValues(alpha: 0.05),
        child: Row(
          children: [
            Obx(() {
              final path = userController.profilePicturePath;
              final photoUrl = authService.currentUser?.photoURL;
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: path.isNotEmpty
                        ? FileImage(File(path)) as ImageProvider
                        : (photoUrl != null
                              ? NetworkImage(photoUrl)
                              : const AssetImage('lib/assets/logo.png')
                                    as ImageProvider),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      userController.userName.isNotEmpty
                          ? userController.userName
                          : (authService.currentUser?.displayName ?? "Trader"),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Obx(
                    () => Text(
                      userController.userEmail.isNotEmpty
                          ? userController.userEmail
                          : (authService.currentUser?.email ?? "trader@example.com"),
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white.withValues(alpha: 0.3),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 20,
      child: Column(children: children),
    );
  }

  Widget _buildMoreTile(
    IconData icon,
    String title,
    VoidCallback? onTap, {
    Widget? trailing,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap != null
            ? () {
                HapticFeedback.lightImpact();
                onTap();
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? Colors.white.withValues(alpha: 0.7),
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.2),
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinCommunity() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSocialIcon(
            Icons.discord_rounded,
            "Discord",
            Colors.indigoAccent,
            "https://discord.gg/dDc3YM6dBh",
          ),
          _buildSocialIcon(
            Icons.camera_alt_rounded,
            "Instagram",
            Colors.pinkAccent,
            "https://www.instagram.com/candle.ledger",
          ),
          _buildSocialIcon(
            Icons.alternate_email_rounded,
            "Threads",
            Colors.white,
            "https://www.threads.com/@candle.ledger",
          ),
          _buildSocialIcon(
            Icons.close_rounded,
            "X",
            Colors.white70,
            "https://x.com/candleledger",
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(
    IconData icon,
    String label,
    Color color,
    String url,
  ) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
