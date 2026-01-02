import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/glass_container.dart';

class CorrectionRequestsView extends StatefulWidget {
  const CorrectionRequestsView({super.key});

  @override
  State<CorrectionRequestsView> createState() => _CorrectionRequestsViewState();
}

class _CorrectionRequestsViewState extends State<CorrectionRequestsView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Requests List (35%)
        Expanded(
          flex: 35,
          child: ListView.separated(
            padding: const EdgeInsets.all(32),
            itemCount: 5,
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
            child: _buildDetailView(context),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(BuildContext context, int index) {
    final isSelected = index == _selectedIndex;
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        color: isSelected ? primaryColor.withOpacity(0.1) : null,
        border: isSelected ? Border.all(color: primaryColor.withOpacity(0.5)) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                    Row(
                      children: [
                        Text(
                          'Sarah Wilson',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Product Design', // "Tag" / Department
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
                      'Missed Punch',
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
                      'Oct 24, 2023',
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
                'Request Details',
                style: GoogleFonts.poppins(
                  fontSize: 16, // Smaller title
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
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
                    onPressed: () {},
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
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Metadata Grid (Compact)
          Row(
            children: [
              Expanded(child: _buildDetailItem(context, 'Employee', 'Sarah Wilson')),
              Expanded(child: _buildDetailItem(context, 'Dept', 'Product Design')),
              Expanded(child: _buildDetailItem(context, 'Manager', 'Alex Morgan')),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 16),

          // Time Comparison (Compact)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                     color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                     borderRadius: BorderRadius.circular(8),
                     border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text('System', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                      Text('09:45 AM', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
              ),
              Expanded(
                child: Container(
                   padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                     color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                     borderRadius: BorderRadius.circular(8),
                     border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text('Requested', style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                      Text('09:00 AM', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Justification
          Text('Justification', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
             decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
             ),
             child: Text(
               'I forgot to punch in when I arrived at the office. I was in a meeting with the design team immediately upon arrival.',
               style: GoogleFonts.poppins(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.3, fontSize: 12),
             ),
          ),

          const SizedBox(height: 24), // Reduced spacing
          
          // Timeline (Simplified)
          Text('Audit Trail', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13)),
          const SizedBox(height: 12),
           Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Column(
                 children: [
                   const Icon(Icons.circle, size: 10, color: Colors.blue),
                   Container(width: 2, height: 24, color: Colors.blue.withOpacity(0.2)),
                   const Icon(Icons.circle, size: 10, color: Colors.grey),
                 ],
               ),
               const SizedBox(width: 12),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('Request Created', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13)),
                   Text('Oct 24, 10:30 AM by Sarah Wilson', style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                   const SizedBox(height: 16),
                   Text('Pending Approval', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.orange, fontSize: 13)),
                   Text('Awaiting review by Alex Morgan', style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                 ],
               ),
            ],
           ),
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
