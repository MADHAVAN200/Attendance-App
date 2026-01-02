import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

class MobileHolidaysContent extends StatefulWidget {
  const MobileHolidaysContent({super.key});

  @override
  State<MobileHolidaysContent> createState() => _MobileHolidaysContentState();
}

class _MobileHolidaysContentState extends State<MobileHolidaysContent> {
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Top Action Bar
        _buildTopActionBar(context),
        const SizedBox(height: 4),

        // Holidays List (No Header Row for Mobile, Card content is self-explanatory)
        _buildHolidaysList(context),
      ],
    );
  }

  Widget _buildTopActionBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search holidays...',
                prefixIcon: Icon(Icons.search, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
          
          // Buttons Row
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file_outlined, size: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
                        const SizedBox(width: 8),
                         Text(
                          'Import',
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    'Add',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B60F6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHolidaysList(BuildContext context) {
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
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    holiday['name'],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOptional
                        ? Colors.orange.withOpacity(0.1)
                        : const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    typeName,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isOptional ? Colors.orange : const Color(0xFF6366F1)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: subTextColor),
                const SizedBox(width: 8),
                Text(holiday['date'], style: GoogleFonts.poppins(color: subTextColor, fontSize: 13)),
              ],
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Text(
              'Holiday Details',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
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
                    onPressed: () => Navigator.pop(context),
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
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B60F6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Edit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
