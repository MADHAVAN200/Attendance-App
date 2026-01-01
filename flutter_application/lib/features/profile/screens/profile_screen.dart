import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/responsive_builder.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 24),
          ResponsiveBuilder(
            mobile: Column(
              children: [
                _buildContactInfoCard(context),
                const SizedBox(height: 16),
                _buildEmploymentDetailsCard(context),
              ],
            ),
            tablet: Column(
              children: [
                _buildContactInfoCard(context),
                const SizedBox(height: 16),
                _buildEmploymentDetailsCard(context),
              ],
            ),
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildContactInfoCard(context)),
                const SizedBox(width: 24),
                Expanded(child: _buildEmploymentDetailsCard(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'M',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mano Admin',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, color: Theme.of(context).primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Admin',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(BuildContext context) {
    return _buildCard(
      title: 'Contact Information',
      children: [
        _buildInfoRow(Icons.email_outlined, 'Email Address', 'admin@demo.com'),
        const SizedBox(height: 24),
        _buildInfoRow(Icons.phone_outlined, 'Phone Number', '+91 98765 43210'),
      ],
    );
  }

  Widget _buildEmploymentDetailsCard(BuildContext context) {
    return _buildCard(
      title: 'Employment Details',
      children: [
        _buildInfoRow(Icons.business_center_outlined, 'Department', 'Management'),
        const SizedBox(height: 24),
        _buildInfoRow(Icons.badge_outlined, 'Employee ID', 'MS-001'),
      ],
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Builder( // Use Builder to ensure context is available if needed, though passed in mixins usually ok.
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: Theme.of(context).dividerColor.withOpacity(0.1), height: 1),
              const SizedBox(height: 24),
              ...children,
            ],
          ),
        );
      }
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Theme.of(context).iconTheme.color?.withOpacity(0.5), size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ],
        );
      }
    );
  }
}
