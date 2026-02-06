import 'package:flutter/material.dart';
import 'dart:math' as math;

class BlobPainter extends CustomPainter {
  final Color color;
  final double animationValue;
  BlobPainter({required this.color,this.animationValue=0.0});

  @override
  void paint(Canvas canvas,Size size) {
    final paint = Paint()
        ..color =color
        ..style =PaintingStyle.fill;
    final path =Path();
    final center = Offset(size.width/2,size.height/2);
    final radius = math.min(size.width,size.height)/2;
    const points = 6;
    for (int i=0;i<=points;i++){
      final angle = (i/points)*2*math.pi;
      final variation = math.sin(angle*3+animationValue*2*math.pi) *0.2;
      final r = radius *(0.8+variation);
      final x =center.dx +r*math.cos(angle);
      final y = center.dy +r *math.sin(angle);
      if( i==0){
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(BlobPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}