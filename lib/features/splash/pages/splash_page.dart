import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _pngOk = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Muat logo dan kemudian putuskan navigasi berbasis status login
    _loadLogo();
    _bootstrap();
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

  Future<void> _bootstrap() async {
    // Pastikan splash tampil minimal 500ms dan tunggu pemulihan sesi Firebase (maks 2 detik)
    final minDelay = Future<void>.delayed(const Duration(milliseconds: 500));
    final userFuture = _getUserWithRestore(maxWait: const Duration(seconds: 2));

    final results = await Future.wait<dynamic>([minDelay, userFuture]);
    final User? user = results[1] as User?;

    if (!mounted || _navigated) return;
    _navigated = true;

    // Navigasi setelah frame pertama untuk mencegah masalah context Navigator di initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = user != null ? '/navbar' : '/login';
      debugPrint(
        '[Splash] Navigate to: ' + route + ' | user: ' + (user?.uid ?? 'null'),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
    });
  }

  Future<User?> _getUserWithRestore({
    Duration maxWait = const Duration(seconds: 2),
  }) async {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) return user;

    // Coba tunggu emisi pertama authStateChanges (maks 2 detik)
    try {
      user = await auth.authStateChanges().first.timeout(maxWait);
      return user;
    } catch (_) {
      // fallback ke currentUser (bisa saja sudah dipulihkan saat ini)
      return auth.currentUser;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pngOk)
              Image.asset('assets/logo/logo.png', width: 180, height: 180)
            else
              const SizedBox.shrink(),
            const SizedBox(height: 16),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          ],
        ),
      ),
    );
  }
}
