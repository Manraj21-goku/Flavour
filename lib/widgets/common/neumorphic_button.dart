import 'package:flutter/material.dart';

class NeumorphicButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double size;

  const NeumorphicButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = 60,
  });
  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF1A1A2E)
        : const Color(0xFFE8E8E8);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onPressed();
      },
      onTapCancel: () => setState(() {
        _isPressed = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(widget.size / 2),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.5)
                        : Colors.grey.shade500,
                    offset: const Offset(4, 4),
                    blurRadius: 15,
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white,
                    offset: const Offset(-4, -4),
                    blurRadius: 15,
                  ),
                ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
