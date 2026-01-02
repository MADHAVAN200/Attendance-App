import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../models/employee_model.dart';
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Top Filter Section
          _buildFilterSection(context),
          const SizedBox(height: 24),

          // Employees List
          _buildEmployeesTable(context),
          const SizedBox(height: 24),

          // Pagination
          _buildPagination(context),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Row(
      children: [
        // 1. Search Details (Flex 3)
        Expanded(
          flex: 3,
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            borderRadius: 12,
            child: Row(
              children: [
                Icon(Icons.search, color: Theme.of(context).textTheme.bodySmall?.color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search employees...',
                      hintStyle: GoogleFonts.poppins(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
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
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 2. Status Dropdown (Fixed width or fit content)
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white.withOpacity(0.05) 
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white.withOpacity(0.08) 
                  : Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'All Status',
              icon: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.filter_list, size: 18, color: Theme.of(context).textTheme.bodySmall?.color),
              ),
              dropdownColor: Theme.of(context).cardColor,
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 14,
              ),
              items: ['All Status', 'Active', 'On Leave', 'Onboarding']
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (_) {},
            ),
          ),
        ),
        
        const Spacer(),

        // 3. Action Buttons
        _buildActionButton(
          context, 
          label: 'Bulk Upload', 
          icon: Icons.upload_file_outlined,
          isPrimary: false,
          isCompact: false, // Show text as per image
        ),
        const SizedBox(width: 12),
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
    required bool isPrimary,
    bool isCompact = false,
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isPrimary ? primaryColor : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : primaryColor.withOpacity(0.1)
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isPrimary ? Colors.white : (isDark ? Colors.white : primaryColor),
              size: 20
            ),
             if (!isCompact) ...[
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeesTable(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
              Colors.transparent 
            ),
            columnSpacing: 16, // Reduced spacing to fit
            horizontalMargin: 16, // Reduced margin to fit
            showCheckboxColumn: false, // Hide checkbox, just use row click
            dataRowMaxHeight: 85,
            dividerThickness: 0,
            // Columns: EMPLOYEE, ROLE & DEPT, PHONE, SHIFT, ACTIONS
            columns: [
              _buildDataColumn(context, 'EMPLOYEE'),
              _buildDataColumn(context, 'ROLE & DEPT'),
              _buildDataColumn(context, 'PHONE'),
              _buildDataColumn(context, 'SHIFT'),
              const DataColumn(
                label: Expanded(
                  child: Text('ACTIONS', textAlign: TextAlign.right)
                ),
              ), 
            ],
            rows: Employee.dummyData.map((e) => _buildDataRow(context, e)).toList(),
          ),
        ),
      ),
    );
  }

  DataColumn _buildDataColumn(BuildContext context, String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 11, // Smaller, uppercase header
          letterSpacing: 0.5,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, Employee data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return DataRow(
      onSelectChanged: (_) => _showEmployeeDetails(context, data),
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
           return Colors.transparent; // Transparent rows
        },
      ),
      cells: [
        // Employee Details (Avatar + Name + Email)
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: data.color.withOpacity(0.15),
                  child: Text(
                    data.avatar,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: data.color,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.name, 
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        fontSize: 14,
                      )
                    ),
                    Text(
                      data.email, 
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
        ),
        // Role & Dept
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(data.role, style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500, fontSize: 13)),
              const SizedBox(height: 2),
              Text(data.department, style: GoogleFonts.poppins(fontSize: 11, color: subTextColor)),
            ],
          ),
        ),
        // Phone
        DataCell(
          Text(data.phone, style: GoogleFonts.poppins(fontSize: 13, color: subTextColor)),
        ),
        // Shift
        DataCell(
          Text(data.shift, style: GoogleFonts.poppins(fontSize: 13, color: subTextColor)),
        ),
        // Actions
        DataCell(
           Align(
             alignment: Alignment.centerRight,
             child: _buildActionsMenu(context),
           )
        ),
      ],
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
                  Column(
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
                  const Spacer(),
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

  Widget _buildActionsMenu(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        _showActionsMenu(context, details.globalPosition);
      },
      child: Container(
        color: Colors.transparent, // Hit test target
        padding: const EdgeInsets.all(8),
        child: Icon(Icons.more_vert, color: Theme.of(context).textTheme.bodySmall?.color),
      ),
    );
  }

  void _showActionsMenu(BuildContext context, Offset tapPosition) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent, // No dark overlay for simple dropdown feel
      builder: (context) => Stack(
        children: [
          Positioned(
            top: tapPosition.dy,
            right: MediaQuery.of(context).size.width - tapPosition.dx,
            child: Material( // Required for InkWell visuals inside
              color: Colors.transparent,
              child: GlassContainer(
                width: 160, // Smaller, dropdown-like width
                padding: const EdgeInsets.all(8),
                borderRadius: 16,
                // Ensure proper shadow for "floating" feel since barrier is transparent
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGlassActionButton(
                      context, 
                      icon: Icons.edit_outlined, 
                      label: 'Edit', 
                      onTap: () {
                        Navigator.pop(context);
                        // Handle edit
                      }
                    ),
                    const SizedBox(height: 4),
                    _buildGlassActionButton(
                      context, 
                      icon: Icons.delete_outline, 
                      label: 'Delete', 
                      isDestructive: true,
                      onTap: () {
                        Navigator.pop(context);
                        // Handle delete
                      }
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassActionButton(BuildContext context, {
    required IconData icon, 
    required String label, 
    required VoidCallback onTap,
    bool isDestructive = false
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive ? Colors.redAccent : Theme.of(context).textTheme.bodyLarge?.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.transparent, // Clean look inside dropdown
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
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

  Widget _buildPagination(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing 10 results',
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 13,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {}, 
              icon: Icon(Icons.chevron_left, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
             const SizedBox(width: 8),
             IconButton(
              onPressed: () {}, 
              icon: Icon(Icons.chevron_right, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ],
        )
      ],
    );
  }
}
