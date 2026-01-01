import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

class GeoFencingView extends StatefulWidget {
  const GeoFencingView({super.key});

  @override
  State<GeoFencingView> createState() => _GeoFencingViewState();
}

class _GeoFencingViewState extends State<GeoFencingView> {
  // Using a state variable for selection even without map to show interactivity
  String _selectedLocation = 'Headquarters';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Left: Locations List
          Expanded(
            flex: 1, // Equal width for balanced 2-column layout
            child: _buildLocationsList(context),
          ),
          const SizedBox(width: 24), // Spacing between columns

          // 2. Right: Assigned Staff List
          Expanded(
            flex: 1, // Equal width for balanced 2-column layout
            child: _buildAssignedStaff(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsList(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOCATIONS',
                style: GoogleFonts.poppins(
                  fontSize: 18, // Standard Heading
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline, size: 20)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildLocationTile(context, 'Headquarters', 'New York, USA', _selectedLocation == 'Headquarters'),
                _buildLocationTile(context, 'Branch Office A', 'London, UK', _selectedLocation == 'Branch Office A'),
                _buildLocationTile(context, 'Warehouse B', 'Berlin, Germany', _selectedLocation == 'Warehouse B'),
                _buildLocationTile(context, 'Remote Hub', 'Singapore', _selectedLocation == 'Remote Hub'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile(BuildContext context, String title, String subtitle, bool isSelected) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected 
            ? primaryColor.withOpacity(0.1) 
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? primaryColor : (isDark ? Colors.white.withOpacity(0.1) : Colors.transparent),
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            _selectedLocation = title;
          });
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.location_on, 
            size: 18, 
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, 
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildAssignedStaff(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ASSIGNED STAFF',
            style: GoogleFonts.poppins(
              fontSize: 18, // Standard Heading
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildStaffSearch(context),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildStaffItem(context, 'Sarah Wilson', 'Product Manager', 'https://i.pravatar.cc/150?u=1'),
                _buildStaffItem(context, 'Mike Johnson', 'Senior Dev', 'https://i.pravatar.cc/150?u=2'),
                _buildStaffItem(context, 'Emily Davis', 'Designer', 'https://i.pravatar.cc/150?u=3'),
                _buildStaffItem(context, 'Alex Brown', 'QA Lead', 'https://i.pravatar.cc/150?u=4'),
                _buildStaffItem(context, 'Jessica Lee', 'HR Manager', 'https://i.pravatar.cc/150?u=5'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffSearch(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

     return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search staff...',
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
          prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: GoogleFonts.poppins(fontSize: 13),
      ),
    );
  }

  Widget _buildStaffItem(BuildContext context, String name, String role, String imageUrl) {
     final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(imageUrl),
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                     color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  role,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {}, 
            icon: Icon(Icons.remove_circle_outline, size: 18, color: Colors.red.withOpacity(0.7)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
