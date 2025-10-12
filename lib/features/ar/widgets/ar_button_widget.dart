import 'package:flutter/material.dart';

class ArButtonWidget extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onSwitchCamera;
  final VoidCallback onHelp;

  const ArButtonWidget({
    super.key,
    required this.onCapture,
    required this.onSwitchCamera,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.teal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: IconButton(
              icon: Image.asset('assets/images/reverse_camera.png'),
              onPressed: onSwitchCamera,
            ),
          ),
          GestureDetector(
            onTap: onCapture,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            height: 60,
            child: IconButton(
              icon: Image.asset('assets/images/guidance.png'),
              onPressed: onHelp,
            ),
          ),
        ],
      ),
    );
  }
}
