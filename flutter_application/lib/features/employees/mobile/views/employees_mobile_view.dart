import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../models/employee_model.dart';
import '../../services/employee_service.dart';
import '../../../../shared/services/auth_service.dart';
import '../../tablet/views/add_employee_view.dart';
import '../../widgets/bulk_upload_report_dialog.dart';
import '../../widgets/glass_confirmation_dialog.dart';

class EmployeesMobileView extends StatefulWidget {
  const EmployeesMobileView({super.key});

  @override
  State<EmployeesMobileView> createState() => _EmployeesMobileViewState();
}

class _EmployeesMobileViewState extends State<EmployeesMobileView> {
  late EmployeeService _employeeService;
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
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
      final dio = Provider.of<AuthService>(context, listen: false).dio;
      final employees = await _employeeService.getEmployees(dio);
      if (!mounted) return;
      setState(() {
        _employees = employees;
        _filterEmployees();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
    if (mounted) setState(() {});
  }

  Set<int> _selectedIds = {};
  bool _isSelectionMode = false;

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _filteredEmployees.length) {
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedIds = _filteredEmployees.map((e) => e.userId).toSet();
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
      final dio = Provider.of<AuthService>(context, listen: false).dio;
      await _employeeService.bulkDeleteEmployees(dio, _selectedIds.toList());
      
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context); // Close loading

      _exitSelectionMode();
      _fetchEmployees();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected employees deleted')));
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }

  Future<void> _deleteEmployee(int id) async {
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
      final dio = Provider.of<AuthService>(context, listen: false).dio;
      await _employeeService.deleteEmployee(dio, id);
      _fetchEmployees();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee deleted')));
    } catch (e) {
      if (!mounted) return;
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
    // Request permissions first
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      // Add other media permissions if needed based on Android version
    ].request();

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
        final dio = Provider.of<AuthService>(context, listen: false).dio;
        
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
          final response = await _employeeService.bulkUploadUsers(dio, file);
          
          if (!mounted) return;
          // Close loading
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
             // Close loading if it's still open
             final nav = Navigator.of(context, rootNavigator: true);
             if (nav.canPop()) {
               nav.pop();
             }
             
             String message = 'Upload Failed: $e';
             // Check for 413 or "Payload Too Large"
             if (e.toString().contains('413') || e.toString().contains('Payload Too Large')) {
                message = 'File is too large for the server. Please try a smaller file.';
             }
             
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        // Navigator.of(context, rootNavigator: true).pop(); // SAFETY: Ensure dialog closed (Removed, handled above)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Failed: $e')));
      }
    }
  }

  void _navigateToAddEdit({Employee? employee}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(employee == null ? 'Add Employee' : 'Edit Employee')),
          body: AddEmployeeView(
            employeeToEdit: employee,
            onCancel: () => Navigator.pop(context),
            onSuccess: () {
              Navigator.pop(context);
              _fetchEmployees();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Provider.of<AuthService>(context, listen: false).user!.isEmployee 
          ? null 
          : FloatingActionButton(
              onPressed: () => _navigateToAddEdit(),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: Column(
        children: [
          // Search & Filters Header OR Selection Header
          Container(
            padding: const EdgeInsets.all(16),
            child: _isSelectionMode 
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _exitSelectionMode,
                      ),
                      const SizedBox(width: 8),
                      Text('${_selectedIds.length} Selected', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      TextButton(
                        onPressed: _toggleSelectAll,
                        child: Text(
                          _selectedIds.length == _filteredEmployees.length ? 'Unselect All' : 'Select All',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: _bulkDelete,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                           child: Row(
                            children: [
                              const Icon(Icons.search, size: 20, color: Colors.grey),
                               const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (val) {
                                    _searchQuery = val;
                                    _filterEmployees();
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Search...',
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!Provider.of<AuthService>(context, listen: false).user!.isEmployee) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: _downloadSampleTemplate, 
                          icon: const Icon(Icons.download),
                          tooltip: 'Download Template',
                        ),
                        IconButton(
                          onPressed: _handleBulkUpload, 
                          icon: const Icon(Icons.upload_file),
                          tooltip: 'Bulk Upload',
                        ),
                      ],
                    ],
                  ),
          ),
          
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _filteredEmployees.isEmpty 
                    ? const Center(child: Text('No employees found'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final emp = _filteredEmployees[index];
                          final isSelected = _selectedIds.contains(emp.userId);
                          final isDark = Theme.of(context).brightness == Brightness.dark;

                          // Content for the card/glass container
                          final childContent = ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: _isSelectionMode
                                  ? Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => _toggleSelection(emp.userId),
                                      activeColor: Theme.of(context).primaryColor,
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: isDark ? Border.all(color: Colors.blue, width: 2) : null,
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.1),
                                        child: Text(
                                          emp.userName.isNotEmpty ? emp.userName[0].toUpperCase() : '?',
                                          style: TextStyle(color: isDark ? Colors.white : Theme.of(context).primaryColor),
                                        ),
                                      ),
                                    ),
                              title: Text(emp.userName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: isDark ? Colors.white : null)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(emp.designation ?? 'N/A', style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white70 : null)),
                                  Text(emp.phoneNo ?? 'N/A', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              trailing: (_isSelectionMode || Provider.of<AuthService>(context, listen: false).user!.isEmployee) 
                                  ? null 
                                  : PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert, color: isDark ? Colors.white70 : null),
                                      onSelected: (val) {
                                        if (val == 'edit') _navigateToAddEdit(employee: emp);
                                        if (val == 'delete') _deleteEmployee(emp.userId);
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleSelection(emp.userId);
                                } else {
                                  _showEmployeeDetails(context, emp);
                                }
                              },
                              onLongPress: () {
                                if (!_isSelectionMode && !Provider.of<AuthService>(context, listen: false).user!.isEmployee) {
                                  setState(() {
                                    _isSelectionMode = true;
                                    _toggleSelection(emp.userId);
                                  });
                                }
                              },
                            );

                          if (isDark) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: GlassContainer(
                                child: childContent,
                              ),
                            );
                          } else {
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected 
                                    ? Theme.of(context).primaryColor 
                                    : Colors.grey.withOpacity(0.2),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: childContent,
                            );
                          }
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showEmployeeDetails(BuildContext context, Employee employee) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, // Important for GlassContainer
        insetPadding: const EdgeInsets.all(16),
        child: isDark 
          ? GlassContainer(child: _buildDialogContent(context, employee, isDark)) 
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)
              ),
              child: _buildDialogContent(context, employee, isDark)
            ),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context, Employee employee, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isDark ? Border.all(color: Colors.blue, width: 2) : null,
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                employee.userName.isNotEmpty ? employee.userName[0].toUpperCase() : '?', 
                style: TextStyle(fontSize: 32, color: isDark ? Colors.white : Theme.of(context).primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(employee.userName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
          Text(employee.designation ?? 'N/A', style: GoogleFonts.poppins(color: Colors.grey)),
          Divider(height: 32, color: isDark ? Colors.white24 : null),
          _buildDetailRow('Email', employee.email, isDark),
          _buildDetailRow('Phone', employee.phoneNo ?? 'N/A', isDark),
          _buildDetailRow('Dept', employee.department ?? 'N/A', isDark),
          _buildDetailRow('Shift', employee.shift ?? 'N/A', isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value, 
              style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : null),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
