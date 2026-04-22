import 'package:candle_ledger/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSnackbar {
  static void show({
    required String title,
    required String message,
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      barBlur: 10,
      colorText: Colors.white,
      titleText: Text(
        title,
        style: GoogleFonts.outfit(
          color: isError ? AppColors.lossRed : AppColors.profitGreen,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.outfit(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 14,
        ),
      ),
      margin: const EdgeInsets.all(20),
      borderRadius: 20,
      borderWidth: 1,
      borderColor: Colors.white.withValues(alpha: 0.1),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  static void success(String title, String message) {
    show(title: title, message: message, isError: false);
  }

  static void error(String title, String message) {
    show(title: title, message: message, isError: true);
  }

  static void info(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      barBlur: 10,
      colorText: Colors.white,
      titleText: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.outfit(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 14,
        ),
      ),
      margin: const EdgeInsets.all(20),
      borderRadius: 20,
      borderWidth: 1,
      borderColor: Colors.white.withValues(alpha: 0.1),
      duration: const Duration(seconds: 3),
    );
  }
}
