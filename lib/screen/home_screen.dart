import 'dart:ui';
import 'package:flutter/material.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key});

  final double pnl = 3200.50; // change to test (- value for loss)

  @override
  Widget build(BuildContext context) {
    final bool isProfit = pnl >= 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔥 TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150?img=3",
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Sidhuu",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔥 GLASS CARD
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "NET P&L",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white.withOpacity(0.08),
                                ),
                                child: const Text(
                                  "This Month",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// P&L VALUE
                          Text(
                            "₹ ${pnl.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: isProfit ? Colors.green : Colors.red,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// 📊 BLENDED MINI CHART
                          SizedBox(
                            height: 100,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: _ChartPainter(isProfit: isProfit),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Divider(color: Colors.white.withOpacity(0.2)),

                          const SizedBox(height: 15),

                          /// 📊 STATS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              _StatItem(title: "TRADES", value: "24"),
                              _StatItem(title: "AVG P&L", value: "₹ 320"),
                              _StatItem(title: "BEST", value: "₹ 1,200"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔥 CUSTOM CHART (BLENDED STYLE)
class _ChartPainter extends CustomPainter {
  final bool isProfit;

  _ChartPainter({required this.isProfit});

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isProfit ? Colors.green : Colors.red;

    final path = Path();
    path.moveTo(0, size.height * 0.6);

    path.cubicTo(
      size.width * 0.2,
      size.height * 0.2,
      size.width * 0.4,
      size.height * 0.8,
      size.width * 0.6,
      size.height * 0.4,
    );

    path.cubicTo(
      size.width * 0.75,
      size.height * 0.2,
      size.width * 0.9,
      size.height * 0.5,
      size.width,
      size.height * 0.3,
    );

    /// MAIN LINE
    final linePaint = Paint()
      ..color = baseColor.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    /// GLOW EFFECT
    final glowPaint = Paint()
      ..color = baseColor.withOpacity(0.15)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🔥 STAT ITEM
class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
