import 'package:flutter/material.dart';

class ArOverlayWidget extends StatelessWidget {
  const ArOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 60,
              color: Colors.teal,
            ),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.maxWidth * 0.8;
                return Image.asset(
                  'assets/images/scan.png',
                  width: size,
                  fit: BoxFit.contain,
                  color: Colors.white.withValues(alpha: 0.9),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
