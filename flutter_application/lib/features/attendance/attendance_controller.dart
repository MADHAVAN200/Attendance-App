import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

import 'models/attendance_session.dart';
import 'services/attendance_service.dart';
import 'camera_capture_screen.dart';

class AttendanceController extends ChangeNotifier {
  final AttendanceService _service = AttendanceService();
  
  DateTime _selectedDate = DateTime.now();
  List<AttendanceSession> _sessions = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  DateTime get selectedDate => _selectedDate;
  List<AttendanceSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;

  AttendanceController() {
    _fetchRecords();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  Future<void> _fetchRecords() async {
    _setLoading(true);
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      // Fetch for selected date (start=end)
      final sessions = await _service.getMyRecords(formattedDate, formattedDate);
      _sessions = sessions;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching records: $e');
      _sessions = [];
      _isLoading = false;
      notifyListeners();
      // Error handling should ideally be exposed via a stream or callback, 
      // but for now we'll just log it here.
    }
  }

  void updateDate(DateTime date) {
    if (date != _selectedDate) {
      _selectedDate = date;
      _fetchRecords();
    }
  }

  void previousDay() {
    updateDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  void nextDay() {
    updateDate(_selectedDate.add(const Duration(days: 1)));
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> handleAction(BuildContext context, String type) async {
    // 1. Open Camera
    // Note: Navigation in controller is generally discouraged but keeping it here for simple refactor
    // Ideally this should be a callback or service.
    // Assuming context is passed for navigation and snackbar.
    
    // Check if widget is mounted before navigation, but controller doesn't know about mounting directly.
    // We'll rely on the caller to handle unmounted state if possible or check internally if we tracked context.
    
    final XFile? image = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraCaptureScreen()),
    );

    if (image == null) return; 
    
    _setSubmitting(true);

    try {
        // 2. Get Location
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
             throw Exception('Location services are disabled.');
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
                 throw Exception('Location permissions are denied');
            }
        }
        
        if (permission == LocationPermission.deniedForever) {
             throw Exception('Location permissions are permanently denied, we cannot request permissions.');
        }

        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        
        // Strict Accuracy Check (< 500m)
        if (position.accuracy > 500) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Location accuracy is low (${position.accuracy.round()}m). Unacceptable quality (<500m required).'),
                      backgroundColor: Colors.red
                  ),
              );
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enable GPS/Wi-Fi for better accuracy.'),
                      duration: Duration(seconds: 4),
                  ),
              );
            }
            return; // Block submission
        }

        // 3. Submit to API
        final imageFile = File(image.path);
        
        if (type == 'IN') {
             await _service.timeIn(
                 latitude: position.latitude,
                 longitude: position.longitude,
                 imageFile: imageFile,
                 accuracy: position.accuracy
             );
        } else {
             await _service.timeOut(
                 latitude: position.latitude,
                 longitude: position.longitude,
                 imageFile: imageFile,
                 accuracy: position.accuracy
             );
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Successfully Checked $type!'), backgroundColor: Colors.green),
          );
        }
        
        // 4. Refresh List
        _fetchRecords();

    } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
    } finally {
        _setSubmitting(false);
    }
  }
}
