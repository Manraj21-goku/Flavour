import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class AnimatedLikeButton extends StatefulWidget {
  final bool isLiked;
  final ValueChanged<bool> onChanged;
  final double size;

  const AnimatedLikeButton({
    super.key,
    required this.isLiked,
    required this.onChanged,
    this.size = 32,
  });

  @override
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _controller.forward(from: 0);
    widget.onChanged(!widget.isLiked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.isLiked) ..._buildParticles(),
                Icon(
                  widget.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.isLiked ? const Color(0xFFFF6B35) : Colors.grey,
                  size: widget.size,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildParticles() {
    return List.generate(6, (index) {
      final angle = (index / 6) * math.pi * 2;
      return AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          final offset = _bounceAnimation.value * 20;
          return Transform.translate(
            offset: Offset(offset * cos(angle), offset * sin(angle)),
            child: Opacity(
              opacity: 1 - _bounceAnimation.value,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B35),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

double cos(double x) => math.cos(x);
double sin(double x) => math.sin(x);
