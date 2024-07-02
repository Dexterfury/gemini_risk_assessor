import 'dart:developer';

import 'package:flutter/material.dart';

class TabProvider extends ChangeNotifier {
  int _currentTabIndex = 0;
  String _hintText = 'Search';
  String _searchQuery = '';

  int get currentTabIndex => _currentTabIndex;
  String get hintText => _hintText;
  String get searchQuery => _searchQuery;

  Future<void> setCurrentTabIndex(int index) async {
    _currentTabIndex = index;
    dataSearch(currentTabIndex);
    notifyListeners();
  }

  Future<void> setSearchHintText(String text) async {
    _hintText = text;
    notifyListeners();
  }

  Future<void> setSearchQuery(String query) async {
    log('query: $query');
    _searchQuery = query;
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
