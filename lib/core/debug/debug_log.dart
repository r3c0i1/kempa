// lib/core/debug/debug_log.dart

import 'package:flutter/material.dart';

class DebugLog extends ChangeNotifier {
  static final DebugLog instance = DebugLog._();
  DebugLog._();

  final List<String> _logs = [];

  List<String> get logs => List.unmodifiable(_logs);

  void log(String message) {
    final time = DateTime.now().toString().substring(11, 19);
    _logs.add('[$time] $message');

    if (_logs.length > 50) {
      _logs.removeAt(0);
    }

    notifyListeners();
    debugPrint(message);
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }
}