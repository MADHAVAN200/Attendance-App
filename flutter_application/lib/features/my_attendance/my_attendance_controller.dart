import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyAttendanceController extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  
  // Mock data for now, as it was hardcoded in the original screen
  final List<Map<String, dynamic>> _mockRecords = [
    {
      'timeIn': '07:49 AM',
      'inStatus': 'LATE 859M',
      'inAddress': '2VJ4+QR5, KA Subramaniam Rd, Matunga East, Mumbai, Maharashtra 400019, India',
      'timeOut': '09:49 PM',
      'outStatus': 'PRESENT',
      'outAddress': '2VJ4+QR5, KA Subramaniam Rd, Matunga East, Mumbai, Maharashtra 400019, India',
      'isComplete': true,
      'avatarUrl': 'https://i.pravatar.cc/150?u=1'
    },
    {
      'timeIn': '06:05 AM',
      'inStatus': 'LATE 155M',
      'inAddress': '2, Mukundrao Ambedkar Rd, Nirmal Nagar, Kokri Agar, Sion, Mumbai, Maharashtra 400037, India',
      'timeOut': null,
      'outStatus': null,
      'outAddress': null,
      'isComplete': false,
      'avatarUrl': 'https://i.pravatar.cc/150?u=1'
    },
  ];

  DateTime get selectedDate => _selectedDate;
  List<Map<String, dynamic>> get records => _mockRecords;

  void updateDate(DateTime date) {
    if (date != _selectedDate) {
      _selectedDate = date;
      notifyListeners();
    }
  }

  void previousDay() {
    updateDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  void nextDay() {
    updateDate(_selectedDate.add(const Duration(days: 1)));
  }

  // Placeholder actions
  void handleTimeIn() {
    debugPrint('Time In Pressed');
  }

  void handleTimeOut() {
    debugPrint('Time Out Pressed');
  }
}
