import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

class MobileProfileContent extends StatelessWidget {
  const MobileProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Hero Profile Card
          _buildHeroCard(context),
          const SizedBox(height: 16),

          // Contact Info Card
          _buildContactInfoCard(context),
          const SizedBox(height: 16),

          // Employment Details Card
          _buildEmploymentDetailsCard(context),
          const SizedBox(height: 16),

          // Logout Card
          _buildLogoutCard(context),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column( // Stacked for Mobile
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF5B60F6).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF5B60F6).withOpacity(0.3), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              'M',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5B60F6),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info
          Text(
            'Mano Admin',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF5B60F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF5B60F6).withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF5B60F6)),
                const SizedBox(width: 8),
                Text(
                  'Admin',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5B60F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1, color: Colors.white10),
          const SizedBox(height: 24),
          // Vertical Stack for Mobile
          _buildInfoItem(
            context,
            icon: Icons.email_outlined,
            label: 'Email Address',
            value: 'admin@demo.com',
            valueFontSize: 12,
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            context,
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: '+91 98765 43210',
          ),
        ],
      ),
    );
  }

  Widget _buildEmploymentDetailsCard(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Employment Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1, color: Colors.white10),
          const SizedBox(height: 24),
          // Vertical Stack
          _buildInfoItem(
            context,
            icon: Icons.business_outlined,
            label: 'Department',
            value: 'Management',
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            context,
            icon: Icons.badge_outlined,
            label: 'Employee ID',
            value: 'MS-001',
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Implement logout logic
        Navigator.pop(context); // Example: Pop if it was a route, or show snackbar
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
      },
      child: GlassContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        color: Colors.red.withOpacity(0.1), // Distinctive red tint
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 12),
            Text(
              'Log Out',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, {required IconData icon, required String label, required String value, double? valueFontSize}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Colors.grey[400]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: valueFontSize ?? 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
