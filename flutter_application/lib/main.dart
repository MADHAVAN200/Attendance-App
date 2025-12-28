import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'models/attendance_entry.dart';
import 'widgets/attendance_button.dart';
import 'widgets/attendance_card.dart';
import 'widgets/session_card.dart';
import 'package:intl/intl.dart';
import 'widgets/custom_dialog.dart';
import 'services/permission_service.dart';
import 'services/camera_service.dart';
import 'services/api_service.dart';
import 'services/cache_service.dart';
import 'screens/camera_screen.dart';
import 'screens/login_screen.dart';
import 'screens/calendar_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await CameraService.initialize();
  await AttendanceCacheService.initialize();
  
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MANO',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E1317),
        cardColor: const Color(0xFF1E2630),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0E1317),
          selectedItemColor: Color(0xFF7A4BFF),
          unselectedItemColor: Colors.grey,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const AttendanceHomePage(),
      },
    );
  }
}

// Wrapper to check authentication status
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ApiService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7A4BFF),
              ),
            ),
          );
        }

        if (snapshot.data == true) {
          return const AttendanceHomePage();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class AttendanceHomePage extends StatefulWidget {
  const AttendanceHomePage({super.key});

  @override
  State<AttendanceHomePage> createState() => _AttendanceHomePageState();
}

class _AttendanceHomePageState extends State<AttendanceHomePage> {
  final List<AttendanceDay> _days = [];
  int _selectedIndex = 0;
  bool _permissionsGranted = false;
  bool _isCheckingPermissions = true;
  bool _isLoadingRecords = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadCachedData();
    _loadAttendanceRecords();
  }

  // Load cached data first for instant display (optimized)
  void _loadCachedData() {
    if (AttendanceCacheService.hasCache()) {
      final cachedDays = AttendanceCacheService.getCachedAttendance();
      if (cachedDays.isNotEmpty) {
        setState(() {
          _days.clear();
          _days.addAll(cachedDays);
        });
        print('✅ Loaded ${_days.length} days from cache');
        return;
      }
    }
    _initializeToday();
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isCheckingPermissions = true;
    });

    final permissions = await PermissionService.requestAllPermissions();
    
    final cameraGranted = permissions['camera'] ?? false;
    final locationGranted = permissions['location'] ?? false;
    final allGranted = cameraGranted && locationGranted;

    // Batch setState for single rebuild
    setState(() {
      _permissionsGranted = allGranted;
      _isCheckingPermissions = false;
    });

    if (!allGranted && mounted) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'This app requires camera and location permissions to function properly. '
          'Please grant the permissions to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestPermissions();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _initializeToday() {
    final today = DateTime.now();
    final attendanceDay = AttendanceDay(
      date: DateTime(today.year, today.month, today.day),
    );
    setState(() {
      _days.add(attendanceDay);
    });
  }

  // Helper function to parse JavaScript Date string format
  DateTime? _parseJSDate(String? dateString) {
    if (dateString == null) return null;
    
    try {
      // Try standard ISO format first
      return DateTime.parse(dateString);
    } catch (e) {
      try {
        // Handle JavaScript Date string format: "Fri Dec 05 2025 14:04:13 GMT+0000 (Coordinated Universal Time)"
        // Extract the ISO-like part before GMT
        final parts = dateString.split(' GMT');
        if (parts.isEmpty) return null;
        
        // Parse the date part: "Fri Dec 05 2025 14:04:13"
        final datePart = parts[0].trim();
        final dateComponents = datePart.split(' ');
        
        if (dateComponents.length >= 5) {
          final month = _monthToNumber(dateComponents[1]);
          final day = int.parse(dateComponents[2]);
          final year = int.parse(dateComponents[3]);
          final timeParts = dateComponents[4].split(':');
          
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          final second = int.parse(timeParts[2]);
          
          
          // Use DateTime(...) constructor to treat these components as Local Time
          // This fixes the issue where the server sends Local Time labeled as GMT,
          // which was causing a double-offset (Next Day) issue.
          return DateTime(year, month, day, hour, minute, second);
        }
      } catch (e2) {
        print('Error parsing JS date: $e2');
      }
    }
    return null;
  }

  int _monthToNumber(String month) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
      'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
      'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[month] ?? 1;
  }

  // Helper to extract time string directly from JS Date string
  String? _extractTimeFromJSDate(String? dateString) {
    if (dateString == null) return null;
    try {
      // Input: "Fri Dec 05 2025 14:04:13 GMT+0000 (Coordinated Universal Time)"
      // Extract "14:04:13"
      final parts = dateString.split(' ');
      if (parts.length >= 5) {
        final timePart = parts[4]; // Should be HH:mm:ss
        final timeComponents = timePart.split(':');
        
        if (timeComponents.length >= 2) {
          int hour = int.tryParse(timeComponents[0]) ?? 0;
          int minute = int.tryParse(timeComponents[1]) ?? 0;
          
          final period = hour >= 12 ? 'PM' : 'AM';
          if (hour > 12) hour -= 12;
          if (hour == 0) hour = 12;
          
          final minuteStr = minute.toString().padLeft(2, '0');
          return '$hour:$minuteStr $period';
        }
      }
    } catch (e) {
      print('Error extracting time string: $e');
    }
    return null;
  }

  Future<void> _loadAttendanceRecordsOld() async {
    setState(() {
      _isLoadingRecords = true;
    });

    try {
      print('📥 Loading attendance records...');
      final result = await ApiService.getAttendanceRecords();
      
      print('📦 API Response: ${result['success']}');
      
      if (result['success'] && mounted) {
        final data = result['data'];
        print('📊 Data type: ${data.runtimeType}, Length: ${data is List ? data.length : 'N/A'}');
        
        // Parse records from new API format
        if (data is List) {
          _days.clear();
          
          // Group records by date
          Map<DateTime, List<TimeEntry>> entriesByDate = {};
          
          for (var record in data) {
            try {
              print('🔍 Processing record: ${record['attendance_id']}');
              
              // Parse time_in
              if (record['time_in'] != null) {
                final timeIn = _parseJSDate(record['time_in']);
                if (timeIn != null) {
                  final localTime = timeIn.toLocal();
                  final dateOnly = DateTime(localTime.year, localTime.month, localTime.day);
                  
                  entriesByDate.putIfAbsent(dateOnly, () => []);
                  
                  entriesByDate[dateOnly]!.add(TimeEntry(
                  timestamp: localTime,
                  type: EntryType.timeIn,
                  locationName: 'Location', // You can add geocoding here if needed
                  latitude: record['time_in_lat'] != null ? double.tryParse(record['time_in_lat'].toString()) : null,
                  longitude: record['time_in_lng'] != null ? double.tryParse(record['time_in_lng'].toString()) : null,
                  photoUrl: record['time_in_image_key'],
                  displayTime: _extractTimeFromJSDate(record['time_in']),
                ));
                print('✅ Added time_in entry at $localTime');
              }
            }
            
            // Parse time_out
            if (record['time_out'] != null) {
              final timeOut = _parseJSDate(record['time_out']);
              if (timeOut != null) {
                final localTime = timeOut.toLocal();
                final dateOnly = DateTime(localTime.year, localTime.month, localTime.day);
                
                entriesByDate.putIfAbsent(dateOnly, () => []);
                
                entriesByDate[dateOnly]!.add(TimeEntry(
                  timestamp: localTime,
                  type: EntryType.timeOut,
                  locationName: 'Location',
                  latitude: record['time_out_lat'] != null ? double.tryParse(record['time_out_lat'].toString()) : null,
                  longitude: record['time_out_lng'] != null ? double.tryParse(record['time_out_lng'].toString()) : null,
                  photoUrl: record['time_out_image_key'],
                  displayTime: _extractTimeFromJSDate(record['time_out']),
                ));
                print('✅ Added time_out entry at $localTime');
              }
            }
            } catch (e) {
              print('❌ Error parsing record: $e');
              print('Raw time_in: ${record['time_in']}');
            }
          }
          
          print('📅 Total dates with entries: ${entriesByDate.length}');
          
          // Create AttendanceDay objects
          entriesByDate.forEach((date, entries) {
            // Sort entries by timestamp
            entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            // _days.add(AttendanceDay(date: date, entries: entries));
            print('📆 Created day for $date with ${entries.length} entries');
          });
          
          // Sort days by date (newest first)
          _days.sort((a, b) => b.date.compareTo(a.date));
        }
        
        // Ensure today exists
        final today = DateTime.now();
        final dateOnly = DateTime(today.year, today.month, today.day);
        final hasToday = _days.any((d) => d.date == dateOnly);
        
        if (!hasToday) {
          _days.insert(0, AttendanceDay(date: dateOnly));
          print('➕ Added empty day for today');
        }
        
        print('✨ Total days loaded: ${_days.length}');
        
        // Save to cache
        await AttendanceCacheService.saveAttendance(_days);
        
        setState(() {});
        print('🔄 UI updated');
      }
    } catch (e) {
      print('❌ Error loading records: $e');
    } finally {
      setState(() {
        _isLoadingRecords = false;
      });
    }
  }

  Future<void> _loadAttendanceRecords() async {
    setState(() {
      _isLoadingRecords = true;
    });

    try {
      print('📥 Loading attendance records...');
      final result = await ApiService.getAttendanceRecords();
      
      print('📦 API Response: ${result['success']}');
      
      if (result['success'] && mounted) {
        final data = result['data'];
        print('📊 Data type: ${data.runtimeType}, Length: ${data is List ? data.length : 'N/A'}');
        
        // Parse records from new API format
        if (data is List) {
          _days.clear();
          
          // Group records by date
          Map<DateTime, List<AttendanceSession>> sessionsByDate = {};
          final baseUrl = 'https://erp.mano.co.in/'; // Base URL for images
          
          for (var record in data) {
            try {
              print('🔍 Processing record: ${record['attendance_id']}');
              
              TimeEntry? timeInEntry;
              TimeEntry? timeOutEntry;
              
              // Parse time_in
              if (record['time_in'] != null) {
                final timeIn = _parseJSDate(record['time_in']);
                
                if (timeIn != null) {
                  final localTime = timeIn;
                  
                  // Get photo URL (prefer full S3 URL, fallback to constructing from key)
                  String? photoUrl;
                  if (record['time_in_image'] != null && record['time_in_image'].toString().isNotEmpty) {
                    photoUrl = record['time_in_image'].toString();
                  } else if (record['time_in_image_key'] != null) {
                    photoUrl = '$baseUrl${record['time_in_image_key']}';
                  }
                  
                  // Try to get address from backend response
                  String locName = 'Location';
                  if (record['time_in_address'] != null && record['time_in_address'].toString().isNotEmpty) {
                    locName = record['time_in_address'].toString();
                  } else if (record['address'] != null && record['address'].toString().isNotEmpty) {
                    // Fallback to generic address if available (mostly for single-action responses)
                    locName = record['address'].toString();
                  }

                  if (photoUrl != null) {
                    print('📸 Time-in photo URL: $photoUrl');
                  }
                  timeInEntry = TimeEntry(
                    timestamp: localTime,
                    type: EntryType.timeIn,
                    locationName: locName, 
                    latitude: record['time_in_lat'] != null ? double.tryParse(record['time_in_lat'].toString()) : null,
                    longitude: record['time_in_lng'] != null ? double.tryParse(record['time_in_lng'].toString()) : null,
                    photoUrl: photoUrl,
                    displayTime: _extractTimeFromJSDate(record['time_in']),
                  );
                }
              }
              
              // Parse time_out
              if (record['time_out'] != null) {
                final timeOut = _parseJSDate(record['time_out']);
                if (timeOut != null) {
                  final localTime = timeOut;
                  
                  // Get photo URL (prefer full S3 URL, fallback to constructing from key)
                  String? photoUrl;
                  if (record['time_out_image'] != null && record['time_out_image'].toString().isNotEmpty) {
                    photoUrl = record['time_out_image'].toString();
                  } else if (record['time_out_image_key'] != null) {
                    photoUrl = '$baseUrl${record['time_out_image_key']}';
                  }
                  
                  // Try to get address from backend response
                  String locName = 'Location';
                  if (record['time_out_address'] != null && record['time_out_address'].toString().isNotEmpty) {
                    locName = record['time_out_address'].toString();
                  }

                  if (photoUrl != null) {
                    print('📸 Time-out photo URL: $photoUrl');
                  }
                  timeOutEntry = TimeEntry(
                    timestamp: localTime,
                    type: EntryType.timeOut,
                    locationName: locName,
                    latitude: record['time_out_lat'] != null ? double.tryParse(record['time_out_lat'].toString()) : null,
                    longitude: record['time_out_lng'] != null ? double.tryParse(record['time_out_lng'].toString()) : null,
                    photoUrl: photoUrl,
                    displayTime: _extractTimeFromJSDate(record['time_out']),
                  );
                }
              }
              
              // Create session if we have at least one entry
              if (timeInEntry != null || timeOutEntry != null) {
                final dateRef = timeInEntry?.timestamp ?? timeOutEntry!.timestamp;
                final dateOnly = DateTime(dateRef.year, dateRef.month, dateRef.day);
                
                sessionsByDate.putIfAbsent(dateOnly, () => []);
                sessionsByDate[dateOnly]!.add(AttendanceSession(
                  checkIn: timeInEntry,
                  checkOut: timeOutEntry,
                ));
              }
              
            } catch (e) {
              print('❌ Error parsing record: $e');
            }
          }
          
          print('📅 Total dates with sessions: ${sessionsByDate.length}');
          
          // Create AttendanceDay objects
          sessionsByDate.forEach((date, sessions) {
            // Sort sessions by recent time (descending)
            sessions.sort((a, b) => b.date.compareTo(a.date));
            
            _days.add(AttendanceDay(date: date, sessions: sessions));
            print('📆 Created day for $date with ${sessions.length} sessions');
          });
          
          // Sort days by date (newest first)
          _days.sort((a, b) => b.date.compareTo(a.date));
        }
        
        // Ensure today exists
        final today = DateTime.now();
        final dateOnly = DateTime(today.year, today.month, today.day);
        final hasToday = _days.any((d) => d.date == dateOnly);
        
        if (!hasToday) {
          _days.insert(0, AttendanceDay(date: dateOnly));
          print('➕ Added empty day for today');
        }
        
        
        // Save to cache
        await AttendanceCacheService.saveAttendance(_days);
      }
    } catch (e) {
      print('❌ Error loading records: $e');
    } finally {
      // Single setState for final state update
      if (mounted) {
        setState(() {
          _isLoadingRecords = false;
        });
      }
    }
  }

  Future<Position> _determinePosition() async {
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
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }



  bool _hasActiveSession() {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    
    print('🔍 Checking for active session on date: $dateOnly');
    print('📊 Total days in memory: ${_days.length}');
    
    // Find today's data
    final todayIndex = _days.indexWhere((d) => 
      d.date.year == dateOnly.year && 
      d.date.month == dateOnly.month && 
      d.date.day == dateOnly.day
    );
    
    if (todayIndex == -1) {
      print('❌ No data found for today');
      return false;
    }
    
    final todayData = _days[todayIndex];
    print('📅 Today\'s sessions count: ${todayData.sessions.length}');

    // Check if there's any session with check-in but no check-out
    if (todayData.sessions.isEmpty) {
      print('❌ No sessions today');
      return false;
    }
    
    // Check the most recent session (first in list because sorted descending)
    // If it has check-in but no check-out, it's active
    final latestSession = todayData.sessions.first;
    final hasCheckIn = latestSession.checkIn != null;
    final hasCheckOut = latestSession.checkOut != null;
    
    print('🔎 Latest session - CheckIn: $hasCheckIn, CheckOut: $hasCheckOut');
    
    final isActive = hasCheckIn && !hasCheckOut;
    print('✅ Active session: $isActive');
    
    return isActive;
  }

  Future<void> _openCameraAndAddEntry(EntryType type) async {
    if (!_permissionsGranted) {
      _showPermissionDialog();
      return;
    }

    // Refresh data from server before checking session status
    print('🔄 Refreshing attendance data before validation...');
    await _loadAttendanceRecords();
    print('✅ Data refresh complete');

    // Check if there's an active session (checked in but not checked out)
    if (type == EntryType.timeIn && _hasActiveSession()) {
      if (mounted) {
        await CustomDialog.showError(
          context,
          title: 'Already Checked In',
          message: 'Please check out from your current session before checking in again.',
          buttonText: 'OK',
        );
      }
      return;
    }

    if (type == EntryType.timeOut) {
      if (!_hasActiveSession()) {
        if (mounted) {
          await CustomDialog.showError(
            context,
            title: 'No Active Session',
            message: 'Please check in first before checking out.',
            buttonText: 'OK',
          );
        }
        return;
      }
    }

    // Start fetching location in the background IMMEDIATELY
    // This runs in parallel while the user is taking the photo
    final locationFuture = _determinePosition().then((pos) async {
      // Backend provides location, so we just send coordinates
      return {'pos': pos};
    });

    try {
      // Open camera immediately
      // Optimized image parameters for faster upload: 800x800 max, 70% quality
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      
      final photoPath = photo?.path;

      // If user cancelled, return
      if (photoPath == null) {
        return;
      }

      // Show processing indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF7A4BFF),
            ),
          ),
        );
      }

      // Wait for location
      final locationData = await locationFuture;
      final pos = locationData['pos'] as Position;

      // Update loading text to uploading
      if (mounted) {
        Navigator.of(context).pop(); // remove spinner
        CustomDialog.showLoading(
          context,
          message: type == EntryType.timeIn 
              ? 'Uploading Time In...' 
              : 'Uploading Time Out...',
        );
      }

      // Call API (backend will provide location name)
      final result = type == EntryType.timeIn
          ? await ApiService.timeIn(
              photoPath: photoPath,
              latitude: pos.latitude,
              longitude: pos.longitude,
              locationName: '',  // Backend provides this
            )
          : await ApiService.timeOut(
              photoPath: photoPath,
              latitude: pos.latitude,
              longitude: pos.longitude,
              locationName: '',  // Backend provides this
            );

      // Close uploading dialog
      if (mounted) Navigator.of(context).pop();

      if (result['success']) {
        if (mounted) {
          await CustomDialog.showSuccess(
            context,
            title: type == EntryType.timeIn ? 'Time In Recorded' : 'Time Out Recorded',
            message: type == EntryType.timeIn
                ? 'Your check-in has been recorded successfully.'
                : 'Your check-out has been recorded successfully.',
            buttonText: 'OK',
          );
        }
        await _loadAttendanceRecords();
      } else {
        if (mounted) {
          final friendlyMessage = _getUserFriendlyErrorMessage(result['message'], type);
          await CustomDialog.showError(
            context,
            title: 'Recording Failed',
            message: friendlyMessage,
            buttonText: 'OK',
          );
        }
      }
    } catch (e) {
      print('❌ Error during time in/out: $e');
      
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (!mounted) return;
      
      String errorTitle = 'Error';
      String errorMessage = 'An unexpected error occurred. Please try again.';
      
      if (e.toString().contains('Location services are disabled')) {
        errorTitle = 'Location Services Disabled';
        errorMessage = 'Please enable GPS/Location services on your device to record attendance.';
      } else if (e.toString().contains('Location permissions')) {
        errorTitle = 'Location Permission Required';
        errorMessage = 'Please grant location permission to this app in your device settings.';
      }
      
      await CustomDialog.showError(
        context,
        title: errorTitle,
        message: errorMessage,
        buttonText: 'OK',
      );
    }
  }

  String _getUserFriendlyErrorMessage(String? backendMessage, EntryType type) {
    if (backendMessage == null || backendMessage.isEmpty) {
      return 'Failed to record attendance. Please try again.';
    }

    final lowerMessage = backendMessage.toLowerCase();

    // Check for common error patterns
    if (lowerMessage.contains('already') && lowerMessage.contains('time') && lowerMessage.contains('in')) {
      return 'You have already checked in today.';
    }
    
    if (lowerMessage.contains('already') && lowerMessage.contains('time') && lowerMessage.contains('out')) {
      return 'You have already checked out today.';
    }

    if (lowerMessage.contains('not') && lowerMessage.contains('checked') && lowerMessage.contains('in')) {
      return 'Please check in first before checking out.';
    }

    if (lowerMessage.contains('invalid') || lowerMessage.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    }

    if (lowerMessage.contains('network') || lowerMessage.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }

    if (lowerMessage.contains('location') || lowerMessage.contains('gps')) {
      return 'Unable to get your location. Please enable location services.';
    }

    // Default user-friendly message
    return type == EntryType.timeIn
        ? 'Unable to record check-in. Please try again.'
        : 'Unable to record check-out. Please try again.';
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.clearAuthToken();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              // color: const Color(0xFF7A4BFF), // Removed background color
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/mano.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attendance',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              SizedBox(height: 4),
              Text(
                'Track your timein and timeout',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFD4A574),
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: AttendanceButton(
              icon: Icons.login,
              label: 'Time In',
              background: const Color(0xFF7A4BFF),
              foreground: Colors.white,
              onPressed: () => _openCameraAndAddEntry(EntryType.timeIn),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AttendanceButton(
              icon: Icons.logout,
              label: 'Time Out',
              background: const Color(0xFF2A3036),
              foreground: Colors.white,
              onPressed: () => _openCameraAndAddEntry(EntryType.timeOut),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayList() {
    if (_isLoadingRecords) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF7A4BFF),
        ),
      );
    }

    // Find today's data
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    
    AttendanceDay? todayData;
    try {
      todayData = _days.firstWhere((d) => 
        d.date.year == today.year && 
        d.date.month == today.month && 
        d.date.day == today.day
      );
    } catch (e) {
      todayData = null;
    }

    if (todayData == null || todayData.sessions.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Today, ${DateFormat('d MMM yyyy').format(today)}',
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w600,
                color: Colors.white
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'No attendance recorded yet',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAttendanceRecords,
      color: const Color(0xFF7A4BFF),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: todayData.sessions.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Today, ${DateFormat('d MMM yyyy').format(today)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey
                  ),
                ),
              ),
            );
          }
          // Adjust index for header
          final session = todayData!.sessions[index - 1];
          return SessionCard(session: session);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermissions) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7A4BFF),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await CustomDialog.showError(
          context,
          title: 'Exit App',
          message: 'Are you sure you want to exit?',
          buttonText: 'Exit',
        );
        return false; // Always return false, dialog handles navigation
      },
      child: Scaffold(
        body: SafeArea(
          child: _selectedIndex == 0 ? _buildHomeView() : _buildCalendarView(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          backgroundColor: const Color(0xFF1E2630),
          selectedItemColor: const Color(0xFF7A4BFF),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
          ],
        ),
      ),
    );
  }

  // Home view wrapper
  Widget _buildHomeView() {
    return Column(
      children: [
        _buildHeader(),
        _buildButtons(),
        const SizedBox(height: 6),
        Expanded(child: _buildTodayList()),
      ],
    );
  }

  // Calendar view wrapper
  Widget _buildCalendarView() {
    return CalendarScreen(
      days: _days,
      onLogout: _handleLogout,
    );
  }
}


