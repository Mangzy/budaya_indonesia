import 'package:flutter/material.dart';

/// Simple checkerboard background to visualize transparency.
class ArCheckerboard extends StatelessWidget {
  final double cellSize;
  final Color dark;
  final Color light;
  const ArCheckerboard({
    super.key,
    this.cellSize = 12,
    this.dark = const Color(0xFFBDBDBD),
    this.light = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerPainter(cellSize: cellSize, dark: dark, light: light),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  final double cellSize;
  final Color dark;
  final Color light;
  _CheckerPainter({
    required this.cellSize,
    required this.dark,
    required this.light,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pDark = Paint()..color = dark;
    final pLight = Paint()..color = light;
    for (double y = 0; y < size.height; y += cellSize) {
      for (double x = 0; x < size.width; x += cellSize) {
        final isDark =
            ((x / cellSize).floor() + (y / cellSize).floor()) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(x, y, cellSize, cellSize),
          isDark ? pDark : pLight,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckerPainter oldDelegate) =>
      oldDelegate.cellSize != cellSize ||
      oldDelegate.dark != dark ||
      oldDelegate.light != light;
}
