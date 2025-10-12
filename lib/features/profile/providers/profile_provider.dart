import 'dart:developer' as dev;
import 'package:budaya_indonesia/features/profile/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  UserProfile? _profile;
  bool _loading = false;
  String? _error;

  ProfileProvider({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance {
    load();
  }

  UserProfile? get profile => _profile;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    final user = _auth.currentUser;
    if (user == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final dark = prefs.getBool('darkMode') ?? false;
      _profile = UserProfile(
        id: user.uid,
        name: user.displayName ?? 'Pengguna',
        username: user.displayName, // sementara samakan
        email: user.email,
        photoUrl: user.photoURL,
        darkMode: dark,
      );
    } catch (e, st) {
      dev.log(
        'Profile load error: $e',
        name: 'ProfileProvider',
        stackTrace: st,
      );
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    if (_profile == null) return;
    try {
      await _auth.currentUser?.updateDisplayName(name);
      _profile = _profile!.copyWith(name: name);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUsername(String username) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(username: username);
    notifyListeners();
  }

  Future<void> updatePhoto() async {
    if (_profile == null) return;
    try {
      final path = await pickImagePath();
      if (path == null) return;
      await setLocalPhoto(path);
    } catch (e, st) {
      dev.log('updatePhoto error: $e', name: 'ProfileProvider', stackTrace: st);
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<String?> pickImagePath() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 85,
      );
      return picked?.path;
    } on PlatformException catch (e, st) {
      dev.log(
        'pickImage PlatformException: $e',
        name: 'ProfileProvider',
        stackTrace: st,
      );
      _error = 'Gagal membuka gallery. Lakukan full restart aplikasi.';
      notifyListeners();
      return null;
    } catch (e, st) {
      dev.log('pickImage error: $e', name: 'ProfileProvider', stackTrace: st);
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> setLocalPhoto(String path) async {
    if (_profile == null) return;
    final file = File(path);
    if (!await file.exists()) return;
    _profile = _profile!.copyWith(photoUrl: path);
    notifyListeners();
    try {
      await _auth.currentUser?.updatePhotoURL(_profile!.photoUrl);
    } catch (e) {
      dev.log('updatePhotoURL warning: $e');
    }
  }

  Future<void> toggleDarkMode() async {
    if (_profile == null) return;
    final newVal = !_profile!.darkMode;
    _profile = _profile!.copyWith(darkMode: newVal);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', newVal);
    } catch (e, st) {
      dev.log(
        'toggleDarkMode persist error: $e',
        name: 'ProfileProvider',
        stackTrace: st,
      );
    }
  }
}
