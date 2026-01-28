import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'attendance_mobile_common_widgets.dart';

class AttendanceHistoryMobile extends StatelessWidget {
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const AttendanceHistoryMobile({
    super.key, 
    this.shrinkWrap = false, 
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        // 1. Report Header (Mobile)
        MonthlyReportHeaderMobile(
          selectedMonth: DateTime.now(),
          onMonthChanged: (d) {},
        ),
        const SizedBox(height: 32),

        _buildWeekSection(context, 'Week 3', [
           _buildHistoryCard(
             context, 
             15, 'Thursday, Jan 15', 'LATE', 'Simulated Office Location', '01:30 PM', '05:02 PM', '-', 
             inImage: 'https://via.placeholder.com/150',
             outImage: 'https://via.placeholder.com/150'
           ),
        ]),
        const SizedBox(height: 24),

        _buildWeekSection(context, 'Week 4', [
           _buildHistoryCard(context, 23, 'Friday, Jan 23', 'LATE', 'Simulated Office Location', '09:55 AM', '06:32 PM', '-'),
            _buildHistoryCard(context, 22, 'Thursday, Jan 22', 'LATE', 'Simulated Office Location', '09:50 AM', '07:04 PM', '-'),
             _buildHistoryCard(context, 21, 'Wednesday, Jan 21', 'LATE', 'Simulated Office Location', '09:41 AM', '06:42 PM', '-'),
        ]),
      ],
    );
  }

  Widget _buildWeekSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, 
          style: GoogleFonts.poppins(
            fontSize: 14, 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7) ?? Colors.grey[600]
          )
        ),
        const SizedBox(height: 16),
        ...children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)),
      ],
    );
  }

  Widget _buildHistoryCard(BuildContext context, int day, String date, String status, String location, String timeIn, String timeOut, String hrs, {String? inImage, String? outImage}) {
    final isLate = status == 'LATE';
    final statusColor = isLate ? Colors.orange : Colors.green[100];
    final statusText = isLate ? Colors.orange[800] : Colors.green[800];

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        children: [
           Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                // Date Box
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B60F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$day', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF5B60F6))),
                ),
                const SizedBox(width: 12),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date, 
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, 
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyLarge?.color
                        )
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location, 
                        style: GoogleFonts.poppins(
                          fontSize: 10, 
                          color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: statusColor?.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                        child: Text(status, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: statusText)),
                      ),
                    ],
                  ),
                ),
             ],
           ),
           const SizedBox(height: 12),
           const Divider(height: 1),
           const SizedBox(height: 12),
           // Times Row (Space Between)
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn(context, 'IN', timeIn, imageUrl: inImage),
                _buildTimeColumn(context, 'OUT', timeOut, imageUrl: outImage),
                _buildTimeColumn(context, 'HRS', hrs),
              ],
           )
        ],
      ),
    );
  }

  Widget _buildTimeColumn(BuildContext context, String label, String value, {String? imageUrl}) {
    final isUndefined = value == '-' || value.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: GoogleFonts.poppins(
            fontSize: 9, 
            color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey, 
            fontWeight: FontWeight.w600
          )
        ),
        const SizedBox(height: 2),
        if (imageUrl != null && !isUndefined)
          InkWell(
            onTap: () => _showImagePreview(context, imageUrl, "$label Image"),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value, 
                  style: GoogleFonts.poppins(
                    decoration: TextDecoration.underline,
                  )
                ),
                const SizedBox(width: 4),
                Icon(Icons.remove_red_eye_outlined, size: 12, color: Theme.of(context).primaryColor),
              ],
            ),
          )
        else
          Text(
            value, 
            style: GoogleFonts.poppins(
              fontSize: 12, 
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color
            )
          ),
      ],
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
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
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
                  height: 450, // Allow sufficient height for portrait
                  width: double.infinity,
                  fit: BoxFit.contain, // Show full image without cropping
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
                         // Debug helper
                         // Text(imageUrl, style: const TextStyle(fontSize: 8)),
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
