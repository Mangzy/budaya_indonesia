import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:budaya_indonesia/src/auth_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;
  bool _pngOk = false;

  @override
  void initState() {
    super.initState();
    // Small delay to show the splash and allow providers to initialize
    _timer = Timer(const Duration(milliseconds: 900), _goNext);
    _loadLogo();
  }

  Future<void> _loadLogo() async {
    // Also check for a PNG fallback
    try {
      await rootBundle.load('assets/logo/logo.png');
      setState(() {
        _pngOk = true;
      });
    } catch (_) {
      _pngOk = false;
    }
  }

  void _goNext() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final isLoggedIn = auth.user != null;
    if (isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/navbar');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: _pngOk
            ? Image.asset('assets/logo/logo.png', width: 180, height: 180)
            : const SizedBox.shrink(),
      ),
    );
  }
}
