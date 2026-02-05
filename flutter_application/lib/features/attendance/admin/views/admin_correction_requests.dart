
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/glass_dropdown.dart';
import '../../models/correction_request.dart';
import '../../services/attendance_correction_service.dart';
import '../widgets/correction_detail_dialog.dart';

class AdminCorrectionRequests extends StatefulWidget {
  const AdminCorrectionRequests({super.key});

  @override
  State<AdminCorrectionRequests> createState() => _AdminCorrectionRequestsState();
}

class _AdminCorrectionRequestsState extends State<AdminCorrectionRequests> {
  late AttendanceCorrectionService _service;
  bool _isLoading = true;
  List<AttendanceCorrectionRequest> _requests = [];
  String _filterStatus = 'Pending'; // 'Pending' or 'History'

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _service = AttendanceCorrectionService(authService);
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      // In a real API, we'd pass the status filter
      // For now, fetching all and filtering locally or assuming service handles it
      final allRequests = await _service.getCorrectionRequests(status: _filterStatus.toLowerCase());
      setState(() {
        _requests = allRequests;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showDetail(AttendanceCorrectionRequest request) {
    showDialog(
      context: context,
      builder: (context) => CorrectionDetailDialog(
        request: request,
        onStatusChanged: _fetchRequests,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter / Toggle
    return Column(
      children: [
        Row(
          children: [
            _buildTabButton('Pending', _filterStatus == 'Pending'),
            const SizedBox(width: 12),
            _buildTabButton('History', _filterStatus == 'History'),
           ],
        ),
        const SizedBox(height: 16),
        
        // 2. List
        Expanded(
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _requests.isEmpty 
                  ? Center(child: Text('No requests found', style: GoogleFonts.poppins(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final req = _requests[index];
                        return _buildRequestCard(req);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = label;
          _fetchRequests();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
           color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
           borderRadius: BorderRadius.circular(20),
           border: Border.all(color: isActive ? Theme.of(context).primaryColor : Colors.grey.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(AttendanceCorrectionRequest req) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => _showDetail(req), // Open Detail Dialog
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Text(req.userName.isNotEmpty ? req.userName[0] : '?', 
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(req.userName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  Text('${req.type.toString().split('.').last.toUpperCase()} • ${DateFormat('MMM dd').format(req.requestDate)}',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(req.status),
                const SizedBox(height: 4),
                Text(DateFormat('hh:mm a').format(req.requestDate), style: const TextStyle(fontSize: 10, color: Colors.grey)), // Actually request time created_at usually
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(RequestStatus status) {
    Color color;
    switch (status) {
      case RequestStatus.approved: color = Colors.green; break;
      case RequestStatus.rejected: color = Colors.red; break;
      default: color = Colors.orange;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
