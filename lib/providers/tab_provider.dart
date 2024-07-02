import 'package:flutter/material.dart';

class TabProvider extends ChangeNotifier {
  int _currentTabIndex = 0;
  String _hintText = 'Search';

  int get currentTabIndex => _currentTabIndex;
  String get hintText => _hintText;

  Future<void> setCurrentTabIndex(int index) async {
    _currentTabIndex = index;
    dataSearch(currentTabIndex);
    notifyListeners();
  }

  Future<void> setSearchHintText(String text) async {
    _hintText = text;
    notifyListeners();
  }

  dataSearch(int currentTabIndex) {
    switch (currentTabIndex) {
      case 0:
        setSearchHintText('Daily Safety Task Instructions...');
        break;
      case 1:
        setSearchHintText('Risk Assessments...');
        break;
      case 2:
        setSearchHintText('Tools...');
        break;
      default:
        ''; // Default hint text if no match is found
    }
  }
}
