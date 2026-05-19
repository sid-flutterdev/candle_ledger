import 'dart:async';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLoadingDialog {
  static final RxString _message = "".obs;
  static final RxString _subtitle = "".obs;
  static bool _isShowing = false;

  static void show(String message, {String? subtitle}) {
    _message.value = message;
    _subtitle.value = subtitle ?? "";

    if (_isShowing) {
      // If already open, just update the message via Obx
      return;
    }
    _isShowing = true;

    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: GlassContainer(
              borderRadius: 32,
              padding: const EdgeInsets.all(32),
              child: Obx(() => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _message.value,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      if (_subtitle.value.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _subtitle.value,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ],
                  )),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      _isShowing = false;
    });
  }

  static Future<void> hide() async {
    if (!_isShowing) return;
    _isShowing = false;
    await _closeDialog();
  }

  static Future<void> _closeDialog({int attempts = 0}) async {
    if (attempts > 30) {
      // Safety limit to avoid infinite loops if navigator state is inconsistent
      return;
    }
    if (Get.isDialogOpen ?? false) {
      Get.back();
      // Brief delay to let navigator register the pop
      await Future.delayed(const Duration(milliseconds: 150));
    } else {
      final completer = Completer<void>();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _closeDialog(attempts: attempts + 1);
        completer.complete();
      });
      await completer.future;
    }
  }

  static void showError(String title, String message) {
    Get.dialog(
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: GlassContainer(
            borderRadius: 24,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "OK",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
