import 'package:flutter/foundation.dart';

class HeaderToggleProvider extends ChangeNotifier {
  bool _isHeaderVisible = true;

  bool get isHeaderVisible => _isHeaderVisible;

  void toggleHeader() {
    _isHeaderVisible = !_isHeaderVisible;
    notifyListeners();
  }

  void showHeader() {
    if (!_isHeaderVisible) {
      _isHeaderVisible = true;
      notifyListeners();
    }
  }

  void hideHeader() {
    if (_isHeaderVisible) {
      _isHeaderVisible = false;
      notifyListeners();
    }
  }
} 