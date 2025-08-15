import 'package:flutter/material.dart';
import 'dart:html' as html;

class LocaleProvider extends ChangeNotifier {
  List<String> _localePriority = ['KOR', 'ENG', 'JPN'];

  List<String> get localePriority => _localePriority;

  LocaleProvider() {
    _loadFromLocalStorage();
  }

  void _loadFromLocalStorage() {
    final localePriorityStr = html.window.localStorage['localePriority'];
    
    if (localePriorityStr != null && localePriorityStr.isNotEmpty) {
      _localePriority = localePriorityStr.split(',').where((s) => s.isNotEmpty).toList();
    }
  }

  void updateLocalePriority(List<String> priority) {
    _localePriority = priority;
    html.window.localStorage['localePriority'] = priority.join(',');
    notifyListeners();
  }
}