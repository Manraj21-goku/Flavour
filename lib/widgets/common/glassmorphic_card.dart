import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicCard extends StatelessWidget{
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity =0.15,
    this.borderRadius,
    this.padding,
});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius:  borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur,sigmaY: blur),
      child: Container(
        padding: padding?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(opacity)
              : Colors.white.withOpacity(opacity+0.3),
          borderRadius:  borderRadius ?? BorderRadius.circular(20),
          border:  Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: -5,
            )
          ]
        ),
        child: child,
      ),
      ),
    );
  }
}