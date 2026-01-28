import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/glass_date_picker.dart';
import '../../../../shared/widgets/attendance_success_dialog.dart';
import '../../../../shared/services/auth_service.dart';
import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import 'late_arrival_dialog_mobile.dart';
import 'correction_request_dialog_mobile.dart';
import '../../providers/attendance_provider.dart';

class MarkAttendanceMobile extends StatefulWidget {
  const MarkAttendanceMobile({super.key});

  @override
  State<MarkAttendanceMobile> createState() => _MarkAttendanceMobileState();
}

class _MarkAttendanceMobileState extends State<MarkAttendanceMobile> {
  late AttendanceService _attendanceService;
  final ImagePicker _picker = ImagePicker();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthService>(context, listen: false);
    _attendanceService = AttendanceService(auth.dio);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(context, listen: false).fetchRecords(_selectedDate);
    });
  }

  Future<void> _fetchRecords() async {
    await Provider.of<AttendanceProvider>(context, listen: false)
        .fetchRecords(_selectedDate, forceRefresh: false);
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
      if (permission == LocationPermission.denied) return null;
    }
    
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
  }

  Future<void> _handleAttendanceAction(bool isTimeIn) async {
    final position = await _getCurrentLocation();
    if (position == null) return;

    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera, 
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 600, 
        imageQuality: 80,
      );
      
      if (photo == null) return;

      if (!mounted) return;
      
      // Helper to show loading
      void showLoading() {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }

      // Helper to perform API call
      Future<void> performApiCall(String? lateReason) async {
        if (isTimeIn) {
          await _attendanceService.timeIn(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            imageFile: File(photo.path),
            lateReason: lateReason,
          );
        } else {
          await _attendanceService.timeOut(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            imageFile: File(photo.path),
          );
        }
      }

      // 1. First Attempt
      showLoading();
      bool success = false;
      String? caughtReasonError;

      try {
        await performApiCall(null);
        success = true;
      } catch (e) {
        // Check for specific "reason" error
        final msg = e.toString().toLowerCase();
        if (isTimeIn && msg.contains("reason")) {
           caughtReasonError = msg;
        } else {
           if (mounted) {
             Navigator.pop(context); // Pop Loading 1
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red));
           }
           return; // Stop here
        }
      }

      if (success) {
        if (mounted) {
          Navigator.pop(context); // Pop Loading 1
          await _showSuccessDialog(isTimeIn);
        }
        return;
      }

      // 2. Handle Late Reason (if applicable)
      if (caughtReasonError != null) {
        if (mounted) Navigator.pop(context); // Pop Loading 1
        
        // Show Reason Dialog
        if (!mounted) return;
        final reason = await LateArrivalDialogMobile.show(context);
        
        if (reason == null || reason.isEmpty) return; // User cancelled

        // 3. Second Attempt with Reason
        if (!mounted) return;
        showLoading(); // Show Loading 2

        try {
          await performApiCall(reason);
          
          if (mounted) {
             Navigator.pop(context); // Pop Loading 2
             await _showSuccessDialog(isTimeIn);
          }
        } catch (e) {
          if (mounted) {
            Navigator.pop(context); // Pop Loading 2
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed with reason: $e"), backgroundColor: Colors.red));
          }
        }
      }

    } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Camera/Location Error: $e")));
    }
  }

  Future<void> _showSuccessDialog(bool isTimeIn) async {
    final timeStr = DateFormat('hh:mm a').format(DateTime.now());
    await AttendanceSuccessDialog.show(
      context, 
      type: isTimeIn ? 'Time In' : 'Time Out', 
      time: timeStr
    );
    
    if (mounted) {
      Provider.of<AttendanceProvider>(context, listen: false).invalidateCache(DateTime.now());
      _fetchRecords(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        final records = provider.records;
        final isLoading = provider.isLoading;

        bool isCheckedIn = false;
        if (records.isNotEmpty) {
           isCheckedIn = records.any((r) => r.timeOut == null);
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildActionButtons(context, isCheckedIn),
            const SizedBox(height: 32),
            _buildDateSelector(context, records),
            const SizedBox(height: 16),
            if (isLoading)
               const Center(child: CircularProgressIndicator())
            else if (records.isEmpty)
               Center(child: Text("No records for this date", style: GoogleFonts.poppins(color: Colors.grey)))
            else
               ...records.map((record) => Padding(
                 padding: const EdgeInsets.only(bottom: 12),
                 child: _buildSessionCard(context, record),
               )),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isCheckedIn) {
    return Column(
      children: [
        _buildLargeActionButton(
          context,
          label: 'Time In',
          subLabel: isCheckedIn ? 'You are currently checked in' : 'Start your shift',
          icon: Icons.login,
          color: const Color(0xFF10B981),
          isActive: !isCheckedIn, 
          onTap: () => _handleAttendanceAction(true),
        ),
        const SizedBox(height: 16),
        _buildLargeActionButton(
          context,
          label: 'Time Out',
          subLabel: isCheckedIn ? 'End current shift' : 'Not checked in',
          icon: Icons.logout,
          color: const Color(0xFFEF4444),
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
    return InkWell(
      onTap: isActive ? onTap : null,
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
                  color: isActive ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: isActive ? color : color.withValues(alpha: 0.7), size: 28),
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: isActive ? 1.0 : 0.5))),
                  Text(subLabel, style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                ],
              ),
              const Spacer(),
              if (isActive) Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, List<AttendanceRecord> records) {
    // Fixed Layout for Mobile to prevent overflow
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                 onTap: () {
                   final attendanceId = records.isNotEmpty ? records.first.attendanceId : null;
                   CorrectionRequestDialogMobile.show(context, date: _selectedDate, attendanceId: attendanceId);
                 },
                 child: GlassContainer(
                   height: 44,
                   padding: const EdgeInsets.symmetric(horizontal: 12),
                   borderRadius: 12,
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.edit_note, size: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Theme.of(context).primaryColor),
                       const SizedBox(width: 8),
                       Text('Correction', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                     ],
                   ),
                 ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
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
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  borderRadius: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      // Flexible Date Text
                      Flexible(
                        child: Text(
                          DateFormat('dd MMM').format(_selectedDate),
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildSessionCard(BuildContext context, AttendanceRecord record) {
     // Reusing session card logic but ensured generic

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                Expanded(child: Container(width: 2, color: Colors.grey.withValues(alpha: 0.3), margin: const EdgeInsets.symmetric(vertical: 4))),
                Container(width: 12, height: 12, decoration: BoxDecoration(color: record.timeOut != null ? Colors.red : Colors.grey, shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeInfo(context, time: _formatTime(record.timeIn), location: record.timeInAddress ?? 'Unknown'),
                  const SizedBox(height: 24),
                  record.timeOut != null 
                    ? _buildTimeInfo(context, time: _formatTime(record.timeOut), location: record.timeOutAddress ?? 'Unknown')
                    : Text(
                        'Currently Active', 
                        style: GoogleFonts.poppins(
                          fontSize: 13, 
                          fontWeight: FontWeight.w600, 
                          color: const Color(0xFF10B981)
                        )
                      ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAvatar(context, record.timeInImage),
                if (record.timeOut != null) _buildAvatar(context, record.timeOutImage),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(BuildContext context, {required String time, required String location}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time, 
          style: GoogleFonts.poppins(
            fontSize: 14, 
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color
          )
        ),
        const SizedBox(height: 4),
        Text(location, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey, height: 1.3)),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, String? imageUrl) {
      if (imageUrl == null || imageUrl.isEmpty) {
        return Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 24, color: Colors.white),
        );
      }

      return InkWell(
        onTap: () => _showImagePreview(context, imageUrl, "Attendance Image"),
        child: Container(
          width: 40,
          height: 40,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: CachedNetworkImage(
            imageUrl: imageUrl, 
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white),
            placeholder: (context, url) => const Center(child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
          ),
        ),
      );
  }

  void _showImagePreview(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E2939) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                         const SizedBox(height: 8),
                         Text("Image not available", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                       ],
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
