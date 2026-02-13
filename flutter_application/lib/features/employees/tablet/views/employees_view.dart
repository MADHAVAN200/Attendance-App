import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../shared/widgets/glass_container.dart';
import '../../models/employee_model.dart';
import '../../services/employee_service.dart';
import '../../../../shared/services/auth_service.dart';
import 'add_employee_view.dart';
import '../../widgets/bulk_upload_report_dialog.dart';
import '../../widgets/glass_confirmation_dialog.dart';

class EmployeesView extends StatefulWidget {
  const EmployeesView({super.key});

  @override
  State<EmployeesView> createState() => _EmployeesViewState();
}

class _EmployeesViewState extends State<EmployeesView> {
  late EmployeeService _employeeService;
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Employee? _editingEmployee;
  bool _isAddingOrEditing = false;
  Set<int> _selectedIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _employeeService = EmployeeService(authService);
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() => _isLoading = true);
    try {
      final employees = await _employeeService.getEmployees();
      setState(() {
        _employees = employees;
        _filterEmployees();
        _isLoading = false;
        _selectedIds.clear(); // Clear selection on refresh
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _filterEmployees() {
    if (_searchQuery.isEmpty) {
      _filteredEmployees = _employees;
    } else {
      _filteredEmployees = _employees.where((e) =>
        e.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        e.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (e.phoneNo?.contains(_searchQuery) ?? false)
      ).toList();
    }
    setState(() {}); // Refresh UI
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds = _filteredEmployees.map((e) => e.userId).toSet();
      } else {
        _selectedIds.clear();
        _isSelectionMode = false;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _bulkDelete() async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => GlassConfirmationDialog(
        title: 'Confirm Bulk Delete',
        content: 'Are you sure you want to delete ${_selectedIds.length} employees?',
        confirmLabel: 'Delete',
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (confirm != true) return;

    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      await _employeeService.bulkDeleteEmployees(_selectedIds.toList());
      
      if (!mounted) return;
      
      // Close Loading with defensive pop
      if (Navigator.canPop(context)) Navigator.pop(context);

      setState(() {
        _selectedIds.clear();
      });
      _fetchEmployees(); // Refresh list
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected employees deleted')));
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }

  Future<void> _deleteEmployee(int id) async {
    // Confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => GlassConfirmationDialog(
        title: 'Confirm Delete',
        content: 'Are you sure you want to delete this employee?',
        confirmLabel: 'Delete',
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (confirm != true) return;

    try {
      await _employeeService.deleteEmployee(id);
      _fetchEmployees(); // Refresh list
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }

  Future<void> _downloadSampleTemplate() async {
    try {
      String path;
      if (Platform.isAndroid) {
        path = '/storage/emulated/0/Download/attendance_template.csv';
      } else {
        final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
        path = '${dir.path}/attendance_template.csv';
      }
      
      final file = File(path);
      await file.writeAsString("Name,Email,Phone,Department,Designation,Password\n"
          "John Doe,john.doe@example.com,9876543210,Engineering,Manager,Mano@123\n"
          "Jane Smith,jane.smith@example.com,9876543211,Human Resources,HR Executive,Mano@123\n"
          "Alice Johnson,alice.j@example.com,9876543212,Sales,Sales Executive,Mano@123");
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Template saved to $path'), 
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save template: $e')));
    }
  }

  Future<void> _handleBulkUpload() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        
        // 1. File Size Check (Max 5MB)
        if (file.lengthSync() > 5 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File is too large. Max size is 5MB.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
          );
          return;
        }

        if (!mounted) return;
        
        // Show loading indicator
        if (!mounted) return;
        showDialog(
          context: context, 
          barrierDismissible: false, 
          builder: (_) => WillPopScope(
            onWillPop: () async => false,
            child: const Center(child: CircularProgressIndicator()),
          ),
        );
        
        try {
          final response = await _employeeService.bulkUploadUsers(file);
          
          if (!mounted) return;
          // Close loading safely
          final nav = Navigator.of(context, rootNavigator: true);
          if (nav.canPop()) {
            nav.pop();
          }
          
          final report = response['report'];
          if (report != null) {
            await showDialog(
              context: context,
              builder: (context) => BulkUploadReportDialog(
                report: report,
              ),
            );
            _fetchEmployees();
          } else {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bulk Upload Processed (No Report)')));
             _fetchEmployees();
          }
        } catch (e) {
             if (!mounted) return;
             // Close loading safely
             final nav = Navigator.of(context, rootNavigator: true);
             if (nav.canPop()) {
               nav.pop();
             }
             
             String message = 'Upload Failed: $e';
             if (e.toString().contains('413') || e.toString().contains('Payload Too Large')) {
                message = 'File is too large for the server. Please check the file size limits.';
             }
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        // Navigator.pop(context); // Handled above
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAddingOrEditing) {
      return AddEmployeeView(
        employeeToEdit: _editingEmployee, // Assuming you update AddEmployeeView to accept this
        onCancel: () {
          setState(() {
            _isAddingOrEditing = false;
            _editingEmployee = null;
          });
        },
        onSuccess: () {
          setState(() {
            _isAddingOrEditing = false;
            _editingEmployee = null;
          });
          _fetchEmployees();
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
          _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildEmployeesTable(context),
          
          if (!_isLoading) ...[
            const SizedBox(height: 24),
            _buildPagination(context),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
      if (_isSelectionMode) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: _exitSelectionMode, 
              icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black87, size: 22),
              tooltip: 'Exit Selection',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),
            Text(
              '${_selectedIds.length} Selected',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, 
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            // Select/Unselect All
            TextButton.icon(
              onPressed: () => _toggleSelectAll(_selectedIds.length != _filteredEmployees.length),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              icon: Icon(
                _selectedIds.length == _filteredEmployees.length ? Icons.deselect : Icons.select_all,
                color: isDark ? Colors.blue[400] : Theme.of(context).primaryColor,
                size: 20,
              ),
              label: Text(
                _selectedIds.length == _filteredEmployees.length ? 'Unselect All' : 'Select All',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.blue[400] : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Bulk Delete Button
            _buildActionButton(
              context,
              label: 'Delete (${_selectedIds.length})',
              icon: Icons.delete_outline,
              isPrimary: false,
              onTap: _bulkDelete,
            ),
          ],
        ),
      );
    }

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
                    onChanged: (val) {
                      _searchQuery = val;
                      _filterEmployees();
                    },
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
        const Spacer(),

        if (!Provider.of<AuthService>(context, listen: false).user!.isEmployee) ...[
          // 3. Action Buttons
          _buildActionButton(
            context, 
            label: 'Template', 
            icon: Icons.download,
            isPrimary: false,
            isCompact: true, 
            onTap: _downloadSampleTemplate,
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            context, 
            label: 'Bulk Upload', 
            icon: Icons.upload_file_outlined,
            isPrimary: false,
            isCompact: false, 
            onTap: _handleBulkUpload,
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            context, 
            label: 'Add Employee', 
            icon: Icons.add,
            isPrimary: true,
            onTap: () {
              setState(() {
                _editingEmployee = null;
                _isAddingOrEditing = true;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required String label, 
    required IconData icon, 
    required bool isPrimary,
    bool isCompact = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isPrimary ? primaryColor : (isDark ? const Color(0xFF1E2939) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(
            color: isDark ? const Color(0xFF1E2939) : primaryColor.withOpacity(0.1)
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
    if (_filteredEmployees.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text('No employees found', style: GoogleFonts.poppins(color: Colors.grey)),
      ));
    }
  
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.transparent),
            columnSpacing: 16, 
            horizontalMargin: 16, 
            dataRowMaxHeight: 85,
            showCheckboxColumn: false, // Custom implementation
            columns: [
              // Checkbox Column (Only in Selection Mode)
              if (_isSelectionMode)
                DataColumn(
                  label: Checkbox(
                    value: _filteredEmployees.isNotEmpty && _selectedIds.length == _filteredEmployees.length,
                    onChanged: (val) => _toggleSelectAll(val),
                    activeColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).disabledColor),
                  ),
                ),
              _buildDataColumn(context, 'EMPLOYEE'),
              _buildDataColumn(context, 'ROLE & DEPT'),
              _buildDataColumn(context, 'PHONE'),
              _buildDataColumn(context, 'SHIFT'),
              if (!Provider.of<AuthService>(context, listen: false).user!.isEmployee)
                 const DataColumn(label: Expanded(child: Text('ACTIONS', textAlign: TextAlign.right))), 
            ],
            rows: _filteredEmployees.map((e) => _buildDataRow(context, e)).toList(),
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
          fontSize: 11,
          letterSpacing: 0.5,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, Employee data) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final nameInitial = data.userName.isNotEmpty ? data.userName[0].toUpperCase() : '?';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DataRow(
      selected: _selectedIds.contains(data.userId),
      onLongPress: () {
        if (!_isSelectionMode && !Provider.of<AuthService>(context, listen: false).user!.isEmployee) {
          setState(() {
            _isSelectionMode = true;
            _toggleSelection(data.userId);
          });
        }
      },
      onSelectChanged: (_) {
        if (_isSelectionMode) {
          _toggleSelection(data.userId);
        } else {
          _showEmployeeDetails(context, data);
        }
      },
      cells: [
        // Checkbox (Only in Selection Mode)
        if (_isSelectionMode)
          DataCell(
            Checkbox(
              value: _selectedIds.contains(data.userId),
              onChanged: (val) => _toggleSelection(data.userId),
              activeColor: Theme.of(context).primaryColor,
              side: BorderSide(color: Theme.of(context).disabledColor),
            ),
          ),
        // Employee
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isDark ? Border.all(color: Colors.blue, width: 2) : null,
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: isDark ? const Color(0xFF101828) : Theme.of(context).primaryColor.withOpacity(0.1),
                    child: data.profileImage != null && data.profileImage!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: data.profileImage!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Text(
                                nameInitial,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, 
                                  color: isDark ? Colors.white : Theme.of(context).primaryColor,
                                ),
                              ),
                              errorWidget: (context, url, error) => Text(
                                nameInitial,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, 
                                  color: isDark ? Colors.white : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            nameInitial,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, 
                              color: isDark ? Colors.white : Theme.of(context).primaryColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(data.userName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor, fontSize: 14)),
                    Text(data.email, style: GoogleFonts.poppins(fontSize: 12, color: subTextColor)),
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
              Text(data.designation ?? 'N/A', style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500, fontSize: 13)),
              const SizedBox(height: 2),
              Text(data.department ?? 'N/A', style: GoogleFonts.poppins(fontSize: 11, color: subTextColor)),
            ],
          ),
        ),
        // Phone
        DataCell(Text(data.phoneNo ?? 'N/A', style: GoogleFonts.poppins(fontSize: 13, color: subTextColor))),
        // Shift
        DataCell(Text(data.shift ?? 'N/A', style: GoogleFonts.poppins(fontSize: 13, color: subTextColor))),
        // Actions
        if (!Provider.of<AuthService>(context, listen: false).user!.isEmployee)
          DataCell(Align(alignment: Alignment.centerRight, child: _buildActionsMenu(context, data))),
      ],
    );
  }

  Widget _buildActionsMenu(BuildContext context, Employee employee) {
    return IconButton(
      icon: Icon(Icons.more_vert, color: Theme.of(context).textTheme.bodySmall?.color),
      onPressed: () => _showEmployeeActionSheet(employee),
    );
  }

  void _showEmployeeActionSheet(Employee employee) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
             color: isDark ? const Color(0xFF1E2939) : Colors.white,
             borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, 
                height: 4, 
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300], 
                  borderRadius: BorderRadius.circular(2)
                ),
              ),
              _buildActionItem(
                context, 
                icon: Icons.edit_outlined, 
                label: 'Edit Employee', 
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _editingEmployee = employee;
                    _isAddingOrEditing = true;
                  });
                }
              ),
              const SizedBox(height: 8),
              _buildActionItem(
                context, 
                icon: Icons.delete_outline, 
                label: 'Delete Employee', 
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _deleteEmployee(employee.userId);
                }
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  Widget _buildActionItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? (isDark ? Colors.white : Colors.black87), size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color ?? (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmployeeDetails(BuildContext context, Employee employee) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Reusing the nice dialog from before, but populated with real data
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
               Row(
                children: [
                   Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isDark ? Border.all(color: Colors.blue, width: 2) : null,
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: isDark ? const Color(0xFF101828) : Theme.of(context).primaryColor.withOpacity(0.15),
                      child: employee.profileImage != null && employee.profileImage!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: CachedNetworkImage(
                                imageUrl: employee.profileImage!,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Text(
                                  employee.userName.isNotEmpty ? employee.userName[0].toUpperCase() : '?',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Theme.of(context).primaryColor,
                                    fontSize: 24,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Text(
                                  employee.userName.isNotEmpty ? employee.userName[0].toUpperCase() : '?',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Theme.of(context).primaryColor,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              employee.userName.isNotEmpty ? employee.userName[0].toUpperCase() : '?',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Theme.of(context).primaryColor,
                                fontSize: 24,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(employee.userName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(employee.designation ?? 'N/A', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(context, Icons.email_outlined, 'Email', employee.email),
              const SizedBox(height: 16),
              _buildDetailRow(context, Icons.phone_outlined, 'Phone', employee.phoneNo ?? 'N/A'),
              const SizedBox(height: 16),
              _buildDetailRow(context, Icons.work_outline, 'Department', employee.department ?? 'N/A'),
              const SizedBox(height: 16),
              _buildDetailRow(context, Icons.access_time, 'Shift', employee.shift ?? 'N/A'),
              const SizedBox(height: 24),
               SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
     return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColor),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildPagination(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Showing ${_filteredEmployees.length} results', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
        // Placeholder pagination buttons
        const Row(children: [Icon(Icons.chevron_left), Icon(Icons.chevron_right)]),
      ],
    );
  }
}
