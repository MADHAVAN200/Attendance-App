import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

class HolidaysView extends StatefulWidget {
  const HolidaysView({super.key});

  @override
  State<HolidaysView> createState() => _HolidaysViewState();
}

class _HolidaysViewState extends State<HolidaysView> {
  final TextEditingController _searchController = TextEditingController();

  // Dummy Data
  final List<Map<String, dynamic>> _holidays = [
    {'name': 'New Year\'s Day', 'date': 'Mon, 1 Jan 2024', 'type': 'Public', 'locations': ['All Locations'], 'isOptional': false},
    {'name': 'Republic Day', 'date': 'Fri, 26 Jan 2024', 'type': 'Public', 'locations': ['All Locations'], 'isOptional': false},
    {'name': 'Holi', 'date': 'Mon, 25 Mar 2024', 'type': 'Optional', 'locations': ['Mumbai', 'Delhi'], 'isOptional': true},
    {'name': 'Good Friday', 'date': 'Fri, 29 Mar 2024', 'type': 'Public', 'locations': ['All Locations'], 'isOptional': false},
    {'name': 'Independence Day', 'date': 'Thu, 15 Aug 2024', 'type': 'Public', 'locations': ['All Locations'], 'isOptional': false},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Top Action Bar
          _buildTopActionBar(context),
          const SizedBox(height: 24),

          // Header Row
          _buildHeaderRow(context),
          const SizedBox(height: 12),

          // Holidays List
          _buildHolidaysList(context),
        ],
      ),
    );
  }

  Widget _buildTopActionBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search holidays...',
                hintStyle: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 4),
              ),
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 24),
          
          // Import CSV Button
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.upload_file_outlined, size: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                  const SizedBox(width: 8),
                  Text(
                    'Import CSV',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Add Holiday Button
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              'Add Holiday',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B60F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 4,
              shadowColor: const Color(0xFF5B60F6).withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodySmall?.color;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('HOLIDAY NAME', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: textColor, letterSpacing: 0.5))),
          Expanded(flex: 2, child: Text('DATE', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: textColor, letterSpacing: 0.5))),
          Expanded(flex: 1, child: Text('TYPE', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: textColor, letterSpacing: 0.5))),
          // Expanded(flex: 1, child: Text('ACTIONS', textAlign: TextAlign.right, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: textColor, letterSpacing: 0.5))),
        ],
      ),
    );
  }

  Widget _buildHolidaysList(BuildContext context) {
    // Non-scrollable list (shrinkWrap: true, physics: NeverScrollable)
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _holidays.length,
      separatorBuilder: (c, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildHolidayItem(context, _holidays[index]);
      },
    );
  }

  Widget _buildHolidayItem(BuildContext context, Map<String, dynamic> holiday) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final isOptional = holiday['isOptional'] as bool;
    final typeName = holiday['type'] as String;

    return GestureDetector(
      onTap: () => _showHolidayDetails(context, holiday),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        borderRadius: 12,
        child: Row(
          children: [
            // Name
            Expanded(
              flex: 3,
              child: Text(
                holiday['name'],
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor, fontSize: 14),
              ),
            ),
            // Date
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: subTextColor),
                  const SizedBox(width: 8),
                  Text(holiday['date'], style: GoogleFonts.poppins(color: subTextColor, fontSize: 13)),
                ],
              ),
            ),
            // Type
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOptional
                        ? Colors.orange.withOpacity(0.1)
                        : const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    typeName,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isOptional ? Colors.orange : const Color(0xFF6366F1)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHolidayDetails(BuildContext context, Map<String, dynamic> holiday) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            width: 400,
            padding: const EdgeInsets.all(24),
            borderRadius: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Holiday Details',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: subTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Name & Date
                _buildDetailRow(context, 'Holiday Name', holiday['name'], Icons.celebration),
                const SizedBox(height: 16),
                _buildDetailRow(context, 'Date', holiday['date'], Icons.calendar_today),
                const SizedBox(height: 16),
                _buildDetailRow(context, 'Type', holiday['type'], Icons.category),
                
                const SizedBox(height: 24),
                Divider(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
                const SizedBox(height: 24),

                // Locations
                Text(
                  'APPLICABLE LOCATIONS',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: subTextColor, letterSpacing: 0.5),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (holiday['locations'] as List<String>).map((loc) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: subTextColor),
                          const SizedBox(width: 6),
                          Text(
                            loc,
                            style: GoogleFonts.poppins(fontSize: 13, color: textColor, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 32),
                
                // Actions (Edit/Delete)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Delete', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B60F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text('Edit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 11, color: subTextColor)),
            const SizedBox(height: 2),
            Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
          ],
        ),
      ],
    );
  }
}
