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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Top Action Bar
          _buildTopActionBar(context),
          const SizedBox(height: 24),

          // Holidays Table
          _buildHolidaysTable(context),
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

  Widget _buildHolidaysTable(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 40,
            headingRowHeight: 60,
            dataRowMaxHeight: 72,
            dividerThickness: 0,
            headingTextStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14, // Standard Table Header
              letterSpacing: 0.5,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            dataRowColor: MaterialStateProperty.all(Colors.transparent),
            columns: const [
              DataColumn(label: Text('HOLIDAY NAME')),
              DataColumn(label: Text('DATE')),
              DataColumn(label: Text('TYPE')),
              DataColumn(label: Text('APPLICABLE LOCATIONS')),
              DataColumn(label: Text('ACTIONS')),
            ],
            rows: [
              _buildHolidayRow(
                context,
                'New Year\'s Day',
                'Mon, 1 Jan 2024',
                'Public',
                ['All Locations'],
              ),
              _buildHolidayRow(
                context,
                'Republic Day',
                'Fri, 26 Jan 2024',
                'Public',
                ['All Locations'],
              ),
              _buildHolidayRow(
                context,
                'Holi',
                'Mon, 25 Mar 2024',
                'Optional',
                ['Mumbai', 'Delhi'],
                isOptional: true,
              ),
              _buildHolidayRow(
                context,
                'Good Friday',
                'Fri, 29 Mar 2024',
                'Public',
                ['All Locations'],
              ),
              _buildHolidayRow(
                context,
                'Independence Day',
                'Thu, 15 Aug 2024',
                'Public',
                ['All Locations'],
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildHolidayRow(
      BuildContext context, String name, String date, String type, List<String> locations,
      {bool isOptional = false}) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return DataRow(
      cells: [
        DataCell(
          Text(name,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: textColor, fontSize: 14))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: subTextColor),
              const SizedBox(width: 8),
              Text(date, style: GoogleFonts.poppins(color: subTextColor, fontSize: 13)),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isOptional
                  ? Colors.orange.withOpacity(0.1)
                  : const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20), // Pill shape
            ),
            child: Text(
              type,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOptional ? Colors.orange : const Color(0xFF6366F1)),
            ),
          ),
        ),
        DataCell(
          Row(
            children: locations.map((location) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white.withOpacity(0.1) 
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (location == 'All Locations')
                       Padding(
                        padding: const EdgeInsets.only(right: 6),
                         child: Icon(Icons.public, size: 12, color: subTextColor),
                       ),
                    Text(
                      location,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: textColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: Colors.grey, // Matching minimal style
                onPressed: () {},
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
