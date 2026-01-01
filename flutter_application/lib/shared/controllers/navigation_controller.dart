import 'package:flutter/material.dart';

class NavigationController extends ChangeNotifier {
  int _selectedIndex = 0;
  
  int get selectedIndex => _selectedIndex;

  final List<String> _titles = [
    'Dashboard',
    'Live Attendance',
    'My Attendance',
    'Employees',
    'Reports & Exports',
    'Holidays',
    'Policy Engine',
    'Geo Fencing',
    'My Profile',
  ];

  String get currentTitle => _titles[_selectedIndex < _titles.length ? _selectedIndex : 0];

  void setIndex(int index) {
    if (index != _selectedIndex && index >= 0 && index < _titles.length) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}
