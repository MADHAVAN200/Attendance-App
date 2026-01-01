import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'add_employee_view.dart';

class EmployeesView extends StatefulWidget {
  const EmployeesView({super.key});

  @override
  State<EmployeesView> createState() => _EmployeesViewState();
}

class _EmployeesViewState extends State<EmployeesView> {
  bool _isAddingEmployee = false;

  @override
  Widget build(BuildContext context) {
    if (_isAddingEmployee) {
      return AddEmployeeView(
        onCancel: () {
          setState(() {
            _isAddingEmployee = false;
          });
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Top Actions Bar
          _buildTopActions(context),
          const SizedBox(height: 24),

          // Employees Table
          _buildEmployeesTable(context),
          const SizedBox(height: 24),

          // Pagination
          _buildPagination(context),
        ],
      ),
    );
  }

  Widget _buildTopActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        // Search Input
        Expanded(
          flex: 3,
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            child: Row(
              children: [
                Icon(Icons.search, color: Theme.of(context).textTheme.bodySmall?.color),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search employees...',
                      hintStyle: GoogleFonts.poppins(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Status Filter
        Expanded(
          flex: 2,
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'All Status',
                icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).textTheme.bodySmall?.color),
                dropdownColor: Theme.of(context).cardColor,
                items: ['All Status', 'Active', 'On Leave', 'Onboarding']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e, 
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 14,
                            )
                          ),
                        ))
                    .toList(),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
        const Spacer(flex: 2),

        // Action Buttons
        _buildActionButton(
          context, 
          label: 'Bulk Upload', 
          icon: Icons.upload_file_outlined,
          isPrimary: false,
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          context, 
          label: 'Add Employee', 
          icon: Icons.add,
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required String label, 
    required IconData icon, 
    required bool isPrimary
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: () {
        if (isPrimary) {
          setState(() {
            _isAddingEmployee = true;
          });
        }
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isPrimary ? primaryColor : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : primaryColor.withOpacity(0.2)
          ),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: isPrimary ? Colors.white : (isDark ? Colors.white : primaryColor),
              size: 20
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : (isDark ? Colors.white : primaryColor),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeesTable(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: SizedBox( // Wrap in SizedBox to avoid unbounded width issues inside some layouts
        width: double.infinity,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC)
          ),
          columnSpacing: 24,
          horizontalMargin: 24,
          dataRowMaxHeight: 72,
          dividerThickness: 0, // Cleaner look
          columns: [
            _buildDataColumn(context, 'Employee', flex: 3),
            _buildDataColumn(context, 'Role & Dept', flex: 2),
            _buildDataColumn(context, 'Phone', flex: 2),
            _buildDataColumn(context, 'Shift', flex: 2),
            _buildDataColumn(context, 'Status', flex: 1),
            const DataColumn(label: SizedBox(width: 40)), // Actions
          ],
          rows: [
            _buildDataRow(context, 
              name: 'Sarah Wilson',
              email: 'sarah.w@company.com',
              avatar: 'S',
              role: 'UX Designer',
              dept: 'Product',
              phone: '+1 (555) 123-4567',
              shift: '09:00 - 17:00',
              status: 'Active',
              color: Colors.blue,
            ),
            _buildDataRow(context, 
              name: 'Mike Johnson',
              email: 'mike.j@company.com',
              avatar: 'M',
              role: 'Senior Dev',
              dept: 'Engineering',
              phone: '+1 (555) 987-6543',
              shift: '10:00 - 18:00',
              status: 'On Leave',
              color: Colors.orange,
            ),
             _buildDataRow(context, 
              name: 'Anna Davis',
              email: 'anna.d@company.com',
              avatar: 'A',
              role: 'HR Manager',
              dept: 'Human Resources',
              phone: '+1 (555) 456-7890',
              shift: '08:00 - 16:00',
              status: 'Active',
              color: Colors.purple,
            ),
             _buildDataRow(context, 
              name: 'James Wilson',
              email: 'james.w@company.com',
              avatar: 'J',
              role: 'Sales Lead',
              dept: 'Sales',
              phone: '+1 (555) 222-3333',
              shift: '09:00 - 17:00',
              status: 'Active',
              color: Colors.green,
            ),
            _buildDataRow(context, 
              name: 'Emily Chen',
              email: 'emily.c@company.com',
              avatar: 'E',
              role: 'Frontend Dev',
              dept: 'Engineering',
              phone: '+1 (555) 777-8888',
              shift: '10:00 - 18:00',
              status: 'Onboarding',
              color: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }

  DataColumn _buildDataColumn(BuildContext context, String label, {int flex = 1}) {
    return DataColumn(
      label: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 1,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, {
    required String name,
    required String email,
    required String avatar,
    required String role,
    required String dept,
    required String phone,
    required String shift,
    required String status,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return DataRow(
      cells: [
        // Employee
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.1),
                child: Text(
                  avatar,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name, 
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    )
                  ),
                  Text(
                    email, 
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: subTextColor,
                    )
                  ),
                ],
              ),
            ],
          ),
        ),
        // Role
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(role, style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500)),
              Text(dept, style: GoogleFonts.poppins(fontSize: 12, color: subTextColor)),
            ],
          ),
        ),
        // Phone
        DataCell(Text(phone, style: GoogleFonts.poppins(color: textColor))),
        // Shift
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!)
            ),
            child: Text(
              shift,
              style: GoogleFonts.poppins(fontSize: 12, color: textColor),
            ),
          )
        ),
        // Status
        DataCell(
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: _getStatusColor(status),
              ),
            ),
          )
        ),
        // Actions
        DataCell(
          IconButton(
            icon: const Icon(Icons.more_vert), 
            color: subTextColor,
            onPressed: () {},
          )
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Active') return const Color(0xFF10B981);
    if (status == 'On Leave') return const Color(0xFFF59E0B);
    return const Color(0xFF6366F1);
  }

  Widget _buildPagination(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Showing 1 to 5 of 24 entries',
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            IconButton(
              onPressed: () {}, 
              icon: Icon(Icons.chevron_left, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
             Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
               child: Text(
                '1', 
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
              ),
             ),
             IconButton(
              onPressed: () {}, 
              icon: Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ],
        )
      ],
    );
  }
}
