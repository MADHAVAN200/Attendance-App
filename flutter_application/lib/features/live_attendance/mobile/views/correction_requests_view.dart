import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../attendance/services/attendance_service.dart';
import '../../../attendance/models/correction_request.dart';

class MobileCorrectionRequestsView extends StatefulWidget {
  const MobileCorrectionRequestsView({super.key});

  @override
  State<MobileCorrectionRequestsView> createState() => _MobileCorrectionRequestsViewState();
}

class _MobileCorrectionRequestsViewState extends State<MobileCorrectionRequestsView> {
  List<CorrectionRequest> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final service = AttendanceService(authService.dio);
      final data = await service.getCorrectionRequests();
      
      if (mounted) {
        setState(() {
          _requests = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAction(int id, String status, String comments) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final authService = Provider.of<AuthService>(context, listen: false);
      final service = AttendanceService(authService.dio);
      
      await service.updateCorrectionRequestStatus(id, status, comments);

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close details sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request $status successfully'), backgroundColor: Colors.green),
        );
        _fetchRequests(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading requests', style: GoogleFonts.poppins(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _fetchRequests, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return Center(
        child: Text('No correction requests found', style: GoogleFonts.poppins(color: Colors.grey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80), // Extra padding at bottom
      physics: const BouncingScrollPhysics(),
      itemCount: _requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildRequestCard(context, _requests[index]);
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, CorrectionRequest request) {
    // Status Logic
    Color statusColor;
    switch (request.status.toLowerCase()) {
      case 'approved': statusColor = Colors.green; break;
      case 'rejected': statusColor = Colors.red; break;
      default: statusColor = Colors.orange;
    }

    return InkWell(
      onTap: () => _showRequestDetails(context, request),
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Avatar + Name + Status
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage: request.userAvatar != null ? NetworkImage(request.userAvatar!) : null,
                  child: request.userAvatar == null 
                      ? Text(request.userName?[0].toUpperCase() ?? '?', style: GoogleFonts.poppins(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userName ?? 'Unknown User',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        'ID: ${request.userId}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.2)),
            const SizedBox(height: 12),
            
            // Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Request Type', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      request.typeLabel,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Date', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      request.requestDate,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
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

  void _showRequestDetails(BuildContext context, CorrectionRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => _DetailSheet(request: request, controller: controller, onAction: _handleAction),
      ),
    );
  }
}

class _DetailSheet extends StatefulWidget {
  final CorrectionRequest request;
  final ScrollController controller;
  final Function(int, String, String) onAction;

  const _DetailSheet({required this.request, required this.controller, required this.onAction});

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final isPending = request.status.toLowerCase() == 'pending';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: widget.controller,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                // Header
                Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      backgroundImage: request.userAvatar != null ? NetworkImage(request.userAvatar!) : null,
                      child: request.userAvatar == null 
                          ? Text(request.userName?[0].toUpperCase() ?? '?', style: GoogleFonts.poppins(color: Theme.of(context).primaryColor, fontSize: 24, fontWeight: FontWeight.bold))
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      request.userName ?? 'Unknown User',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Employee ID: ${request.userId}',
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Details Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      _buildRow('Request Type', request.typeLabel),
                      const SizedBox(height: 12),
                      _buildRow('For Date', request.requestDate),
                      const SizedBox(height: 12),
                      _buildRow('Submitted On', request.createdAt.split('T')[0]), // Simple date part
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Justification
                Text('Justification', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.reason,
                    style: GoogleFonts.poppins(height: 1.4, fontSize: 13),
                  ),
                ),

                if (!isPending) ...[
                  const SizedBox(height: 24),
                  Text('Review Notes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                   Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: request.status == 'approved' ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${request.status.toUpperCase()}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: request.status == 'approved' ? Colors.green : Colors.red
                          ),
                        ),
                        if (request.reviewComments != null) ...[
                          const SizedBox(height: 4),
                          Text(request.reviewComments!, style: GoogleFonts.poppins(fontSize: 13)),
                        ]
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Actions
                if (isPending) ...[
                  Text('Add Comment (Optional)', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Enter review comments...',
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => widget.onAction(request.id, 'rejected', _commentController.text),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Reject', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => widget.onAction(request.id, 'approved', _commentController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B60F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Approve', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ] else
                   Center(child: Text('This request has been ${request.status}.', style: GoogleFonts.poppins(color: Colors.grey))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
