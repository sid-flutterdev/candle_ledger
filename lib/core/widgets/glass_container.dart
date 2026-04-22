import 'dart:ui';
import 'package:candle_ledger/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20.0,
    this.blur = 20.0,
    this.padding,
    this.margin,
    this.border,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color:
                  color ??
                  (isDarkMode ? AppColors.darkGlass : AppColors.lightGlass),
              borderRadius: BorderRadius.circular(borderRadius),
              border:
                  border ??
                  Border.all(
                    color: isDarkMode
                        ? AppColors.darkGlassBorder
                        : AppColors.lightGlassBorder,
                    width: 1.5,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
