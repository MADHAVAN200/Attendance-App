
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/glass_dropdown.dart';
import '../../models/correction_request.dart';
import '../../services/attendance_service.dart';
import '../widgets/correction_detail_dialog.dart';

class AdminCorrectionRequests extends StatefulWidget {
  final String? userId;
  const AdminCorrectionRequests({super.key, this.userId});

  @override
  State<AdminCorrectionRequests> createState() => _AdminCorrectionRequestsState();
}

class _AdminCorrectionRequestsState extends State<AdminCorrectionRequests> {
  late AttendanceService _service;
  bool _isLoading = true;
  List<AttendanceCorrectionRequest> _requests = [];
  String _filterStatus = 'Pending'; // 'Pending' or 'History'

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _service = AttendanceService(authService.dio);
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final status = _filterStatus.toLowerCase();
      final allRequests = await _service.getCorrectionRequests(
        status: status == 'pending' ? 'pending' : null, 
        userId: widget.userId,
      );
      
      setState(() {
        if (status == 'history') {
          _requests = allRequests.where((r) => r.status != RequestStatus.pending).toList();
        } else {
          _requests = allRequests.where((r) => r.status == RequestStatus.pending).toList();
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showDetail(AttendanceCorrectionRequest request) {
    CorrectionDetailDialog.show(
      context,
      request: request,
      onStatusChanged: _fetchRequests,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter / Toggle
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: Row(
            children: [
              _buildTabButton('Pending', _filterStatus == 'Pending'),
              const SizedBox(width: 12),
              _buildTabButton('History', _filterStatus == 'History'),
             ],
          ),
        ),
        const SizedBox(height: 8),
        
        // 2. List
        Expanded(
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _requests.isEmpty 
                  ? Center(child: Text('No requests found', style: GoogleFonts.poppins(color: Colors.grey)))
                  : ListView.builder(
                      padding: EdgeInsets.zero,
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
              radius: 20,
              backgroundColor: isDark ? const Color(0xFF5B60F6) : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: req.userAvatar != null && req.userAvatar!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: req.userAvatar!,
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                        placeholder: (context, url) => Center(
                          child: Text(
                            req.userName.isNotEmpty ? req.userName[0] : '?',
                            style: TextStyle(
                              color: isDark ? Colors.white : Theme.of(context).primaryColor, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            req.userName.isNotEmpty ? req.userName[0] : '?',
                            style: TextStyle(
                              color: isDark ? Colors.white : Theme.of(context).primaryColor, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      )
                    : Text(
                        req.userName.isNotEmpty ? req.userName[0] : '?',
                        style: TextStyle(
                          color: isDark ? Colors.white : Theme.of(context).primaryColor, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(req.userName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  Text('${req.typeLabel} • ${DateFormat('MMM dd').format(req.requestDate)}',
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
