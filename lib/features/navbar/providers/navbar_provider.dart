import 'package:flutter/foundation.dart';
import '../models/navbar_model.dart';

class NavbarProvider extends ChangeNotifier {
  final NavbarModel _model = NavbarModel();

  int get index => _model.index;

  void setIndex(int i) {
    if (_model.index == i) return;
    _model.index = i;
    notifyListeners();
  }
}
