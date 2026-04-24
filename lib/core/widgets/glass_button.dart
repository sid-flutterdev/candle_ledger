import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;

  const GlassButton({
    super.key,
    this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 16.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassContainer(
        width: width,
        height: height,
        borderRadius: borderRadius,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        color: color,
        child: Center(child: child),
      ),
    );
  }
}
