import 'package:flutter/material.dart';
import 'dart:math' as math;

class WavePainter extends CustomPainter {
  final Color color;
  final double animationValue;
  final int waveCount;
  WavePainter({
    required this.color,
    this.animationValue = 0.0,
    this.waveCount = 3,
  });
  @override
  void paint(Canvas canvas,Size size){
    final paint = Paint()
        ..color= color
        ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, size.height);

    for (double i=0;i<=size.width;i++){
      final y = size.height * 0.5 + math.sin((i/size.width*waveCount*math.pi)+ (animationValue*2*math.pi))*20;
      path.lineTo(i, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}

