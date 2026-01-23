import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../attendance/services/attendance_service.dart';
import 'package:provider/provider.dart';

class CorrectionRequestsView extends StatefulWidget {
  const CorrectionRequestsView({super.key});

  @override
  State<CorrectionRequestsView> createState() => _CorrectionRequestsViewState();
}

class _CorrectionRequestsViewState extends State<CorrectionRequestsView> {
  int _selectedIndex = 0;
  List<dynamic> _requests = [];
  bool _isLoading = false;
  late AttendanceService _service;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthService>(context, listen: false);
    _service = AttendanceService(auth.dio);
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getCorrectionRequests();
      setState(() => _requests = data);
    } catch (e) {
      debugPrint("Error fetching requests: $e");
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await _service.updateCorrectionRequestStatus(id, status, "Processed by Admin");
      _fetchRequests(); // Refresh
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request $status")));
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Requests List (35%)
        Expanded(
          flex: 35,
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _requests.isEmpty 
               ? Center(child: Text("No Pending Requests", style: GoogleFonts.poppins(color: Colors.grey)))
               : ListView.separated(
                  padding: const EdgeInsets.all(32),
                  itemCount: _requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildRequestCard(context, index);
                  },
                ),
        ),

        // Right Column: Request Details (65%)
        Expanded(
          flex: 65,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 32, 32, 32),
            child: _requests.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text("Select a request to view details", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  )
                : _buildDetailView(context),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(BuildContext context, int index) {
    if (index >= _requests.length) return const SizedBox();
    
    final request = _requests[index];
    final isSelected = index == _selectedIndex;
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final user = request['user'] ?? {};
    final userName = user['name'] ?? 'Unknown';
    // final dept = user['department'] ?? 'General';
    final type = request['correction_type'] ?? 'Request';
    final date = request['request_date'] ?? '';

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        color: null,
        border: isSelected 
            ? Border.all(color: isDark ? Colors.blue.withOpacity(0.5) : primaryColor.withOpacity(0.5), width: isDark ? 1.5 : 1) 
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.purple.withOpacity(0.1),
                child: Text(userName.isNotEmpty ? userName[0] : '?', style: GoogleFonts.poppins(color: Colors.purple, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Employee',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Reduced spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Type',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    Text(
                      type,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Date',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_requests.isEmpty || _selectedIndex >= _requests.length) return const SizedBox();
    
    final request = _requests[_selectedIndex];
    final user = request['user'] ?? {};
    final userName = user['name'] ?? 'Unknown';
    final requestId = request['id'];
    final reason = request['reason'] ?? 'No reason provided';
    final status = request['status'] ?? 'pending';

    return GlassContainer(
      padding: const EdgeInsets.all(20), // Further reduced padding
      child: Column(
        mainAxisSize: MainAxisSize.min, // Wrap content height
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Request Details #$requestId',
                style: GoogleFonts.poppins(
                  fontSize: 16, // Smaller title
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              if (status == 'pending')
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => _updateStatus(requestId, 'rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // More compact
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Reject', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _updateStatus(requestId, 'approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B60F6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Approve',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ) else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(status.toUpperCase(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Metadata Grid (Compact)
          Row(
            children: [
              Expanded(child: _buildDetailItem(context, 'Employee', userName)),
              Expanded(child: _buildDetailItem(context, 'Type', request['correction_type'] ?? '-')),
              Expanded(child: _buildDetailItem(context, 'Date', request['request_date'] ?? '-')),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 16),

          // Justification
          Text('Justification', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
             decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2939) : Colors.grey[50], // Solid instead of tint
                borderRadius: BorderRadius.circular(8),
             ),
             child: Text(
               reason,
               style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.3, fontSize: 12),
             ),
          ),

          const SizedBox(height: 24), // Reduced spacing
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
