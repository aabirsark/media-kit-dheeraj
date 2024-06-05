// lib/controllers/sidebar_controller.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';

class MediaXSidebarController with ChangeNotifier {
  MediaXSidebarController._internal(); // Private constructor to prevent external instantiation

  static final MediaXSidebarController _instance =
      MediaXSidebarController._internal(); // Singleton instance

  factory MediaXSidebarController() {
    // Factory constructor that returns the single instance
    return _instance;
  }

  bool _isOpen = false;
  Widget? _child;

  Widget? get child => _child;
  bool get isOpen => _isOpen;

  void toggleSidebar(Widget? child) {
    _isOpen = !_isOpen;
    _child = child;
    notifyListeners();
  }

  void openSidebar() {
    _isOpen = true;
    notifyListeners();
  }

  void closeSidebar() {
    _isOpen = false;
    notifyListeners();
  }

  static of(BuildContext context) {}
}
