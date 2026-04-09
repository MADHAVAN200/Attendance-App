import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application/shared/widgets/toast_helper.dart';

class SalaryPackagesTabView extends StatefulWidget {
  const SalaryPackagesTabView({super.key});

  @override
  State<SalaryPackagesTabView> createState() => _SalaryPackagesTabViewState();
}

class _SalaryPackagesTabViewState extends State<SalaryPackagesTabView> {
  final bool _isLoading = false;
  String _searchQuery = '';

  // Demo / loaded package groups matching Attendance-Web structure
  final List<Map<String, dynamic>> _packageGroups = [
    {
      'id': 'pkg_1',
      'name': 'Standard Engineering Tier',
      'gross_salary': 45000.0,
      'overtime_enabled': true,
      'overtime_rate': 250.0,
      'assigned_count': 12,
      'effective_from': '2026-01-01',
    },
    {
      'id': 'pkg_2',
      'name': 'Site Operations & Supervisors',
      'gross_salary': 35000.0,
      'overtime_enabled': true,
      'overtime_rate': 200.0,
      'assigned_count': 18,
      'effective_from': '2026-01-01',
    },
    {
      'id': 'pkg_3',
      'name': 'Administrative & Support Staff',
      'gross_salary': 28000.0,
      'overtime_enabled': false,
      'overtime_rate': 0.0,
      'assigned_count': 8,
      'effective_from': '2026-01-01',
    },
    {
      'id': 'pkg_4',
      'name': 'Executive & Project Leads',
      'gross_salary': 85000.0,
      'overtime_enabled': false,
      'overtime_rate': 0.0,
      'assigned_count': 5,
      'effective_from': '2026-01-01',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    final filtered = _packageGroups.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Salary Packages & Compensation",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      "Configure salary package groups, overtime rates, and wage rules",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size.zero,
                ),
                onPressed: () => _showAddPackageModal(context, isDark),
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                label: Text(
                  "Add Package",
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Search Bar
          SizedBox(
            height: 38,
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: "Search package groups by title...",
                hintStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, size: 16),
                fillColor: isDark ? const Color(0xFF161B22) : Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Packages List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          "No salary package groups found",
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final pkg = filtered[index];
                          return _buildPackageCard(pkg, isDark, currencyFormatter);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> pkg, bool isDark, NumberFormat formatter) {
    final hasOvertime = pkg['overtime_enabled'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title + Assigned Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  pkg['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${pkg['assigned_count']} Employees",
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Metrics Strip
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("MONTHLY GROSS", style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(
                      formatter.format(pkg['gross_salary']),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("OVERTIME", style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(
                      hasOvertime ? "${formatter.format(pkg['overtime_rate'])} / hr" : "Disabled",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: hasOvertime ? const Color(0xFFF59E0B) : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("EFFECTIVE FROM", style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(
                      pkg['effective_from'],
                      style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? Colors.white70 : Colors.black87),
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

  void _showAddPackageModal(BuildContext context, bool isDark) {
    final nameCtrl = TextEditingController();
    final grossCtrl = TextEditingController();
    final otCtrl = TextEditingController();
    bool otEnabled = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 16,
            left: 18,
            right: 18,
            top: 18,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Salary Package Group",
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                style: GoogleFonts.poppins(fontSize: 12),
                decoration: InputDecoration(
                  labelText: "Package Group Name",
                  labelStyle: GoogleFonts.poppins(fontSize: 11),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: grossCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(fontSize: 12),
                decoration: InputDecoration(
                  labelText: "Monthly Gross Salary (₹)",
                  labelStyle: GoogleFonts.poppins(fontSize: 11),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Enable Overtime Pay", style: GoogleFonts.poppins(fontSize: 12)),
                value: otEnabled,
                onChanged: (val) => setModalState(() => otEnabled = val),
              ),
              if (otEnabled) ...[
                TextField(
                  controller: otCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(fontSize: 12),
                  decoration: InputDecoration(
                    labelText: "Overtime Rate (₹ / hr)",
                    labelStyle: GoogleFonts.poppins(fontSize: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty || grossCtrl.text.trim().isEmpty) {
                      context.showToast("Please fill in package name and gross salary", isSuccess: false);
                      return;
                    }
                    setState(() {
                      _packageGroups.add({
                        'id': 'pkg_${DateTime.now().millisecondsSinceEpoch}',
                        'name': nameCtrl.text.trim(),
                        'gross_salary': double.tryParse(grossCtrl.text.trim()) ?? 30000.0,
                        'overtime_enabled': otEnabled,
                        'overtime_rate': double.tryParse(otCtrl.text.trim()) ?? 0.0,
                        'assigned_count': 0,
                        'effective_from': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      });
                    });
                    Navigator.pop(modalCtx);
                    context.showToast("Salary Package Group created!", isSuccess: true);
                  },
                  child: Text("Save Package", style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// [upd:2026-04-09T08:30:00+05:30]
