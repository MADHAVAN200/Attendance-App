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

class LabourMobileContent extends StatefulWidget {
  const LabourMobileContent({super.key});

  @override
  State<LabourMobileContent> createState() => _LabourMobileContentState();
}

class _LabourMobileContentState extends State<LabourMobileContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LabourService _labourService;
  bool _isLoading = false;

  // Data
  List<LabourSite> _sites = [];
  List<LabourWorker> _workers = [];
  List<LabourAttendanceItem> _attendanceList = [];
  List<LabourPayoutSummary> _payouts = [];

  // Filter / Active Selection
  int? _selectedSiteId;
  DateTime _attendanceDate = DateTime.now();
  String _searchQuery = '';
  final String _selectedSkillFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

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
      if (mounted) context.showExceptionToast(e, fallback: "Failed to load labour data.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAttendance() async {
    if (_selectedSiteId == null) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(_attendanceDate);
    final list = await _labourService.getSiteAttendance(_selectedSiteId!, dateStr);
    if (mounted) {
      setState(() {
        _attendanceList = list;
      });
    }
  }

  Future<void> _loadPayouts() async {
    final monthStr = DateFormat('yyyy-MM').format(DateTime.now());
    final list = await _labourService.getFinancesSummary(monthStr, siteId: _selectedSiteId);
    if (mounted) {
      setState(() {
        _payouts = list;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LoadingScreen(
      isLoading: _isLoading,
      message: "Loading Labour Portal...",
      child: Column(
        children: [
          // Full-Width Left-to-Right Navigation Tab Bar
          Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              border: Border(
                bottom: BorderSide(color: isDark ? const Color(0xFF30363D) : Colors.grey[200]!, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Color(0xFF5B60F6), width: 3),
              ),
              labelColor: const Color(0xFF5B60F6),
              unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "Sites"),
                Tab(text: "Workers"),
                Tab(text: "Check-In"),
                Tab(text: "Payouts"),
              ],
            ),
          ),

          // Tab Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSitesTab(context, isDark),
                _buildWorkersTab(context, isDark),
                _buildCheckInTab(context, isDark),
                _buildPayoutsTab(context, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: SITES ---

  Widget _buildSitesTab(BuildContext context, bool isDark) {
    final rows = _sites.map((s) {
      final workerCount = _workers.where((w) => w.siteId == s.siteId).length;
      return [
        Text(s.siteName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(s.locationDetails ?? '-', style: GoogleFonts.poppins(fontSize: 12)),
        Text("$workerCount Workers", style: GoogleFonts.poppins(color: const Color(0xFF5B60F6), fontWeight: FontWeight.bold, fontSize: 12)),
        SiteStatusBadge(status: s.status),
      ];
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B60F6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () => _openAddSiteDialog(context),
                icon: const Icon(Icons.add, color: Colors.white, size: 16),
                label: Text("Add Site", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LabourExcelGrid(
              columns: const ["SITE NAME", "LOCATION", "WORKERS", "STATUS"],
              columnWidths: const [180, 160, 120, 100],
              rows: rows,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: WORKERS DIRECTORY ---

  Widget _buildWorkersTab(BuildContext context, bool isDark) {
    final filteredWorkers = _workers.where((w) {
      final matchesSearch = w.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (w.phone?.contains(_searchQuery) ?? false);
      final matchesSkill = _selectedSkillFilter == 'All' || w.role == _selectedSkillFilter;
      return matchesSearch && matchesSkill;
    }).toList();

    final rows = filteredWorkers.map((w) {
      return [
        Text(w.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
        SkillBadge(skill: w.role),
        Text(w.siteName ?? 'Unassigned', style: GoogleFonts.poppins(fontSize: 12), overflow: TextOverflow.ellipsis),
        Text("₹${w.monthlySalary.toStringAsFixed(0)}/day", style: GoogleFonts.poppins(color: const Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 12)),
        Text("₹${w.overtimePayPerHour.toStringAsFixed(0)}/hr", style: GoogleFonts.poppins(color: const Color(0xFF818CF8), fontWeight: FontWeight.bold, fontSize: 12)),
        Text(w.phone ?? '-', style: GoogleFonts.poppins(fontSize: 12)),
      ];
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: GoogleFonts.poppins(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: "Search name or phone...",
                    prefixIcon: const Icon(Icons.search, size: 16),
                    fillColor: isDark ? const Color(0xFF161B22) : Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: isDark ? const Color(0xFF263040) : Colors.grey[300]!)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: isDark ? const Color(0xFF263040) : Colors.grey[300]!)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF5B60F6))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B60F6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () => _openAddWorkerDialog(context),
                icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 16),
                label: Text("Add", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LabourExcelGrid(
              columns: const ["WORKER NAME", "SKILL", "SITE", "DAILY WAGE", "OT RATE", "PHONE"],
              columnWidths: const [160, 120, 160, 110, 100, 120],
              rows: rows,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: SITE CHECK-IN ---

  Widget _buildCheckInTab(BuildContext context, bool isDark) {
    final rows = _attendanceList.map((item) {
      return [
        Text(item.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
        SkillBadge(skill: item.role),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusRadio(item, 'Present', const Color(0xFF059669)),
              const SizedBox(width: 4),
              _buildStatusRadio(item, 'Half Day', const Color(0xFF4338CA)),
              const SizedBox(width: 4),
              _buildStatusRadio(item, 'Absent', const Color(0xFFDC2626)),
            ],
          ),
        ),
        Text("${item.overtimeHours.toStringAsFixed(1)} hrs", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
      ];
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          child: Text(s.siteName, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
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
              const SizedBox(width: 8),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: isDark ? const Color(0xFF263040) : Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Color(0xFF5B60F6)),
                      const SizedBox(width: 4),
                      Text(DateFormat('MMM dd').format(_attendanceDate), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B60F6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: _saveAttendance,
                icon: const Icon(Icons.check_circle, color: Colors.white, size: 16),
                label: Text("Save", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LabourExcelGrid(
              columns: const ["WORKER NAME", "ROLE", "ATTENDANCE STATUS", "OVERTIME"],
              columnWidths: const [150, 110, 280, 100],
              rows: rows,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 4: PAYOUTS & ADVANCES ---

  Widget _buildPayoutsTab(BuildContext context, bool isDark) {
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
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: p.status.toLowerCase() == 'paid' ? const Color(0xFF065F46) : const Color(0xFF92400E),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            p.status.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: p.status.toLowerCase() == 'paid' ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
            ),
          ),
        ),
      ];
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: LabourExcelGrid(
              columns: const ["WORKER NAME", "SITE", "DAYS WORKED", "DAILY RATE", "TOTAL EARNED", "ADVANCES TAKEN", "NET PAYOUT", "STATUS"],
              columnWidths: const [150, 150, 100, 90, 110, 120, 110, 90],
              rows: rows,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRadio(LabourAttendanceItem item, String statusVal, Color color) {
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
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[400],
          ),
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
      context.showToast("Site attendance saved successfully!", isSuccess: true);
    }
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
