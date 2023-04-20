import 'dart:math' as math;
import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final double diameter;
  final Widget? child;

  const CancelButton({key, this.diameter = 300, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: MyPainter(),
          size: Size(diameter, diameter),
        ),
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.0, -0.25),
            child: child,
          ),
        ),
      ],
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    Paint paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment(0.0, 0.05),
        colors: [Color(0x4CF85151), Colors.white70],
      ).createShader(rect);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.height / 2, size.width / 2),
        height: size.height * 0.5,
        width: size.width,
      ),
      math.pi,
      math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
