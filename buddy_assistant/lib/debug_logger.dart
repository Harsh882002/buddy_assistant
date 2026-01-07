import 'package:flutter/foundation.dart';

class DebugLogger extends ChangeNotifier {
  static final DebugLogger _instance = DebugLogger._internal();
  factory DebugLogger() => _instance;
  DebugLogger._internal();

  final List<String> _logs = [];

  List<String> get logs => List.unmodifiable(_logs);

  void log(String message) {
    final timestamp = DateTime.now().toIso8601String().split('T')[1].substring(0, 8);
    final formatted = "[$timestamp] $message";
    print(formatted); // Console
    _logs.add(formatted); // UI List
    if (_logs.length > 50) _logs.removeAt(0); // Cap size
    notifyListeners();
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }
}
