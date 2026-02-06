import 'package:flutter/material.dart';

class NeumorphicButton extends StatefulWidget{
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
