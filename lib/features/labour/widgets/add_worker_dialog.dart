import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../models/labour_models.dart';

class AddWorkerDialog extends StatefulWidget {
  final LabourWorker? initialWorker;
  final List<LabourSite> availableSites;
  final Function(Map<String, dynamic> data) onSave;

  const AddWorkerDialog({
    super.key,
    this.initialWorker,
    required this.availableSites,
    required this.onSave,
  });

  @override
  State<AddWorkerDialog> createState() => _AddWorkerDialogState();
}

class _AddWorkerDialogState extends State<AddWorkerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dailyWageController;
  late TextEditingController _otRateController;
  late String _sex;
  late String _role;
  int? _selectedSiteId;

  final List<String> _skillsList = [
    'Mason',
    'Carpenter',
    'Electrician',
    'Plumber',
    'Welder',
    'Painter',
    'Helper',
    'Foreman',
    'Supervisor',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialWorker?.name ?? '');
    _phoneController = TextEditingController(text: widget.initialWorker?.phone ?? '');
    _dailyWageController = TextEditingController(text: widget.initialWorker?.monthlySalary.toString() ?? '800');
    _otRateController = TextEditingController(text: widget.initialWorker?.overtimePayPerHour.toString() ?? '120');
    _sex = widget.initialWorker?.sex ?? 'Male';
    _role = widget.initialWorker?.role ?? 'Helper';
    _selectedSiteId = widget.initialWorker?.siteId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dailyWageController.dispose();
    _otRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 20,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.initialWorker == null ? "REGISTER WORKER" : "EDIT WORKER",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text("WORKER NAME", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Full Name",
                    fillColor: isDark ? const Color(0xFF161B22) : Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("PHONE NUMBER", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.poppins(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: "Mobile No",
                              fillColor: isDark ? const Color(0xFF161B22) : Colors.grey[100],
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("GENDER", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF161B22) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sex,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 'Male', child: Text("Male")),
                                  DropdownMenuItem(value: 'Female', child: Text("Female")),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _sex = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text("SKILL / ROLE MAPPING", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 4),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _skillsList.contains(_role) ? _role : _skillsList.first,
                      isExpanded: true,
                      items: _skillsList.map((skill) {
                        return DropdownMenuItem(value: skill, child: Text(skill));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _role = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("DAILY WAGE (₹)", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _dailyWageController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: "800",
                              fillColor: isDark ? const Color(0xFF161B22) : Colors.grey[100],
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("OT RATE / HR (₹)", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _otRateController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: "120",
                              fillColor: isDark ? const Color(0xFF161B22) : Colors.grey[100],
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text("ASSIGNED SITE", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 4),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: widget.availableSites.any((s) => s.siteId == _selectedSiteId) ? _selectedSiteId : null,
                      isExpanded: true,
                      hint: Text("Unassigned Site", style: GoogleFonts.poppins(fontSize: 13)),
                      items: [
                        const DropdownMenuItem<int?>(value: null, child: Text("Unassigned")),
                        ...widget.availableSites.map((s) {
                          return DropdownMenuItem<int?>(value: s.siteId, child: Text(s.siteName));
                        }),
                      ],
                      onChanged: (val) => setState(() => _selectedSiteId = val),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("CANCEL", style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B60F6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSave({
                            'name': _nameController.text.trim(),
                            'phone': _phoneController.text.trim(),
                            'sex': _sex,
                            'role': _role,
                            'wage_type': 'Daily Wage',
                            'monthly_salary': double.tryParse(_dailyWageController.text) ?? 800.0,
                            'allowed_leaves': 0,
                            'site_id': _selectedSiteId,
                            'overtime_pay_per_hour': double.tryParse(_otRateController.text) ?? 120.0,
                            'status': 'Active',
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Text("SAVE WORKER", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
