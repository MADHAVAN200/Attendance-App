import 'package:flutter/material.dart';
import '../../../shared/widgets/responsive_builder.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Dropdown Values
  String? _selectedDept;
  String? _selectedDesignation;
  String? _selectedShift;
  String _userType = 'employee';

  // Mock Data
  final List<String> _departments = ['Engineering', 'Sales', 'Marketing', 'HR', 'Operations'];
  final List<String> _designations = ['Developer', 'Manager', 'Designer', 'Executive', 'Intern'];
  final List<String> _shifts = ['General Shift (9-6)', 'Morning Shift (6-3)', 'Night Shift (8-5)'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Employee created successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBuilder.isMobile(context);

    return Scaffold(
      // backgroundColor: const Color(0xFFF3F4F6), // Removed to use theme default
      appBar: AppBar(
        title: Text('Add New Employee', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Icon(Icons.save, size: 20),
              label: Text(_isSaving ? 'Saving...' : 'Save', style: const TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4F46E5), // Primary color
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Center(
          child: Container(
             constraints: const BoxConstraints(maxWidth: 1000),
             child: Form(
               key: _formKey,
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   if (!isMobile) ...[
                     _buildSectionHeader(Icons.person, 'Personal Information'),
                     const SizedBox(height: 24),
                     _buildTwoColumnRow(
                       _buildTextField('Full Name', _nameController, required: true),
                       _buildTextField('Password', _passwordController, isPassword: true, required: true),
                     ),
                     const SizedBox(height: 16),
                     _buildTwoColumnRow(
                       _buildTextField('Email Address', _emailController, required: true, inputType: TextInputType.emailAddress),
                       _buildTextField('Phone Number', _phoneController, inputType: TextInputType.phone),
                     ),
                     
                     const SizedBox(height: 32),
                     const Divider(),
                     const SizedBox(height: 32),
                     
                     _buildSectionHeader(Icons.work, 'Work Details'),
                     const SizedBox(height: 24),
                     _buildTwoColumnRow(
                       _buildDropdown('Department', _departments, _selectedDept, (val) => setState(() => _selectedDept = val)),
                       _buildDropdown('Designation', _designations, _selectedDesignation, (val) => setState(() => _selectedDesignation = val)),
                     ),
                     const SizedBox(height: 16),
                     _buildTwoColumnRow(
                       _buildDropdown('Shift', _shifts, _selectedShift, (val) => setState(() => _selectedShift = val)),
                       _buildDropdown('User Type', ['employee', 'admin', 'HR'], _userType, (val) => setState(() => _userType = val!)),
                     ),
                   ] else ...[
                     // Mobile: Single Column Stack
                     _buildSectionHeader(Icons.person, 'Personal Information'),
                     const SizedBox(height: 16),
                     _buildTextField('Full Name', _nameController, required: true),
                     const SizedBox(height: 16),
                     _buildTextField('Password', _passwordController, isPassword: true, required: true),
                     const SizedBox(height: 16),
                     _buildTextField('Email Address', _emailController, required: true, inputType: TextInputType.emailAddress),
                     const SizedBox(height: 16),
                     _buildTextField('Phone Number', _phoneController, inputType: TextInputType.phone),
                     
                     const SizedBox(height: 32),
                     _buildSectionHeader(Icons.work, 'Work Details'),
                     const SizedBox(height: 16),
                     _buildDropdown('Department', _departments, _selectedDept, (val) => setState(() => _selectedDept = val)),
                     const SizedBox(height: 16),
                     _buildDropdown('Designation', _designations, _selectedDesignation, (val) => setState(() => _selectedDesignation = val)),
                     const SizedBox(height: 16),
                     _buildDropdown('Shift', _shifts, _selectedShift, (val) => setState(() => _selectedShift = val)),
                     const SizedBox(height: 16),
                     _buildDropdown('User Type', ['employee', 'admin', 'HR'], _userType, (val) => setState(() => _userType = val!)),
                   ]
                 ],
               ),
             ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTwoColumnRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 24),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {
    bool isPassword = false, 
    bool required = false,
    TextInputType inputType = TextInputType.text
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: inputType,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          validator: required ? (val) => val == null || val.isEmpty ? '$label is required' : null : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8),
               borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? currentValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, false), // Dropdowns usually have a default or 'Select' state
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentValue,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))).toList(),
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).iconTheme.color),
          dropdownColor: Theme.of(context).cardColor,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
             focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8),
               borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label, bool required) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        if (required)
          const Text(' *', style: TextStyle(color: Colors.red)),
      ],
    );
  }
}
