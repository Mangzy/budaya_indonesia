import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Image.asset(
        'assets/images/google_logo.png',
        height: 20,
        width: 20,
        errorBuilder: (_, __, ___) => const Icon(Icons.login),
      ),
      label: const Text('Sign in with Google'),
    );
  }
}
