import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.primary;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      icon: Image.asset(
        'assets/images/google_logo.png',
        height: 20,
        width: 20,
        errorBuilder: (_, __, ___) => const Icon(Icons.login),
      ),
      label: Text('Sign in with Google', style: TextStyle(color: borderColor)),
    );
  }
}
