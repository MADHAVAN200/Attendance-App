import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/loading_screen.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/toast_helper.dart';
import '../models/labour_models.dart';
import '../services/labour_service.dart';
import '../widgets/labour_common_widgets.dart';
import '../widgets/add_site_dialog.dart';
import '../widgets/add_worker_dialog.dart';

class LabourTabletContent extends StatefulWidget {
  const LabourTabletContent({super.key});

  @override
  State<LabourTabletContent> createState() => _LabourTabletContentState();
}

class _LabourTabletContentState extends State<LabourTabletContent> {
  late LabourService _labourService;
  bool _isLoading = false;
  int _activeNavIndex = 0; // 0: Sites, 1: Workers, 2: Check-In, 3: Payouts

  // Data
  List<LabourSite> _sites = [];
  List<LabourWorker> _workers = [];
  List<LabourAttendanceItem> _attendanceList = [];
  List<LabourPayoutSummary> _payouts = [];

  // Filter / Selection
  int? _selectedSiteId;
  DateTime _attendanceDate = DateTime.now();
  String _searchQuery = '';
  final String _skillFilter = 'All';

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _labourService = LabourService(authService.dio);

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final sites = await _labourService.getSites();
      final workers = await _labourService.getLabours();

      if (mounted) {
        setState(() {
          _sites = sites;
          _workers = workers;
          if (_selectedSiteId == null && sites.isNotEmpty) {
            _selectedSiteId = sites.first.siteId;
          }
        });
      }

      if (_selectedSiteId != null) {
        await _loadAttendance();
      }
      await _loadPayouts();
    } catch (e) {
      if (mounted) context.showExceptionToast(e, fallback: "Failed to load tablet data.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAttendance() async {
    if (_selectedSiteId == null) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(_attendanceDate);
    final list = await _labourService.getSiteAttendance(_selectedSiteId!, dateStr);
    if (mounted) setState(() => _attendanceList = list);
  }

  Future<void> _loadPayouts() async {
    final monthStr = DateFormat('yyyy-MM').format(DateTime.now());
    final list = await _labourService.getFinancesSummary(monthStr, siteId: _selectedSiteId);
    if (mounted) setState(() => _payouts = list);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LoadingScreen(
      isLoading: _isLoading,
      message: "Loading Labour Portal...",
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Full Width Edge-to-Edge Navigation Tab Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: isDark ? const Color(0xFF263040) : Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildFullWidthNavChip(0, Icons.business_rounded, "Contract Sites (${_sites.length})", isDark)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildFullWidthNavChip(1, Icons.people_alt_rounded, "Worker Directory (${_workers.length})", isDark)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildFullWidthNavChip(2, Icons.fact_check_rounded, "Daily Site Check-In", isDark)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildFullWidthNavChip(3, Icons.payments_rounded, "Payouts & Advances", isDark)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Excel Grid Workspace Container
            Expanded(
              child: _buildActiveTabContent(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthNavChip(int index, IconData icon, String title, bool isDark) {
    final isSelected = _activeNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeNavIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B60F6) : (isDark ? const Color(0xFF0D1117) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700])),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(BuildContext context, bool isDark) {
    switch (_activeNavIndex) {
      case 0:
        return _buildSitesCanvas(context, isDark);
      case 1:
        return _buildWorkersCanvas(context, isDark);
      case 2:
        return _buildCheckInCanvas(context, isDark);
      case 3:
        return _buildPayoutsCanvas(context, isDark);
      default:
        return Container();
    }
  }

  // --- TAB 0: SITES CANVAS ---

  Widget _buildSitesCanvas(BuildContext context, bool isDark) {
    final rows = _sites.map((s) {
      final workerCount = _workers.where((w) => w.siteId == s.siteId).length;
      return [
        Text(s.siteName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(s.locationDetails ?? '-', style: GoogleFonts.poppins(fontSize: 12)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_alt_outlined, size: 14, color: Color(0xFF818CF8)),
            const SizedBox(width: 4),
            Text("$workerCount Workers", style: GoogleFonts.poppins(color: const Color(0xFF818CF8), fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        SiteStatusBadge(status: s.status),
      ];
    }).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B60F6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () => _openAddSiteDialog(context),
              icon: const Icon(Icons.add, color: Colors.white, size: 16),
              label: Text("Add Site", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LabourExcelGrid(
            columns: const ["SITE NAME", "LOCATION", "ASSIGNED WORKERS", "STATUS"],
            columnWidths: const [220, 200, 160, 120],
            rows: rows,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  // --- TAB 1: WORKERS CANVAS ---

  Widget _buildWorkersCanvas(BuildContext context, bool isDark) {
    final filtered = _workers.where((w) {
      final matchesSearch = w.name.toLowerCase().contains(_searchQuery.toLowerCase()) || (w.phone?.contains(_searchQuery) ?? false);
      final matchesSkill = _skillFilter == 'All' || w.role == _skillFilter;
      return matchesSearch && matchesSkill;
    }).toList();

    final rows = filtered.map((w) {
      return [
        Text(w.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
        SkillBadge(skill: w.role),
        Text(w.siteName ?? 'Unassigned', style: GoogleFonts.poppins(fontSize: 12), overflow: TextOverflow.ellipsis),
        Text("₹${w.monthlySalary.toStringAsFixed(0)}/day", style: GoogleFonts.poppins(color: const Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 12)),
        Text("₹${w.overtimePayPerHour.toStringAsFixed(0)}/hr", style: GoogleFonts.poppins(color: const Color(0xFF818CF8), fontWeight: FontWeight.bold, fontSize: 12)),
        Text(w.phone ?? '-', style: GoogleFonts.poppins(fontSize: 12)),
      ];
    }).toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Search worker by name or phone...",
                  prefixIcon: const Icon(Icons.search, size: 18),
                  fillColor: isDark ? const Color(0xFF161B22) : Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: isDark ? const Color(0xFF263040) : Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: isDark ? const Color(0xFF263040) : Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF5B60F6))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B60F6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () => _openAddWorkerDialog(context),
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 16),
              label: Text("Register Worker", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LabourExcelGrid(
            columns: const ["WORKER NAME", "SKILL / ROLE", "ASSIGNED SITE", "DAILY WAGE", "OT RATE", "PHONE"],
            columnWidths: const [180, 130, 200, 120, 110, 130],
            rows: rows,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  // --- TAB 2: CHECK-IN CANVAS ---

  Widget _buildCheckInCanvas(BuildContext context, bool isDark) {
    final rows = _attendanceList.map((item) {
      return [
        Text(item.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
        SkillBadge(skill: item.role),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusChip(item, 'Present', const Color(0xFF059669)),
              const SizedBox(width: 4),
              _buildStatusChip(item, 'Half Day', const Color(0xFF4338CA)),
              const SizedBox(width: 4),
              _buildStatusChip(item, 'Absent', const Color(0xFFDC2626)),
            ],
          ),
        ),
        Text("${item.overtimeHours.toStringAsFixed(1)} hrs", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
      ];
    }).toList();

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 220,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161B22) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isDark ? const Color(0xFF263040) : Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedSiteId,
                    isExpanded: true,
                    items: _sites.map((s) {
                      return DropdownMenuItem<int>(
                        value: s.siteId,
                        child: Text(s.siteName, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedSiteId = val);
                        _loadAttendance();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _attendanceDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => _attendanceDate = picked);
                  _loadAttendance();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161B22) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isDark ? const Color(0xFF263040) : Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 15, color: Color(0xFF5B60F6)),
                    const SizedBox(width: 6),
                    Text(DateFormat('MMM dd, yyyy').format(_attendanceDate), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B60F6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: _saveAttendance,
              icon: const Icon(Icons.check_circle, color: Colors.white, size: 16),
              label: Text("SAVE ATTENDANCE", style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LabourExcelGrid(
            columns: const ["WORKER NAME", "SKILL", "ATTENDANCE STATUS", "OVERTIME"],
            columnWidths: const [180, 130, 280, 110],
            rows: rows,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(LabourAttendanceItem item, String statusVal, Color color) {
    final isSelected = item.status == statusVal;
    return GestureDetector(
      onTap: () {
        setState(() {
          item.status = statusVal;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? color : Colors.grey[600]!),
        ),
        child: Text(
          statusVal,
          style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey[400]),
        ),
      ),
    );
  }

  Future<void> _saveAttendance() async {
    if (_selectedSiteId == null) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(_attendanceDate);
    final payload = _attendanceList.map((item) {
      return {
        'labour_id': item.labourId,
        'status': item.status,
        'overtime_hours': item.overtimeHours,
      };
    }).toList();

    final success = await _labourService.saveSiteAttendance(_selectedSiteId!, dateStr, payload);
    if (success && mounted) {
      context.showToast("Attendance checklist saved!", isSuccess: true);
    }
  }

  // --- TAB 3: PAYOUTS CANVAS ---

  Widget _buildPayoutsCanvas(BuildContext context, bool isDark) {
    final rows = _payouts.map((p) {
      return [
        Text(p.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(p.siteName, style: GoogleFonts.poppins(fontSize: 12)),
        Text("${p.daysPresent} Days", style: GoogleFonts.poppins(fontSize: 12)),
        Text("₹${p.dailyRate.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontSize: 12)),
        Text("₹${p.totalEarned.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
        Text("₹${p.totalAdvance.toStringAsFixed(0)}", style: GoogleFonts.poppins(color: const Color(0xFFF87171), fontWeight: FontWeight.w600, fontSize: 12)),
        Text("₹${p.netPayout.toStringAsFixed(0)}", style: GoogleFonts.poppins(color: const Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 12)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: p.status.toLowerCase() == 'paid' ? const Color(0xFF065F46) : const Color(0xFF92400E),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            p.status.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: p.status.toLowerCase() == 'paid' ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
            ),
          ),
        ),
      ];
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabourExcelGrid(
            columns: const ["WORKER NAME", "SITE", "DAYS WORKED", "DAILY RATE", "TOTAL EARNED", "ADVANCES TAKEN", "NET PAYOUT", "STATUS"],
            columnWidths: const [170, 160, 110, 100, 120, 130, 120, 100],
            rows: rows,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  void _openAddSiteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddSiteDialog(
        onSave: (name, location, status) async {
          final success = await _labourService.createSite(name, location);
          if (success && mounted) {
            if (!context.mounted) return;
            context.showToast("Site created successfully!", isSuccess: true);
            _loadData();
          }
        },
      ),
    );
  }

  void _openAddWorkerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddWorkerDialog(
        availableSites: _sites,
        onSave: (data) async {
          final success = await _labourService.createLabour(data);
          if (success && mounted) {
            if (!context.mounted) return;
            context.showToast("Worker registered successfully!", isSuccess: true);
            _loadData();
          }
        },
      ),
    );
  }
}
