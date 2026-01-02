import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../models/employee_model.dart';

class MobileEmployeesContent extends StatelessWidget {
  const MobileEmployeesContent({super.key});

  @override
  Widget build(BuildContext context) {
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Column(
      children: [
        // 1. Search & Filter Bar (Fixed at top of content area)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            children: [
              // Search
              Expanded(
                child: GlassContainer(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  borderRadius: 12,
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 20, color: subTextColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: GoogleFonts.poppins(
                              color: subTextColor?.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(bottom: 4),
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Filter Button
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.filter_list, color: subTextColor),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              // Add Employee Button
              InkWell(
                onTap: () {
                  // Handle Add Employee Action
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Add',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Employee List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: Employee.dummyData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildEmployeeCard(context, Employee.dummyData[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeCard(BuildContext context, Employee employee) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;

    // Wrap in GlassContainer without child padding, handle padding inside InkWell
    return GlassContainer(
      padding: EdgeInsets.zero, 
      borderRadius: 16,
      child: InkWell(
        onTap: () => _showEmployeeDetails(context, employee),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header: Avatar, Name, Role, Actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: employee.color.withOpacity(0.15),
                    child: Text(
                      employee.avatar,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: employee.color,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        Text(
                          employee.role,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(employee.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      employee.status,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(employee.status),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              Divider(color: Theme.of(context).dividerColor.withOpacity(0.1), height: 1),
              const SizedBox(height: 12),

              // Details Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCompactDetail(context, Icons.work_outline, employee.department),
                  _buildCompactDetail(context, Icons.access_time, employee.shift),
                ],
              ),

              const SizedBox(height: 12),
              
              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context, 
                      icon: Icons.call_outlined, 
                      label: 'Call', 
                      color: const Color(0xFF10B981),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context, 
                      icon: Icons.email_outlined, 
                      label: 'Email', 
                      color: const Color(0xFF6366F1),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmployeeDetails(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: GlassContainer(
          width: 450,
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                   CircleAvatar(
                    radius: 32,
                    backgroundColor: employee.color.withOpacity(0.15),
                    child: Text(
                      employee.avatar,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: employee.color,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          employee.role,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                   IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              const SizedBox(height: 24),
              
              // Details
              _buildDetailRow(context, Icons.email_outlined, 'Email', employee.email),
              const SizedBox(height: 16),
              _buildDetailRow(context, Icons.phone_outlined, 'Phone', employee.phone),
              const SizedBox(height: 16),
              _buildDetailRow(context, Icons.work_outline, 'Department', employee.department),
              const SizedBox(height: 16),
              _buildDetailRow(context, Icons.access_time, 'Shift', employee.shift),
              const SizedBox(height: 16),
              _buildDetailRow(context, Icons.info_outline, 'Status', employee.status, isStatus: true),
              
              const SizedBox(height: 24),
               
              // Action Button (Close)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {bool isStatus = false}) {
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Theme.of(context).primaryColor),
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
                  color: subTextColor,
                ),
              ),
              if (isStatus)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(value).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(value),
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDetail(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon, 
    required String label, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Active') return const Color(0xFF10B981);
    if (status == 'On Leave') return const Color(0xFFF59E0B);
    return const Color(0xFF6366F1);
  }
}
