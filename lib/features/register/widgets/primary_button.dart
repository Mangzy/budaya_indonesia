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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: onPressed, child: child),
    );
  }
}
