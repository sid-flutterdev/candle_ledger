import 'package:candle_ledger/core/constants/app_colors.dart';
import 'package:candle_ledger/core/constants/app_constants.dart';
import 'package:candle_ledger/core/controllers/risk_management_controller.dart';
import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RiskManagementCard extends StatelessWidget {
  const RiskManagementCard({super.key});

  RiskManagementController get _controller {
    try {
      return Get.find<RiskManagementController>();
    } catch (_) {
      return Get.put(RiskManagementController(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Obx(() {
      final ratio = controller.usageRatio.clamp(0.0, 1.0);
      final status = controller.status;
      final maxLoss = controller.currentMaxLoss;
      final currentLoss = controller.currentPeriodLoss;
      final isNotSet = maxLoss <= 0;
      final remaining = maxLoss - currentLoss;

      Color gaugeColor;
      String statusLabel;
      IconData statusIcon;
      String statusMessage;

      switch (status) {
        case "exceeded":
          gaugeColor = AppColors.lossRed;
          statusLabel = "EXCEEDED";
          statusIcon = Icons.warning_rounded;
          statusMessage = "Limit crossed. Stop trading for today.";
          break;
        case "warning":
          gaugeColor = Colors.orangeAccent;
          statusLabel = "WARNING";
          statusIcon = Icons.warning_amber_rounded;
          statusMessage = "Approaching limit. Trade carefully.";
          break;
        default:
          gaugeColor = AppColors.profitGreen;
          statusLabel = "SAFE";
          statusIcon = Icons.check_circle_rounded;
          statusMessage = "You're within the safe zone. Keep it up!";
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Outside Card - Matching Recent Trades Theme
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Risk Management",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () => _showSetLimitSheet(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  isNotSet ? "Add Limit" : "Edit Limit",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                GlassContainer(
                  padding: const EdgeInsets.all(4),
                  borderRadius: 10,
                  child: Row(
                    children: ["Daily", "Weekly", "Monthly"].map((period) {
                      final isSelected =
                          controller.selectedPeriod.value == period;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            controller.selectedPeriod.value = period;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              period,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Gauge
                if (isNotSet)
                  _buildNotSetState(controller)
                else
                  _buildGauge(
                    ratio,
                    gaugeColor,
                    statusLabel,
                    statusIcon,
                    currentLoss,
                    maxLoss,
                    remaining,
                    status,
                  ),

                if (!isNotSet) ...[
                  const SizedBox(height: 20),
                  Divider(color: Colors.white.withValues(alpha: 0.05)),
                  const SizedBox(height: 12),
                  // Status message with Set Limit at the end
                  Row(
                    children: [
                      Icon(statusIcon, color: gaugeColor, size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: statusLabel == "SAFE"
                                    ? "Safe. "
                                    : statusLabel == "WARNING"
                                    ? "Warning. "
                                    : "Limit crossed. ",
                                style: GoogleFonts.outfit(
                                  color: gaugeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: statusMessage
                                    .split('. ')
                                    .skip(1)
                                    .join('. '),
                                style: GoogleFonts.outfit(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildGauge(
    double ratio,
    Color gaugeColor,
    String statusLabel,
    IconData statusIcon,
    double currentLoss,
    double maxLoss,
    double remaining,
    String status,
  ) {
    return Column(
      children: [
        // Status Readout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "REMAINING",
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  remaining.toCurrencyStr,
                  style: GoogleFonts.outfit(
                    color: remaining < 0 ? AppColors.lossRed : Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  statusLabel,
                  style: GoogleFonts.outfit(
                    color: gaugeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${(ratio * 100).toPercentStr}% used",
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Segmented Progress Bar
        SizedBox(
          height: 12,
          child: Row(
            children: List.generate(20, (index) {
              final segmentRatio = (index + 1) / 20;
              final isActive = ratio >= segmentRatio;

              // Calculate segment color based on its position
              Color segmentColor;
              if (segmentRatio <= 0.7) {
                segmentColor = AppColors.profitGreen;
              } else if (segmentRatio <= 0.9) {
                segmentColor = Colors.orangeAccent;
              } else {
                segmentColor = AppColors.lossRed;
              }

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: isActive
                        ? segmentColor.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: segmentColor.withValues(alpha: 0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),

        // Bottom Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Lost: ${currentLoss.toCurrencyStr}",
              style: GoogleFonts.outfit(color: Colors.white24, fontSize: 11),
            ),
            Text(
              "Limit: ${maxLoss.toCurrencyStr}",
              style: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotSetState(
    RiskManagementController controller,
  ) {
    return GestureDetector(
      onTap: () => _showSetLimitSheet(controller),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.shield_outlined, color: Colors.white24, size: 40),
            const SizedBox(height: 12),
            Text(
              "No limit set",
              style: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Tap 'Set Limit' to protect your capital",
              style: GoogleFonts.outfit(color: Colors.white24, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetLimitSheet(
    RiskManagementController controller,
  ) {
    final period = controller.selectedPeriod.value;
    double current;
    switch (period) {
      case "Weekly":
        current = controller.weeklyMaxLoss.value;
        break;
      case "Monthly":
        current = controller.monthlyMaxLoss.value;
        break;
      default:
        current = controller.dailyMaxLoss.value;
    }

    final textCtrl = TextEditingController(
      text: current > 0 ? current.toPercentStr : '',
    );

    Get.bottomSheet(
      GlassContainer(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Set $period Max Loss",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "You'll be alerted when losses approach this limit.",
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: textCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                prefixText: "₹  ",
                prefixStyle: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontSize: 18,
                ),
                hintText: "Enter amount",
                hintStyle: GoogleFonts.outfit(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.secondary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final val = double.tryParse(textCtrl.text) ?? 0;
                  controller.setLimit(period, val);
                  HapticFeedback.mediumImpact();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Save Limit",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}
