
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/glass_text_field.dart';
import '../../models/correction_request.dart';
import '../../services/attendance_correction_service.dart';

class CorrectionDetailDialog extends StatefulWidget {
  final AttendanceCorrectionRequest request;
  final VoidCallback onStatusChanged;

  const CorrectionDetailDialog({
    super.key, 
    required this.request,
    required this.onStatusChanged,
  });

  @override
  State<CorrectionDetailDialog> createState() => _CorrectionDetailDialogState();
}

class _CorrectionDetailDialogState extends State<CorrectionDetailDialog> {
  late AttendanceCorrectionService _service;
  bool _isLoading = false;
  final TextEditingController _commentController = TextEditingController();
  
  // Override State
  bool _isOverride = false;
  TextEditingController _overrideInController = TextEditingController();
  TextEditingController _overrideOutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _service = AttendanceCorrectionService(authService);
    
    // Pre-fill overrides with requested times
    _overrideInController.text = widget.request.requestedTimeIn ?? '';
    _overrideOutController.text = widget.request.requestedTimeOut ?? '';
  }

  Future<void> _updateStatus(RequestStatus status) async {
    if (status == RequestStatus.rejected && _commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comment is required for rejection')));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await _service.updateCorrectionStatus(
        widget.request.id,
        status,
        _commentController.text,
        overrideTimeIn: _isOverride ? _overrideInController.text : null,
        overrideTimeOut: _isOverride ? _overrideOutController.text : null,
      );
      
      if (!mounted) return;
      Navigator.pop(context);
      widget.onStatusChanged();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Request ${status == RequestStatus.approved ? 'Approved' : 'Rejected'}'),
        backgroundColor: status == RequestStatus.approved ? Colors.green : Colors.red,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: GlassContainer(
        width: 500,
        height: 600, // Fixed height specifically asked for mobile to fill somewhat
        child: Column(
          children: [
             // Header
             Row(
               children: [
                 Text('Request Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                 const Spacer(),
                 IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
               ],
             ),
             const Divider(),
             Expanded(
               child: SingleChildScrollView(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     _buildDetailRow('Employee', widget.request.userName),
                     _buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(widget.request.requestDate)),
                     _buildDetailRow('Type', widget.request.type.toString().split('.').last.toUpperCase()),
                     _buildDetailRow('Method', widget.request.method.toString().split('.').last.toUpperCase()),
                     const SizedBox(height: 16),
                     
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('Requested Changes:', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                           if (widget.request.requestedSessions != null)
                             ...widget.request.requestedSessions!.map((s) => Text('• ${s['time_in']} - ${s['time_out']}')),
                           if (widget.request.requestedTimeIn != null)
                             Text('In: ${widget.request.requestedTimeIn}'),
                           if (widget.request.requestedTimeOut != null)
                             Text('Out: ${widget.request.requestedTimeOut}'),
                         ],
                       ),
                     ),
                     
                     const SizedBox(height: 16),
                     Text('Reason:', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                     Text(widget.request.reason, style: GoogleFonts.poppins(fontStyle: FontStyle.italic)),
                     
                     if (widget.request.status == RequestStatus.pending) ...[
                       const SizedBox(height: 24),
                       const Divider(),
                       // Admin Actions
                       Row(
                         children: [
                           Text('Admin Override', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                           Switch(value: _isOverride, onChanged: (val) => setState(() => _isOverride = val)),
                         ],
                       ),
                       if (_isOverride) ...[
                         Row(
                           children: [
                             Expanded(child: GlassTextField(controller: _overrideInController, hintText: 'In (HH:mm)')),
                             const SizedBox(width: 8),
                             Expanded(child: GlassTextField(controller: _overrideOutController, hintText: 'Out (HH:mm)')),
                           ],
                         ),
                         const SizedBox(height: 12),
                       ],
                       
                       GlassTextField(
                         controller: _commentController,
                         hintText: 'Review Comments...',
                         maxLines: 2,
                       ),
                       const SizedBox(height: 16),
                       Row(
                         children: [
                           Expanded(
                             child: ElevatedButton(
                               onPressed: _isLoading ? null : () => _updateStatus(RequestStatus.rejected),
                               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                               child: const Text('Reject', style: TextStyle(color: Colors.white)),
                             ),
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                             child: ElevatedButton(
                               onPressed: _isLoading ? null : () => _updateStatus(RequestStatus.approved),
                               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                               child: const Text('Approve', style: TextStyle(color: Colors.white)),
                             ),
                           ),
                         ],
                       )
                     ] else ...[
                       const SizedBox(height: 24),
                       Container(
                         padding: const EdgeInsets.all(12),
                         width: double.infinity,
                         decoration: BoxDecoration(
                           color: widget.request.status == RequestStatus.approved ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                           borderRadius: BorderRadius.circular(8),
                           border: Border.all(color: widget.request.status == RequestStatus.approved ? Colors.green : Colors.red),
                         ),
                         child: Column(
                           children: [
                             Text('Status: ${widget.request.status.toString().split('.').last.toUpperCase()}', 
                               style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: widget.request.status == RequestStatus.approved ? Colors.green : Colors.red)),
                             if (widget.request.reviewComments != null)
                               Text('Comment: ${widget.request.reviewComments}'),
                           ],
                         ),
                       )
                     ]
                   ],
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey)),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
