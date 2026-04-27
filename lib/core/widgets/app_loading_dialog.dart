import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLoadingDialog {
  static final RxString _message = "".obs;
  static final RxString _subtitle = "".obs;

  static void show(String message, {String? subtitle}) {
    _message.value = message;
    _subtitle.value = subtitle ?? "";

    if (Get.isDialogOpen ?? false) {
      // If already open, just update the message via Obx
      return;
    }

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
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
