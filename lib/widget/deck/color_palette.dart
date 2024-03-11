import 'dart:math';

import 'package:flutter/material.dart';

import '../../service/color_service.dart';

class ColorWheel extends StatelessWidget {
  final List<String> colors;
  final double size;

  const ColorWheel({
    Key? key,
    required this.colors,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Color> colorValues = colors.map((color) {
      return ColorService().getColorFromString(color);
    }).toList();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          for (int i = 0; i < colors.length; i++)
            CustomPaint(
              size: Size(size, size),
              painter: _ColorWheelPainter(
                color: colorValues[i],
                startAngle: i * 2 * pi / colors.length,
                sweepAngle: 2 * pi / colors.length,
              ),
            ),
        ],
      ),
    );
  }
}

class _ColorWheelPainter extends CustomPainter {
  final Color color;
  final double startAngle;
  final double sweepAngle;

  _ColorWheelPainter({
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
      startAngle,
      sweepAngle,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ColorWheelPainter oldDelegate) {
    return color != oldDelegate.color ||
        startAngle != oldDelegate.startAngle ||
        sweepAngle != oldDelegate.sweepAngle;
  }
}