import 'package:flutter/material.dart';
import '../models/employee.dart';
import 'bulk_upload_screen.dart';
import 'add_employee_screen.dart';
import '../../../shared/widgets/responsive_builder.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final List<Employee> _employees = [
    Employee(
      id: '1',
      name: 'Mano Admin',
      email: 'admin@demo.com',
      role: 'Manager',
      department: 'Engineering',
      phone: '5',
      shift: 'General Shift',
    ),
    Employee(
      id: '2',
      name: 'Jane Smith',
      email: 'jane@demo.com',
      role: 'HR Executive',
      department: 'Human Resources',
      phone: '9876543212',
      shift: 'General Shift',
    ),
    Employee(
      id: '3',
      name: 'Kesavan M',
      email: 'hmmmmnicebike@gmail.com',
      role: 'Intern',
      department: 'Human Resources',
      phone: '-',
      shift: 'General Shift',
    ),
    Employee(
      id: '4',
      name: 'Mano',
      email: 'meubixuk.9@gmail.com',
      role: 'HR Executive',
      department: 'Engineering',
      phone: '6',
      shift: 'General Shift',
    ),
    Employee(
      id: '5',
      name: 'Sathish dadar',
      email: 's@a',
      role: 'HR Executive',
      department: 'Human Resources',
      phone: '-',
      shift: 'General Shift',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
               boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return constraints.maxWidth < 900
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 900,
                          child: _buildTable(context),
                        ),
                      )
                    : _buildTable(context);
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    InputDecoration searchDecor = InputDecoration(
      hintText: 'Search employees...',
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
      prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
    );

    return Flex(
      direction: ResponsiveBuilder.isMobile(context) ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ResponsiveBuilder.isMobile(context))
          Column(
            children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                ),
                child: TextField(decoration: searchDecor),
              ),
              const SizedBox(height: 12),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Text('All Status', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(width: 8),
                    Icon(Icons.filter_list, size: 20, color: Theme.of(context).iconTheme.color),
                  ],
                ),
              ),
            ],
          )
        else
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                    ),
                    child: TextField(decoration: searchDecor),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Text('All Status', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      Icon(Icons.filter_list, size: 20, color: Theme.of(context).iconTheme.color),
                    ],
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: ResponsiveBuilder.isMobile(context) ? 16 : 0, width: ResponsiveBuilder.isMobile(context) ? 0 : 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BulkUploadScreen()),
                );
              },
              icon: Icon(Icons.file_upload_outlined, size: 20, color: Theme.of(context).iconTheme.color),
              label: Text('Bulk Upload', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
                );
              },
              icon: const Icon(Icons.add, size: 20, color: Colors.white),
              label: const Text('Add Employee', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B60F6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('EMPLOYEE', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
              Expanded(
                flex: 2,
                child: Text('ROLE & DEPT', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
              Expanded(
                flex: 2,
                child: Text('SHIFT', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ],
          ),
        ),
        // Table Body
        ..._employees.map((e) {
          return InkWell(
            onTap: () => _showEmployeeDetails(context, e),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                   // Employee Column
                   Expanded(
                     flex: 3,
                     child: Row(
                       children: [
                         CircleAvatar(
                           backgroundColor: const Color(0xFFE0E7FF),
                           child: Text(e.name[0], style: const TextStyle(color: Color(0xFF4338CA), fontWeight: FontWeight.bold)),
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(e.name, 
                                 style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color),
                                 overflow: TextOverflow.ellipsis,
                               ),
                               Text(e.email, 
                                 style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ),
                   // Role Column
                   Expanded(
                     flex: 2,
                     child: Padding(
                       padding: const EdgeInsets.only(right: 8.0),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(e.role, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color), overflow: TextOverflow.ellipsis),
                           Text(e.department, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12), overflow: TextOverflow.ellipsis),
                         ],
                       ),
                     ),
                   ),
                   // Shift Column
                   Expanded(
                      flex: 2,
                      child: Text(e.shift, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color), overflow: TextOverflow.ellipsis),
                   ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showEmployeeDetails(BuildContext context, Employee e) {
    showDialog(
      context: context,
      builder: (context) {
        final isMobile = ResponsiveBuilder.isMobile(context);
        return Dialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 600,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFFE0E7FF),
                          child: Text(e.name[0], style: const TextStyle(color: Color(0xFF4338CA), fontWeight: FontWeight.bold, fontSize: 20)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(e.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                               const SizedBox(height: 4),
                               Text(e.role, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                    const SizedBox(height: 24),
                    
                    // Responsive Grid for Details
                    if (isMobile) ...[
                       _buildDetailRow(context, Icons.email_outlined, 'Email', e.email),
                       const SizedBox(height: 16),
                       _buildDetailRow(context, Icons.phone_outlined, 'Phone', e.phone),
                       const SizedBox(height: 16),
                       _buildDetailRow(context, Icons.business_outlined, 'Department', e.department),
                       const SizedBox(height: 16),
                       _buildDetailRow(context, Icons.access_time, 'Shift', e.shift),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(child: _buildDetailRow(context, Icons.email_outlined, 'Email', e.email)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildDetailRow(context, Icons.phone_outlined, 'Phone', e.phone)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: _buildDetailRow(context, Icons.business_outlined, 'Department', e.department)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildDetailRow(context, Icons.access_time, 'Shift', e.shift)),
                        ],
                      ),
                    ],
  
                    const SizedBox(height: 32),
                    
                    // Actions Footer
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                               Navigator.pop(context);
                               // Handle Delete
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                               Navigator.pop(context);
                               // Handle Edit
                            },
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
      ],
    );
  }
}
