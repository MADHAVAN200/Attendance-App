
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({super.key});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  String _searchQuery = '';
  
  // Mock Data matching the screenshot
  final List<Map<String, dynamic>> _holidays = [
    {'name': 'New Year', 'date': 'Wed, 1 Jan 2025', 'type': 'Public'},
    {'name': 'Republic Day', 'date': 'Sun, 26 Jan 2025', 'type': 'Public'},
    {'name': 'Christmas', 'date': 'Thu, 25 Dec 2025', 'type': 'Public'},
    {'name': 'Mano Birthday', 'date': 'Thu, 6 Mar 2025', 'type': 'Optional'},
  ];

  List<Map<String, dynamic>> get _filteredHolidays {
    if (_searchQuery.isEmpty) return _holidays;
    return _holidays.where((h) => 
      h['name'].toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isMobile),
          const SizedBox(height: 24),
          _buildContent(isMobile, width),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: isMobile ? _buildMobileHeader() : _buildDesktopHeader(),
    );
  }

  Widget _buildDesktopHeader() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildSearchBox(),
        ),
        const Spacer(),
        _buildActionButton(
          icon: Icons.upload_file_outlined,
          label: 'Import CSV',
          onPressed: () {},
          isSecondary: true,
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Icons.add,
          label: 'Add Holiday',
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      children: [
        _buildSearchBox(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.upload_file_outlined,
                label: 'Import CSV',
                onPressed: () {},
                isSecondary: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: Icons.add,
                label: 'Add Holiday',
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: 'Search holidays...',
          hintStyle: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color),
          prefixIcon: Icon(Icons.search, size: 18, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isSecondary = false,
  }) {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Theme.of(context).canvasColor : const Color(0xFF5B60F6),
          foregroundColor: isSecondary ? const Color(0xFF5B60F6) : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildContent(bool isMobile, double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
           // Use 600 as a threshold for "List vs Table" inside the content area.
           // Since Sidebar might be present, constraints.maxWidth is the real space.
           return constraints.maxWidth < 600 
             ? _buildMobileList() 
             : _buildDataTable(screenWidth);
        }
      ),
    );
  }

  Widget _buildDataTable(double screenWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            // Ensure minWidth is at least the constraint width OR a fixed minWidth like 800
            // logic: if constraint is > 800, use constraint, else use 800 (forcing scroll)
            constraints: BoxConstraints(minWidth: constraints.maxWidth < 800 ? 800 : constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 48,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 56,
              horizontalMargin: 24,
              columnSpacing: 24,
              headingTextStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodySmall?.color,
                letterSpacing: 0.5,
              ),
              columns: const [
                DataColumn(label: Text('HOLIDAY NAME')),
                DataColumn(label: Text('DATE')),
                DataColumn(label: Text('TYPE')),
                DataColumn(label: Text('ACTIONS', textAlign: TextAlign.right)),
              ],
              rows: _filteredHolidays.map((holiday) {
                return DataRow(cells: [
                  DataCell(Text(holiday['name'], style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color))),
                  DataCell(Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                      const SizedBox(width: 8),
                      Text(holiday['date'], style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color)),
                    ],
                  )),
                  DataCell(_buildTypeBadge(holiday['type'])),
                  DataCell(IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                    onPressed: () {},
                  )),
                ]);
              }).toList(),
            ),
          ),
        );
      }
    );
  }

  Widget _buildMobileList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredHolidays.length,
      separatorBuilder: (c, i) => Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
      itemBuilder: (context, index) {
        final holiday = _filteredHolidays[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(holiday['name'], style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                  const SizedBox(width: 6),
                  Text(holiday['date'], style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
                ],
              ),
              const SizedBox(height: 8),
              _buildTypeBadge(holiday['type']),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
            onPressed: () {},
          ),
        );
      },
    );
  }

  Widget _buildTypeBadge(String type) {
    final isPublic = type == 'Public';
    final color = isPublic ? const Color(0xFF8B5CF6) : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
