import 'package:flutter/material.dart';

class TabProvider extends ChangeNotifier {
  int _currentTabIndex = 0;
  String _hintText = 'Search';
  String _dstiSearchQuery = '';
  String _assessmentSearchQuery = '';
  String _toolsSearchQuery = '';
  bool _textFocus = false;

  int get currentTabIndex => _currentTabIndex;
  String get hintText => _hintText;
  String get dstiSearchQuery => _dstiSearchQuery;
  String get assessmentSearchQuery => _assessmentSearchQuery;
  String get toolsSearchQuery => _toolsSearchQuery;
  bool get textFocus => _textFocus;

  Future<void> setCurrentTabIndex(int index) async {
    _currentTabIndex = index;
    dataSearch(index);
    _resetQueries();
    notifyListeners();
  }

  // reset the search queries
  _resetQueries() {
    _dstiSearchQuery = '';
    _assessmentSearchQuery = '';
    _toolsSearchQuery = '';
    // this is for clearing the search field after tab change
    _textFocus = true;
    // imidiately return to false
    Future.delayed(const Duration(milliseconds: 100), () {
      _textFocus = false;
    });
  }

  Future<void> setSearchHintText(String text) async {
    _hintText = text;
    notifyListeners();
  }

  Future<void> setSearchQuery(String query) async {
    if (_currentTabIndex == 0) {
      _dstiSearchQuery = query;
    } else if (_currentTabIndex == 1) {
      _assessmentSearchQuery = query;
    } else if (_currentTabIndex == 2) {
      _toolsSearchQuery = query;
    }

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
