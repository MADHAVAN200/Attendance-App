import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

class MobileCorrectionRequestsView extends StatefulWidget {
  const MobileCorrectionRequestsView({super.key});

  @override
  State<MobileCorrectionRequestsView> createState() => _MobileCorrectionRequestsViewState();
}

class _MobileCorrectionRequestsViewState extends State<MobileCorrectionRequestsView> {
  // Dummy data matching tablet view logic
  final _requests = List.generate(5, (index) => index);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildRequestCard(context, index);
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, int index) {
    return InkWell(
      onTap: () => _showRequestDetails(context),
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Avatar + Name + Dept
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  child: Text('S', style: GoogleFonts.poppins(color: Colors.purple, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sarah Wilson',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        'Product Design',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Indicator (Optional, added for clear status visibility in list)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Text(
                    'Pending',
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.2)),
            const SizedBox(height: 12),
            
            // Info Row: Type + Date
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
                    const SizedBox(height: 2),
                    Text(
                      'Missed Punch',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
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
                    const SizedBox(height: 2),
                    Text(
                      'Oct 24, 2023',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
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

  void _showRequestDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
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
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  children: [
                     _buildDetailHeader(context),
                     const SizedBox(height: 24),
                     _buildComparison(context),
                     const SizedBox(height: 24),
                     _buildJustification(context),
                     const SizedBox(height: 24),
                     _buildAuditTrail(context),
                     const SizedBox(height: 32),
                     _buildActionButtons(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailHeader(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.purple.withOpacity(0.1),
          child: Text('S', style: GoogleFonts.poppins(color: Colors.purple, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        Text(
          'Sarah Wilson',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        Text(
          'Product Design',
          style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color),
        ),
      ],
    );
  }

  Widget _buildComparison(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
               color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text('System Logic', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 4),
                Text('09:45 AM', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
        ),
        Expanded(
          child: Container(
             padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
               color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text('Requested', style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 4),
                Text('09:00 AM', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJustification(BuildContext context) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
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
              'I forgot to punch in when I arrived at the office. I was in a meeting with the design team immediately upon arrival.',
              style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.4, fontSize: 13),
            ),
         ),
       ],
     );
  }

  Widget _buildAuditTrail(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Audit Trail', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Column(
               children: [
                 const Icon(Icons.circle, size: 10, color: Colors.blue),
                 Container(width: 2, height: 30, color: Colors.blue.withOpacity(0.2)),
                 const Icon(Icons.circle, size: 10, color: Colors.grey),
               ],
             ),
             const SizedBox(width: 12),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('Request Created', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13)),
                   Text('Oct 24, 10:30 AM · Sarah Wilson', style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                   const SizedBox(height: 16),
                   Text('Pending Approval', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.orange, fontSize: 13)),
                   Text('Awaiting review by Alex Morgan', style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                 ],
               ),
             ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Reject', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B60F6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Approve',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
