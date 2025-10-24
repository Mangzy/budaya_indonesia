import 'package:flutter/foundation.dart';
import '../../../src/auth_provider.dart';
import '../models/register_model.dart';

class RegisterProvider extends ChangeNotifier {
  final AuthProvider auth;
  final RegisterModel model = RegisterModel();
  bool loading = false;

  RegisterProvider({required this.auth});

  Future<void> register() async {
    if (loading) return;
    loading = true;
    notifyListeners();
    try {
      // Create the account. Note: Firebase creates and signs in the user by
      // default when using createUserWithEmailAndPassword. To keep the UX of
      // returning to the login screen after registration, immediately sign
      // the user out after creating the account.
      await auth.signUpWithEmail(model.email.trim(), model.password);
      try {
        await auth.signOut();
      } catch (_) {
        // ignore sign-out errors here; registration already succeeded.
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
