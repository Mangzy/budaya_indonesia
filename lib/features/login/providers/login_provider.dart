import 'package:flutter/material.dart';
import 'package:budaya_indonesia/src/auth_provider.dart';
import '../models/login_model.dart';

class LoginProvider extends ChangeNotifier {
  final AuthProvider auth;
  final LoginModel model = LoginModel();
  // Separate loading flags for different flows (used by the UI)
  bool loadingSignInWithEmail = false;
  bool loadingSignUpWithEmail = false;
  bool loadingSignInWithGoogle = false;

  // Last error message (useful for displaying user-friendly messages)
  String? errorMessage;

  LoginProvider({required this.auth});

  Future<void> signInWithEmail() async {
    loadingSignInWithEmail = true;
    errorMessage = null;
    notifyListeners();
    try {
      await auth.signInWithEmail(model.email.trim(), model.password);
    } catch (e) {
      errorMessage = _mapErrorToMessage(e);
    } finally {
      loadingSignInWithEmail = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail() async {
    loadingSignUpWithEmail = true;
    errorMessage = null;
    notifyListeners();
    try {
      await auth.signUpWithEmail(model.email.trim(), model.password);
    } catch (e) {
      errorMessage = _mapErrorToMessage(e);
    } finally {
      loadingSignUpWithEmail = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    loadingSignInWithGoogle = true;
    errorMessage = null;
    notifyListeners();
    try {
      await auth.signInWithGoogle();
    } catch (e) {
      errorMessage = _mapErrorToMessage(e);
    } finally {
      loadingSignInWithGoogle = false;
      notifyListeners();
    }
  }

  String _mapErrorToMessage(Object e) {
    final s = e is Exception ? e.toString() : '$e';
    final lower = s.toLowerCase();

    if (lower.contains('email and password must not be empty')) {
      return 'Email dan password tidak boleh kosong.';
    }
    if (lower.contains('wrong-password') || lower.contains('wrong password')) {
      return 'Password salah. Silakan coba lagi.';
    }
    if (lower.contains('user-not-found') || lower.contains('no user record')) {
      return 'Akun dengan email tersebut tidak ditemukan.';
    }
    if (lower.contains('invalid-email') || lower.contains('invalid email')) {
      return 'Format email tidak valid.';
    }
    if (lower.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    }
    if (lower.contains('network-request-failed') || lower.contains('network')) {
      return 'Gagal koneksi. Periksa koneksi internet Anda.';
    }
    if (lower.contains('email-already-in-use') ||
        lower.contains('already in use')) {
      return 'Email ini sudah terdaftar.';
    }
    if (lower.contains('weak-password') || lower.contains('weak password')) {
      return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
    }
    // fallback: return original message (trimmed) for debugging
    return s.replaceAll('Exception: ', '');
  }
}
