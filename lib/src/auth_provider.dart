import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Web OAuth client id (from google-services.json). Keep updated if you
  // regenerate credentials in Firebase console.
  // NOTE: This must be the Web client id (client_type: 3) — not the Android
  // OAuth client id. Using the Android client id will produce
  // "Developer console is not set up correctly" errors.
  static const String serverClientId =
      '929206274027-843pkdp2p5if9an13hmk2r2nvj1a76oi.apps.googleusercontent.com';

  User? _user;
  User? get user => _user;

  StreamSubscription<User?>? _sub;
  void listenAuthState() {
    _sub?.cancel();
    // Ensure google_sign_in plugin is initialized with serverClientId where supported
    try {
      // Some plugin versions provide initialize(clientId:..., serverClientId:...)
      // Use dynamic invocation to stay compatible.
      // ignore: avoid_dynamic_calls
      (GoogleSignIn.instance as dynamic).initialize(
        serverClientId: serverClientId,
      );
      // ignore: avoid_print
      print('AuthProvider: called GoogleSignIn.initialize with serverClientId');
    } catch (_) {
      // ignore: avoid_print
      print('AuthProvider: GoogleSignIn.initialize not available');
    }

    _sub = _auth.authStateChanges().listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    // Defensive: do not call native Firebase API with empty strings —
    // the native SDK throws IllegalArgumentException for empty inputs.
    if (email.trim().isEmpty || password.isEmpty) {
      throw Exception('Email and password must not be empty');
    }
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Sign in with email failed: $e');
    }
  }

  Future<void> sendResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  Future<void> signInWithGoogle() async {
    final gs = GoogleSignIn.instance;

    dynamic googleUser;

    try {
      googleUser = await (gs as dynamic).authenticate(
        scopeHint: <String>['email', 'profile', 'openid'],
      );
    } catch (e) {
      rethrow;
    }

    final googleAuth = await (googleUser as dynamic).authentication;
    final idToken = googleAuth?.idToken as String?;

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    await _auth.signInWithCredential(credential);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
