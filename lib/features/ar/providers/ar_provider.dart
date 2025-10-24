import 'package:flutter/material.dart';

class ArProvider extends ChangeNotifier {
  bool isFrontCamera = true;

  void setFrontCamera(bool value) {
    isFrontCamera = value;
    notifyListeners();
  }

  void toggleCamera() {
    isFrontCamera = !isFrontCamera;
    notifyListeners();
  }
}
