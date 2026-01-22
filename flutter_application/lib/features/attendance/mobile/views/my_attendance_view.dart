import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/glass_date_picker.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../../shared/services/auth_service.dart';
import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';

class MobileMyAttendanceContent extends StatefulWidget {
  const MobileMyAttendanceContent({super.key});

  @override
  State<MobileMyAttendanceContent> createState() => _MobileMyAttendanceContentState();
}

class _MobileMyAttendanceContentState extends State<MobileMyAttendanceContent> {
  late AttendanceService _attendanceService;
  List<AttendanceRecord> _records = [];
  final Map<String, List<AttendanceRecord>> _recordsCache = {}; // Cache
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final dio = Provider.of<AuthService>(context, listen: false).dio;
    _attendanceService = AttendanceService(dio);
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    if (!mounted) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    // Check Cache
    if (_recordsCache.containsKey(dateStr)) {
      if (mounted) {
        setState(() {
          _records = _recordsCache[dateStr]!;
          _isLoading = false;
        });
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = await _attendanceService.getMyRecords(fromDate: dateStr, toDate: dateStr);
      if (mounted) {
        setState(() {
          _records = data;
          _recordsCache[dateStr] = data; // Store in cache
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching records: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location services are disabled.")));
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permission denied.")));
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permission permanently denied.")));
      return null;
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _handleAttendanceAction(bool isTimeIn) async {
    // 1. Get Location
    final position = await _getCurrentLocation();
    if (position == null) return;

    // 1. Permission Check with Settings Prompt
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (status.isPermanentlyDenied) {
        if (mounted) {
           CustomDialog.show(
             context: context,
             title: "Permission Required",
             message: "Camera access is needed to mark attendance. Please enable it in settings.",
             positiveButtonText: "Open Settings",
             onPositivePressed: () {
               Navigator.pop(context); // Close dialog
               openAppSettings();
             },
             negativeButtonText: "Cancel",
             onNegativePressed: () => Navigator.pop(context),
             icon: Icons.camera_alt_outlined,
           );
        }
        return;
      }
      if (!status.isGranted) return; // Denied but not permanently
    }

    // 2. Capture Selfie (System Camera)
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera, 
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 600, 
        imageQuality: 80,
      );
      
      if (photo == null) return; // User canceled

      // Show loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // 3. Submit
      try {
        if (isTimeIn) {
          await _attendanceService.timeIn(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy, // ADDED
            imageFile: File(photo.path),
          );
        } else {
          await _attendanceService.timeOut(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy, // ADDED
            imageFile: File(photo.path),
          );
        }
        
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isTimeIn ? "Time In Successful!" : "Time Out Successful!"), backgroundColor: Colors.green));
          
          // Invalidate cache for today as data changed
          final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
          _recordsCache.remove(todayStr);
          
          _fetchRecords(); // Refresh list
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Camera Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine active state for buttons based on last record
    bool isCheckedIn = false;
    if (_records.isNotEmpty) {
      // Logic: If last record has no Time Out, we are checked in.
      // Assuming records are sorted or we take the latest. Better sorting might be needed API side.
      // Simple logic: Check if ANY record today has no timeOut.
      final activeRecord = _records.any((r) => r.timeOut == null);
      isCheckedIn = activeRecord;
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. Top Actions
        _buildActionButtons(context, isCheckedIn),
        
        const SizedBox(height: 32),

        // 2. Date Selector
        _buildDateSelector(context),

        const SizedBox(height: 16),

        // 3. Attendance History List
        if (_isLoading)
           const Center(child: CircularProgressIndicator())
        else if (_records.isEmpty)
           Center(child: Text("No records for this date", style: GoogleFonts.poppins(color: Colors.grey)))
        else
           ..._records.map((record) => Padding(
             padding: const EdgeInsets.only(bottom: 12),
             child: _buildSessionCard(context, record),
           )),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isCheckedIn) {
    return Column(
      children: [
        // Time In
        _buildLargeActionButton(
          context,
          label: 'Time In',
          subLabel: isCheckedIn ? 'You are currently checked in' : 'Start your shift',
          icon: Icons.login,
          color: const Color(0xFF10B981), // Green
          isActive: !isCheckedIn, 
          onTap: () => _handleAttendanceAction(true),
        ),
        const SizedBox(height: 16),
        // Time Out
        _buildLargeActionButton(
          context,
          label: 'Time Out',
          subLabel: isCheckedIn ? 'End current shift' : 'Not checked in',
          icon: Icons.logout,
          color: const Color(0xFFEF4444), // Red
          isActive: isCheckedIn,
          onTap: () => _handleAttendanceAction(false),
        ),
      ],
    );
  }

  Widget _buildLargeActionButton(BuildContext context, {
    required String label,
    required String subLabel,
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: isActive ? onTap : null, // Disable tap if not active? Or allow for error msg? User requested specific logic.
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        height: 100,
        width: double.infinity,
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isActive ? color.withOpacity(0.2) : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isActive ? color : color.withOpacity(0.7),
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(isActive ? 1.0 : 0.5),
                    ),
                  ),
                  Text(
                    subLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (isActive)
                Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'Activity',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) => GlassDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                onDateSelected: (newDate) {
                  setState(() => _selectedDate = newDate);
                  _fetchRecords();
                },
              ),
            );
          },
          child: GlassContainer(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            borderRadius: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today, 
                  size: 14, 
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Theme.of(context).primaryColor
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEE, dd MMM').format(_selectedDate),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(BuildContext context, AttendanceRecord record) {
    // Colors
    const greenColor = Color(0xFF10B981);
    final statusColor = record.status == 'ABSENT' ? Colors.red : Colors.green;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Timeline Column
            Column(
              children: [
                // Start Dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: greenColor,
                    shape: BoxShape.circle,
                  ),
                ),
                // Line
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.withOpacity(0.3),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
                // End Dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: record.timeOut != null ? Colors.red : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            
            // 2. Info Column (Time & Address)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // IN Info
                  InkWell(
                    onTap: () => _showPunchDetails(
                      context,
                      type: 'TIME IN',
                      time: _formatTime(record.timeIn),
                      location: record.timeInAddress ?? 'Unknown Location',
                      imageUrl: record.timeInImage,
                      icon: Icons.login,
                      accentColor: greenColor,
                    ),
                    child: _buildTimeInfo(
                      context, 
                      time: _formatTime(record.timeIn), 
                      location: record.timeInAddress ?? 'Unknown Location'
                    ),
                  ),
                  
                  const SizedBox(height: 24), // Spacing between In and Out

                  // OUT Info
                  record.timeOut != null 
                    ? InkWell(
                        onTap: () => _showPunchDetails(
                          context,
                          type: 'TIME OUT',
                          time: _formatTime(record.timeOut),
                          location: record.timeOutAddress ?? 'Unknown Location',
                          imageUrl: record.timeOutImage,
                          icon: Icons.logout,
                          accentColor: Colors.red,
                        ),
                        child: _buildTimeInfo(
                          context, 
                          time: _formatTime(record.timeOut), 
                          location: record.timeOutAddress ?? 'Unknown Location' 
                        ),
                      )
                    : Text(
                        'Currently Active',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 3. Images Column (Placeholder or Actual Image)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAvatar(context, record.timeInImage),
                if (record.timeOut != null)
                  _buildAvatar(context, record.timeOutImage),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '--:--';
    try {
      final dt = DateTime.parse(isoTime);
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return 'Err'; 
    }
  }

  Widget _buildTimeInfo(BuildContext context, {required String time, required String location}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          location,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, String? imageUrl) {
    return GestureDetector(
      onTap: imageUrl != null && imageUrl.isNotEmpty ? () {
         showDialog(
           context: context,
           builder: (ctx) => Dialog(
             backgroundColor: Colors.transparent,
             surfaceTintColor: Colors.transparent,
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Container(
                   clipBehavior: Clip.antiAlias,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(16),
                     color: Colors.black,
                   ),
                   child: CachedNetworkImage(
                     imageUrl: imageUrl,
                     fit: BoxFit.contain,
                     placeholder: (context, url) => const SizedBox(height: 200, width: 200, child: Center(child: CircularProgressIndicator())),
                     errorWidget: (context, url, error) => const SizedBox(height: 200, width: 200, child: Icon(Icons.error, color: Colors.white)),
                   ),
                 ),
                 const SizedBox(height: 12),
                 IconButton(
                   onPressed: () => Navigator.pop(ctx),
                   icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.close, color: Colors.black)),
                 ),
               ],
             ),
           ),
         );
      } : null,
      child: Container(
        width: 40,
        height: 40,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Icon(Icons.person, size: 20, color: Colors.grey),
                errorWidget: (context, url, error) => const Icon(Icons.person_off, size: 20, color: Colors.grey),
              )
            : Icon(Icons.person, size: 24, color: Colors.white.withOpacity(0.9)),
      ),
    );
  }

  void _showPunchDetails(
    BuildContext context, {
    required String type,
    required String time,
    required String location,
    required String? imageUrl,
    required IconData icon,
    required Color accentColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: GlassContainer(
          width: 350,
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                       color: accentColor.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Icon(icon, color: accentColor),
                   ),
                   const SizedBox(width: 16),
                   Text(
                     type,
                     style: GoogleFonts.poppins(
                       fontSize: 18,
                       fontWeight: FontWeight.bold,
                       color: Theme.of(context).textTheme.bodyLarge?.color,
                     ),
                   ),
                   const Spacer(),
                   IconButton(
                     onPressed: () => Navigator.pop(context),
                     icon: const Icon(Icons.close),
                   ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Image
              if (imageUrl != null && imageUrl.isNotEmpty)
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.image_not_supported, size: 40, color: Theme.of(context).disabledColor),
                ),
                
              const SizedBox(height: 24),
              
              // Time
              _buildDetailRow(context, Icons.access_time, 'Time', time),
              const SizedBox(height: 16),
              // Location
              _buildDetailRow(context, Icons.place_outlined, 'Location', location),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              Text(
                value, 
                style: GoogleFonts.poppins(
                  fontSize: 15, 
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

