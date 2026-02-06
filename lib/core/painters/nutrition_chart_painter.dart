import 'package:flutter/material.dart';
import 'dart:math' as math;

class NutritionChartPainter extends CustomPainter {
  final double protein;
  final double carbs;
  final double fat;
  final double animationValue;

  NutritionChartPainter({
    required this.protein,
    required this.carbs,
    required this.fat,
    this.animationValue = 1.0,
  });
  @override
  void paint(Canvas canvas,Size size) {
    final center =Offset(size.width/2,size.height/2);
    final radius = math.min(size.width,size.height)/2 -10;

    final total = protein+carbs+fat;
    final proteinAngle = (protein/total)*2*math.pi*animationValue;
    final carbsAngle = (carbs/total)*2*math.pi*animationValue;
    final fatAngle = (fat/total)*2*math.pi*animationValue;

    double startAngle = -math.pi /2;

    _drawSegment( canvas,center,radius,startAngle,proteinAngle,const Color(0xFFFF6B35));
    startAngle +=proteinAngle;

    _drawSegment( canvas,center,radius,startAngle,carbsAngle,const Color(0xFF2EC4B6));
    startAngle += carbsAngle;

    _drawSegment( canvas,center,radius,startAngle,fatAngle,const Color(0xFFFFD93D));
    startAngle +=fatAngle;

  }
  void _drawSegment(Canvas canvas,Offset center,double radius,double startAngle,double sweepAngle,Color color) {
    final paint = Paint()
        ..color =color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, paint,);
  }
  @override
  bool shouldRepaint(NutritionChartPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}
