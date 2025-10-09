import 'package:flutter/material.dart';

class RegisterPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  const RegisterPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF006F5F);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          // ignore: deprecated_member_use
          disabledBackgroundColor: color.withOpacity(.4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        child: child,
      ),
    );
  }
}
