import 'dart:developer';

import 'package:flutter/material.dart';

class TabProvider extends ChangeNotifier {
  int _currentTabIndex = 0;

  int get currentTabIndex => _currentTabIndex;

  void setCurrentTabIndex(int index) {
    _currentTabIndex = index;

    notifyListeners();
    log('tabIndex: $currentTabIndex');
  }
}
