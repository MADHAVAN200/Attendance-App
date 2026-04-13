import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application/shared/widgets/loading_screen.dart';
import 'package:flutter_application/shared/services/auth_service.dart';
import 'package:flutter_application/shared/widgets/toast_helper.dart';
import 'package:flutter_application/features/labour/core/labour_models.dart';
import 'package:flutter_application/features/labour/core/labour_service.dart';
import 'package:flutter_application/features/labour/widgets/labour_common_widgets.dart';
import 'package:flutter_application/features/labour/widgets/add_site_dialog.dart';
import 'package:flutter_application/features/labour/widgets/add_worker_dialog.dart';
import 'package:flutter_application/features/labour/widgets/bulk_transfer_dialog.dart';
import 'package:flutter_application/features/labour/widgets/borrow_worker_dialog.dart';
import 'package:flutter_application/features/labour/widgets/log_advance_dialog.dart';
import 'package:flutter_application/features/labour/widgets/settle_payout_dialog.dart';
import 'package:flutter_application/features/labour/widgets/labour_history_dialog.dart';
import 'package:flutter_application/features/labour/widgets/daily_schedule_dialog.dart';
import 'package:flutter_application/features/labour/widgets/bulk_upload_dialog.dart';
import 'package:flutter_application/features/labour/widgets/confirm_dialog.dart';
import 'package:flutter_application/features/labour/core/labour_excel_export.dart';

class LabourMobileContent extends StatefulWidget {
  const LabourMobileContent({super.key});

  @override
  State<LabourMobileContent> createState() => _LabourMobileContentState();
}

/// Mobile Portrait Mode View
typedef LabourMobilePortraitView = LabourMobileContent;
typedef LabourMobilePortraitContent = LabourMobileContent;

class _LabourMobileContentState extends State<LabourMobileContent> with SingleTickerProviderStateMixin {
  late LabourService _labourService;
  bool _isLoading = true;
  bool _isSavingAttendance = false;

  // Active Main Tab: 'sites' (Sites Overview / Drill-down) or 'directory' (Worker Directory)
  String _activeTab = 'sites';

  // Selected site for drill-down (null = Site Directory view, non-null = Site Dashboard)
  LabourSite? _selectedSite;

  // Subtab inside Site Dashboard: 'attendance', 'grid', 'finances'
  String _subTab = 'attendance';

  // Data from Backend
  List<LabourSite> _sites = [];
  List<LabourWorker> _workers = [];
  List<LabourAttendanceItem> _attendanceRoster = [];
  List<LabourMonthlyRow> _gridData = [];
  List<LabourPayoutSummary> _financeSummary = [];

  // Filters & State
  String _siteSearch = '';
  String _siteStatusFilter = 'All'; // All, Active, Completed, On Hold

  DateTime _attendanceDate = DateTime.now();
  String _attendanceSearch = '';
  String _attendanceRoleFilter = 'All';
  bool _attendanceLoading = false;

  DateTime _gridMonth = DateTime.now();
  String _gridRoleFilter = 'All';
  bool _gridLoading = false;

  String _financeRoleFilter = 'All';
  bool _financeLoading = false;

  String _directorySearch = '';
  dynamic _directorySiteFilter = 'All'; // 'All', 'Unassigned', or int site_id
  String _directoryRoleFilter = 'All';

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _labourService = LabourService(authService.dio);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final sites = await _labourService.getAllSites();
      final workers = await _labourService.getAllLabours();

      if (mounted) {
        setState(() {
          _sites = sites;
          _workers = workers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showExceptionToast(e, fallback: "Failed to load labour data.");
      }
    }
  }

  Future<void> _loadAttendanceRoster() async {
    if (_selectedSite == null) return;
    setState(() => _attendanceLoading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_attendanceDate);

    try {
      final roster = await _labourService.getSiteAttendance(_selectedSite!.siteId, dateStr);
      if (mounted) {
        setState(() {
          _attendanceRoster = roster;
          _attendanceLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _attendanceLoading = false);
        context.showExceptionToast(e, fallback: "Failed to fetch site attendance roster.");
      }
    }
  }

  Future<void> _loadMonthlyGrid() async {
    if (_selectedSite == null) return;
    setState(() => _gridLoading = true);
    final monthStr = DateFormat('yyyy-MM').format(_gridMonth);

    try {
      final res = await _labourService.getMonthlyGridAttendance(
        siteId: _selectedSite!.siteId,
        monthStr: monthStr,
      );
      if (mounted) {
        setState(() {
          _gridData = res.grid;
          _gridLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _gridLoading = false);
        context.showExceptionToast(e, fallback: "Failed to load monthly attendance grid.");
      }
    }
  }

  Future<void> _loadFinances() async {
    if (_selectedSite == null) return;
    setState(() => _financeLoading = true);
    final monthStr = DateFormat('yyyy-MM').format(_attendanceDate);

    try {
      final res = await _labourService.getFinancesSummary(
        siteId: _selectedSite!.siteId,
        monthStr: monthStr,
      );
      if (mounted) {
        setState(() {
          _financeSummary = res.summary;
          _financeLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _financeLoading = false);
        context.showExceptionToast(e, fallback: "Failed to load financial breakdown.");
      }
    }
  }

  void _onSelectSite(LabourSite site) {
    setState(() {
      _selectedSite = site;
      _subTab = 'attendance';
    });
    _loadAttendanceRoster();
  }

  void _onBackToSites() {
    setState(() {
      _selectedSite = null;
    });
  }

  Future<void> _saveAttendance() async {
    if (_selectedSite == null) return;
    setState(() => _isSavingAttendance = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_attendanceDate);

    final payload = _attendanceRoster.map((item) => item.toJson()).toList();

    try {
      await _labourService.saveSiteAttendance(_selectedSite!.siteId, dateStr, payload);
      if (mounted) {
        context.showToast("Attendance saved successfully!", isSuccess: true);
        await _loadAttendanceRoster();
      }
    } catch (e) {
      if (mounted) {
        context.showExceptionToast(e, fallback: "Failed to save attendance roster.");
      }
    } finally {
      if (mounted) setState(() => _isSavingAttendance = false);
    }
  }

  void _markAllPresent() {
    setState(() {
      for (final item in _attendanceRoster) {
        item.status = 'Present';
      }
    });
    context.showToast("Marked all workers present. Click 'Save' to commit.", isSuccess: true);
  }

  // ===========================================================================
  // BUILD METHOD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LoadingScreen(
      isLoading: _isLoading,
      message: "Loading Labour Management Portal...",
      child: Container(
        color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
        child: Column(
          children: [
            // Top Primary Navigation Bar
            _buildPrimaryTabBar(isDark),

            // Main Body Content
            Expanded(
              child: _activeTab == 'sites'
                  ? (_selectedSite == null ? _buildSitesOverview(isDark) : _buildSiteDashboard(isDark))
                  : _buildLabourDirectory(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PRIMARY TAB BAR
  // ---------------------------------------------------------------------------
  Widget _buildPrimaryTabBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _activeTab = 'sites';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _activeTab == 'sites'
                      ? const Color(0xFF6366F1)
                      : (isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business_rounded,
                      size: 16,
                      color: _activeTab == 'sites' ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Sites Overview (${_sites.length})",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _activeTab == 'sites' ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _activeTab = 'directory';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _activeTab == 'directory'
                      ? const Color(0xFF6366F1)
                      : (isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      size: 16,
                      color: _activeTab == 'directory' ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Labour Directory (${_workers.length})",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _activeTab == 'directory' ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                      ),
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

  // ---------------------------------------------------------------------------
  // SITES OVERVIEW (NO SITE SELECTED)
  // ---------------------------------------------------------------------------
  Widget _buildSitesOverview(bool isDark) {
    final activeCount = _sites.where((s) => s.status == 'Active').length;
    final completedCount = _sites.where((s) => s.status == 'Completed').length;
    final totalWorkers = _workers.length;

    final filteredSites = _sites.where((s) {
      if (_siteStatusFilter != 'All' && s.status != _siteStatusFilter) {
        return false;
      }
      if (_siteSearch.isNotEmpty) {
        final q = _siteSearch.toLowerCase();
        final matchName = s.siteName.toLowerCase().contains(q);
        final matchLoc = s.locationDetails?.toLowerCase().contains(q) ?? false;
        if (!matchName && !matchLoc) return false;
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // KPI Stat Cards Grid (2x2)
          Row(
            children: [
              Expanded(
                child: LabourStatCard(
                  title: "Active Sites",
                  value: "$activeCount",
                  icon: Icons.construction_rounded,
                  iconColor: const Color(0xFF10B981),
                  subtitle: "Ongoing operations",
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LabourStatCard(
                  title: "Completed",
                  value: "$completedCount",
                  icon: Icons.check_circle_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  subtitle: "Past projects",
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LabourStatCard(
                  title: "Registered Labours",
                  value: "$totalWorkers",
                  icon: Icons.groups_rounded,
                  iconColor: const Color(0xFF6366F1),
                  subtitle: "Active workforce",
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LabourStatCard(
                  title: "Total Sites",
                  value: "${_sites.length}",
                  icon: Icons.apartment_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  subtitle: "All contract sites",
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Actions and Search Bar
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    onChanged: (val) => setState(() => _siteSearch = val.trim()),
                    style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Search site name or location...",
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
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _openAddSiteDialog,
                icon: const Icon(Icons.add, color: Colors.white, size: 16),
                label: Text("Add Site", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Active', 'Completed', 'On Hold'].map((st) {
                final isSelected = _siteStatusFilter == st;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(st),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _siteStatusFilter = st),
                    selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFF6366F1),
                    backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF6366F1) : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    ),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Sites Card List
          Expanded(
            child: filteredSites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_city_outlined, size: 40, color: Colors.grey[500]),
                        const SizedBox(height: 8),
                        Text("No construction sites found", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredSites.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      final site = filteredSites[i];
                      final assignedWorkers = _workers.where((w) => w.siteId == site.siteId || w.siteIds.contains(site.siteId)).length;

                      return LabourSiteCard(
                        site: site,
                        assignedWorkers: assignedWorkers,
                        onSelect: () => _onSelectSite(site),
                        onEdit: () => _openEditSiteDialog(site),
                        onDelete: () => _confirmDeleteSite(site),
                        isDark: isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SITE DRILL-DOWN DASHBOARD (WITH 3 SUB-TABS)
  // ---------------------------------------------------------------------------
  Widget _buildSiteDashboard(bool isDark) {
    final site = _selectedSite!;

    return Column(
      children: [
        // Breadcrumb Header Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: _onBackToSites,
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, size: 16, color: Color(0xFF6366F1)),
                    const SizedBox(width: 4),
                    Text(
                      "Sites",
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF6366F1)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text("/", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  site.siteName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SiteStatusBadge(status: site.status),
            ],
          ),
        ),

        // Sub-Tab Switcher Bar (Attendance, Monthly Grid, Finances)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
          ),
          child: Row(
            children: [
              _buildSubTabChip('attendance', Icons.fact_check_rounded, "Daily Attendance", isDark),
              const SizedBox(width: 6),
              _buildSubTabChip('grid', Icons.grid_on_rounded, "Monthly Grid", isDark),
              const SizedBox(width: 6),
              _buildSubTabChip('finances', Icons.account_balance_wallet_rounded, "Finances", isDark),
            ],
          ),
        ),

        // Sub-Tab Content View
        Expanded(
          child: _subTab == 'attendance'
              ? _buildAttendanceSubTab(isDark)
              : (_subTab == 'grid' ? _buildMonthlyGridSubTab(isDark) : _buildFinancesSubTab(isDark)),
        ),
      ],
    );
  }

  Widget _buildSubTabChip(String id, IconData icon, String label, bool isDark) {
    final isSelected = _subTab == id;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _subTab = id);
          if (id == 'attendance' && _attendanceRoster.isEmpty) {
            _loadAttendanceRoster();
          } else if (id == 'grid' && _gridData.isEmpty) {
            _loadMonthlyGrid();
          } else if (id == 'finances' && _financeSummary.isEmpty) {
            _loadFinances();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF161B22) : Colors.white),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700])),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUB-TAB 1: DAILY ATTENDANCE
  // ---------------------------------------------------------------------------
  Widget _buildAttendanceSubTab(bool isDark) {
    final roles = ['All', ...{..._attendanceRoster.map((r) => r.role)}];

    final filteredRoster = _attendanceRoster.where((r) {
      if (_attendanceRoleFilter != 'All' && r.role != _attendanceRoleFilter) {
        return false;
      }
      if (_attendanceSearch.isNotEmpty) {
        final q = _attendanceSearch.toLowerCase();
        if (!r.name.toLowerCase().contains(q) && !r.role.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    final presentCount = _attendanceRoster.where((r) => r.status == 'Present').length;
    final halfCount = _attendanceRoster.where((r) => r.status == 'Half Day').length;
    final absentCount = _attendanceRoster.where((r) => r.status == 'Absent').length;
    final plCount = _attendanceRoster.where((r) => r.status == 'Paid Leave').length;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Date Navigator & Actions Row
          Row(
            children: [
              // Prev Day
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: () {
                  setState(() {
                    _attendanceDate = _attendanceDate.subtract(const Duration(days: 1));
                  });
                  _loadAttendanceRoster();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              // Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showLabourDatePicker(
                    context,
                    initialDate: _attendanceDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 7)),
                  );
                  if (picked != null) {
                    setState(() => _attendanceDate = picked);
                    _loadAttendanceRoster();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Color(0xFF6366F1)),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMM yyyy').format(_attendanceDate),
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Next Day
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: () {
                  setState(() {
                    _attendanceDate = _attendanceDate.add(const Duration(days: 1));
                  });
                  _loadAttendanceRoster();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              // Borrow Worker
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: const BorderSide(color: Color(0xFF10B981)),
                  minimumSize: Size.zero,
                ),
                onPressed: _openBorrowWorkerDialog,
                icon: const Icon(Icons.person_add, color: Color(0xFF10B981), size: 14),
                label: Text("Borrow", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
              ),
              const SizedBox(width: 6),
              // Mark All Present
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  minimumSize: Size.zero,
                ),
                onPressed: _markAllPresent,
                child: Text("All P", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Search and Role Filter Row
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    onChanged: (val) => setState(() => _attendanceSearch = val.trim()),
                    style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Search workers...",
                      hintStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                      prefixIcon: const Icon(Icons.search, size: 16),
                      fillColor: isDark ? const Color(0xFF161B22) : Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              CustomDropdown<String>(
                value: _attendanceRoleFilter,
                height: 36,
                fontSize: 11,
                items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r == 'All' ? 'All Roles' : r))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _attendanceRoleFilter = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Attendance Summary Count Chips
          Row(
            children: [
              _buildCountChip("P: $presentCount", const Color(0xFF10B981)),
              const SizedBox(width: 4),
              _buildCountChip("HD: $halfCount", const Color(0xFFF59E0B)),
              const SizedBox(width: 4),
              _buildCountChip("A: $absentCount", const Color(0xFFEF4444)),
              const SizedBox(width: 4),
              _buildCountChip("PL: $plCount", const Color(0xFF3B82F6)),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: Size.zero,
                ),
                onPressed: _isSavingAttendance ? null : _saveAttendance,
                icon: _isSavingAttendance
                    ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded, color: Colors.white, size: 14),
                label: Text("Save", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Worker Roster List
          Expanded(
            child: _attendanceLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : filteredRoster.isEmpty
                    ? Center(child: Text("No workers on roster for this date", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])))
                    : ListView.builder(
                        itemCount: filteredRoster.length,
                        itemBuilder: (context, i) {
                          final item = filteredRoster[i];
                          return _buildAttendanceRosterCard(item, isDark);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildAttendanceRosterCard(LabourAttendanceItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.status.isNotEmpty
              ? const Color(0xFF6366F1).withValues(alpha: 0.3)
              : (isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Worker Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        if (item.isBorrowed) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text("Borrowed", style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                          ),
                        ],
                        if (item.isScheduledMultiSite) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text("Multi-Site", style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF8B5CF6))),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "OT Rate: ₹${item.overtimePayPerHour.toStringAsFixed(0)}/hr",
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              SkillBadge(skill: item.role),
            ],
          ),
          if (item.alreadyMarkedAt != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Marked ${item.alreadyMarkedAt!['status']} at ${item.alreadyMarkedAt!['site_name']}",
                style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFFF59E0B)),
              ),
            ),
          ],
          const SizedBox(height: 8),

          // 4-Way Segmented Status Buttons (Present, Half Day, Absent, Paid Leave)
          Row(
            children: [
              _buildAttendanceButton(item, 'Present', 'P', const Color(0xFF10B981)),
              const SizedBox(width: 4),
              _buildAttendanceButton(item, 'Half Day', 'HD', const Color(0xFFF59E0B)),
              const SizedBox(width: 4),
              _buildAttendanceButton(item, 'Absent', 'A', const Color(0xFFEF4444)),
              const SizedBox(width: 4),
              _buildAttendanceButton(item, 'Paid Leave', 'PL', const Color(0xFF3B82F6)),
            ],
          ),
          const SizedBox(height: 8),

          // Overtime Stepper
          Row(
            children: [
              Text(
                "Overtime (Hours):",
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 18),
                onPressed: () {
                  if (item.overtimeHours > 0) {
                    setState(() {
                      item.overtimeHours = (item.overtimeHours - 0.5).clamp(0.0, 24.0);
                    });
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${item.overtimeHours.toStringAsFixed(1)}h",
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1)),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 18),
                onPressed: () {
                  setState(() {
                    item.overtimeHours = (item.overtimeHours + 0.5).clamp(0.0, 24.0);
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButton(LabourAttendanceItem item, String status, String shortLabel, Color color) {
    final isSelected = item.status == status;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            item.status = isSelected ? '' : status;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              shortLabel,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUB-TAB 2: MONTHLY GRID
  // ---------------------------------------------------------------------------
  Widget _buildMonthlyGridSubTab(bool isDark) {
    final daysInMonth = DateTime(_gridMonth.year, _gridMonth.month + 1, 0).day;
    final roles = ['All', ...{..._gridData.map((r) => r.role)}];

    final filteredGrid = _gridData.where((r) {
      if (_gridRoleFilter != 'All' && r.role != _gridRoleFilter) return false;
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Month Selector & Export Button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: () {
                  setState(() {
                    _gridMonth = DateTime(_gridMonth.year, _gridMonth.month - 1);
                  });
                  _loadMonthlyGrid();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () async {
                  final picked = await showLabourDatePicker(
                    context,
                    initialDate: _gridMonth,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _gridMonth = DateTime(picked.year, picked.month));
                    _loadMonthlyGrid();
                  }
                },
                child: Text(
                  DateFormat('MMMM yyyy').format(_gridMonth),
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: () {
                  setState(() {
                    _gridMonth = DateTime(_gridMonth.year, _gridMonth.month + 1);
                  });
                  _loadMonthlyGrid();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 6),
              CustomDropdown<String>(
                value: _gridRoleFilter,
                height: 32,
                fontSize: 10,
                items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r == 'All' ? 'All Roles' : r))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _gridRoleFilter = val);
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: Size.zero,
                ),
                onPressed: _exportMonthlyGridToExcel,
                icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 14),
                label: Text("Export Excel", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Legend Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLegendItem("P", "Present", const Color(0xFF10B981)),
                const SizedBox(width: 8),
                _buildLegendItem("HD", "Half Day", const Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                _buildLegendItem("A", "Absent", const Color(0xFFEF4444)),
                const SizedBox(width: 8),
                _buildLegendItem("PL", "Paid Leave", const Color(0xFF3B82F6)),
                const SizedBox(width: 8),
                _buildLegendItem("WO", "Week Off", Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Monthly Matrix Table
          Expanded(
            child: _gridLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : filteredGrid.isEmpty
                    ? Center(child: Text("No monthly grid data available", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])))
                    : Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF161B22) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowHeight: 36,
                              dataRowMinHeight: 36,
                              dataRowMaxHeight: 40,
                              columnSpacing: 12,
                              horizontalMargin: 10,
                              columns: [
                                const DataColumn(label: Text("Worker")),
                                const DataColumn(label: Text("Role")),
                                ...List.generate(
                                  daysInMonth,
                                  (d) => DataColumn(
                                    label: Text(
                                      "${d + 1}",
                                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const DataColumn(label: Text("P")),
                                const DataColumn(label: Text("HD")),
                                const DataColumn(label: Text("A")),
                                const DataColumn(label: Text("PL")),
                                const DataColumn(label: Text("OT")),
                              ],
                              rows: filteredGrid.map((row) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(row.name, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold))),
                                    DataCell(SkillBadge(skill: row.role)),
                                    ...List.generate(daysInMonth, (d) {
                                      final dayStr = "${d + 1}";
                                      final st = row.days[dayStr] ?? '';
                                      return DataCell(
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: _getGridCellBg(st),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Center(
                                            child: Text(
                                              st,
                                              style: GoogleFonts.poppins(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: _getGridCellFg(st),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                    DataCell(Text("${row.totalPresent}", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)))),
                                    DataCell(Text("${row.totalHalfDays}", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)))),
                                    DataCell(Text("${row.totalAbsent}", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)))),
                                    DataCell(Text("${row.totalPaidLeaves}", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6)))),
                                    DataCell(Text("${row.totalOvertimeHours.toStringAsFixed(1)}h", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF8B5CF6)))),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String code, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Text(code, style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }

  Color _getGridCellBg(String status) {
    switch (status.toUpperCase().trim()) {
      case 'P':
      case 'PRESENT':
        return const Color(0xFF10B981).withValues(alpha: 0.2);
      case 'HD':
      case 'HALF DAY':
      case 'H':
        return const Color(0xFFF59E0B).withValues(alpha: 0.2);
      case 'A':
      case 'ABSENT':
        return const Color(0xFFEF4444).withValues(alpha: 0.2);
      case 'PL':
      case 'PAID LEAVE':
        return const Color(0xFF3B82F6).withValues(alpha: 0.2);
      case 'WO':
      case 'WEEK OFF':
        return Colors.grey.withValues(alpha: 0.15);
      default:
        return Colors.transparent;
    }
  }

  Color _getGridCellFg(String status) {
    switch (status.toUpperCase().trim()) {
      case 'P':
      case 'PRESENT':
        return const Color(0xFF10B981);
      case 'HD':
      case 'HALF DAY':
      case 'H':
        return const Color(0xFFF59E0B);
      case 'A':
      case 'ABSENT':
        return const Color(0xFFEF4444);
      case 'PL':
      case 'PAID LEAVE':
        return const Color(0xFF3B82F6);
      case 'WO':
      case 'WEEK OFF':
        return Colors.grey;
      default:
        return Colors.grey[400]!;
    }
  }

  Future<void> _exportMonthlyGridToExcel() async {
    if (_gridData.isEmpty) {
      context.showToast("No grid data available to export", isSuccess: false);
      return;
    }
    try {
      await LabourExcelExportHelper.exportMonthlyGridToExcel(
        grid: _gridData,
        siteName: _selectedSite?.siteName ?? 'Site',
        month: _gridMonth,
      );
      if (mounted) context.showToast("Monthly attendance exported to Excel!", isSuccess: true);
    } catch (e) {
      if (mounted) context.showExceptionToast(e, fallback: "Failed to export Excel file.");
    }
  }

  // ---------------------------------------------------------------------------
  // SUB-TAB 3: FINANCES & SALARY CREDIT
  // ---------------------------------------------------------------------------
  Widget _buildFinancesSubTab(bool isDark) {
    final filteredFinances = _financeSummary.where((s) {
      if (_financeRoleFilter != 'All' && s.role != _financeRoleFilter) return false;
      return true;
    }).toList();

    double totalAccrued = 0;
    double totalAdvances = 0;
    double totalNet = 0;
    double totalPaid = 0;

    for (final f in filteredFinances) {
      totalAccrued += f.accruedCredit;
      totalAdvances += f.totalAdvance;
      totalNet += f.netPayable;
      totalPaid += f.paidAmount;
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 4 Financial Summary KPI Cards
          Row(
            children: [
              Expanded(
                child: LabourStatCard(
                  title: "Total Accrued",
                  value: "₹${totalAccrued.toStringAsFixed(0)}",
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFF6366F1),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LabourStatCard(
                  title: "Advances Paid",
                  value: "₹${totalAdvances.toStringAsFixed(0)}",
                  icon: Icons.price_change_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LabourStatCard(
                  title: "Net Payable",
                  value: "₹${totalNet.toStringAsFixed(0)}",
                  icon: Icons.pending_actions_rounded,
                  iconColor: const Color(0xFF10B981),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LabourStatCard(
                  title: "Total Paid",
                  value: "₹${totalPaid.toStringAsFixed(0)}",
                  icon: Icons.check_circle_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Export Payroll Button & Role Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomDropdown<String>(
                value: _financeRoleFilter,
                height: 32,
                fontSize: 10,
                items: ['All', ...{..._financeSummary.map((f) => f.role)}].map((r) => DropdownMenuItem(value: r, child: Text(r == 'All' ? 'All Roles' : r))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _financeRoleFilter = val);
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: Size.zero,
                ),
                onPressed: _exportPayoutsToExcel,
                icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 14),
                label: Text("Export Payroll", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Finance Worker Cards
          Expanded(
            child: _financeLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : filteredFinances.isEmpty
                    ? Center(child: Text("No financial ledger entries for this site", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])))
                    : ListView.builder(
                        itemCount: filteredFinances.length,
                        itemBuilder: (context, i) {
                          final f = filteredFinances[i];
                          return _buildFinanceCard(f, isDark);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(LabourPayoutSummary f, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.name,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                    Text(
                      "Rate: ₹${f.dailyRate.toStringAsFixed(0)}/day • ${f.daysPresent}P + ${f.halfDays}HD • OT: ${f.overtimeHours.toStringAsFixed(1)}h",
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              SkillBadge(skill: f.role),
            ],
          ),
          const SizedBox(height: 8),

          // Numbers Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFinanceMetric("Credit", "₹${f.accruedCredit.toStringAsFixed(0)}", const Color(0xFF6366F1)),
              _buildFinanceMetric("Advance", "-₹${f.totalAdvance.toStringAsFixed(0)}", const Color(0xFFEF4444)),
              _buildFinanceMetric("Net Payable", "₹${f.netPayable.toStringAsFixed(0)}", const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 10),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: const BorderSide(color: Color(0xFFF59E0B)),
                  minimumSize: Size.zero,
                ),
                onPressed: () => _openLogAdvanceDialog(f),
                child: Text("+ Advance", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: Size.zero,
                ),
                onPressed: () => _openSettlePayoutDialog(f),
                child: Text("Settle Payout", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.grey[500])),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Future<void> _exportPayoutsToExcel() async {
    if (_financeSummary.isEmpty) {
      context.showToast("No payouts data available to export", isSuccess: false);
      return;
    }
    try {
      final siteName = _selectedSite?.siteName ?? 'Site';
      final monthStr = DateFormat('yyyy_MM').format(_attendanceDate);
      await LabourExcelExportHelper.exportPayoutsToExcel(
        payouts: _financeSummary,
        siteName: siteName,
        monthStr: monthStr,
      );
      if (mounted) context.showToast("Payout ledger exported to Excel!", isSuccess: true);
    } catch (e) {
      if (mounted) context.showExceptionToast(e, fallback: "Failed to export Excel file.");
    }
  }

  // ---------------------------------------------------------------------------
  // SUB-TAB 4: LABOUR DIRECTORY (MOBILE VIEW)
  // ---------------------------------------------------------------------------
  Widget _buildLabourDirectory(bool isDark) {
    final roles = ['All', ...{..._workers.map((w) => w.role)}];

    final filteredWorkers = _workers.where((w) {
      if (_directoryRoleFilter != 'All' && w.role != _directoryRoleFilter) return false;
      if (_directorySiteFilter == 'Unassigned' && (w.siteId != null || w.siteIds.isNotEmpty)) return false;
      if (_directorySiteFilter != 'All' && _directorySiteFilter != 'Unassigned') {
        final sId = _directorySiteFilter is int ? _directorySiteFilter as int : int.tryParse(_directorySiteFilter.toString());
        if (sId != null && w.siteId != sId && !w.siteIds.contains(sId)) return false;
      }
      if (_directorySearch.isNotEmpty) {
        final q = _directorySearch.toLowerCase();
        final matchName = w.name.toLowerCase().contains(q);
        final matchPhone = w.phone?.toLowerCase().contains(q) ?? false;
        final matchRole = w.role.toLowerCase().contains(q);
        if (!matchName && !matchPhone && !matchRole) return false;
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Action Buttons Bar
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: _openAddWorkerDialog,
                  icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 14),
                  label: Text("+ Add Worker", style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                  ),
                  onPressed: () => _openBulkTransferDialog(),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 14, color: Color(0xFF6366F1)),
                  label: Text("Transfer", style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
                  side: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.upload_file_rounded, size: 16, color: Color(0xFF6366F1)),
                onPressed: _openBulkUploadDialog,
                tooltip: "Bulk Upload Excel",
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Search Bar
          SizedBox(
            height: 36,
            child: TextField(
              onChanged: (val) => setState(() => _directorySearch = val.trim()),
              style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: "Search name, phone or role...",
                hintStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, size: 14),
                fillColor: isDark ? const Color(0xFF161B22) : Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Filters Row
          Row(
            children: [
              Expanded(
                child: CustomDropdown<dynamic>(
                  value: _directorySiteFilter,
                  height: 34,
                  fontSize: 10.5,
                  items: [
                    const DropdownMenuItem(value: 'All', child: Text("All Sites", maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const DropdownMenuItem(value: 'Unassigned', child: Text("Unassigned", maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ..._sites.map((s) => DropdownMenuItem(value: s.siteId, child: Text(s.siteName, maxLines: 1, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (val) => setState(() => _directorySiteFilter = val),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: CustomDropdown<String>(
                  value: _directoryRoleFilter,
                  height: 34,
                  fontSize: 10.5,
                  items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r == 'All' ? 'All Roles' : r))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _directoryRoleFilter = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Worker Directory Card List
          Expanded(
            child: filteredWorkers.isEmpty
                ? Center(child: Text("No workers match directory filters", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])))
                : ListView.builder(
                    itemCount: filteredWorkers.length,
                    itemBuilder: (context, i) {
                      final w = filteredWorkers[i];
                      return _buildWorkerDirectoryCard(w, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerDirectoryCard(LabourWorker w, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _openLabourHistoryDialog(w),
                      child: Text(
                        w.name,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6366F1),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(
                      "Phone: ${w.phone ?? 'N/A'} • Site: ${w.siteName}",
                      style: GoogleFonts.poppins(fontSize: 10, color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              SkillBadge(skill: w.role),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Wage: ₹${w.monthlySalary.toStringAsFixed(0)}/day | OT: ₹${w.overtimePayPerHour.toStringAsFixed(0)}/h",
                style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF10B981)),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.calendar_month_outlined, size: 17, color: Color(0xFF6366F1)),
                    onPressed: () => _openDailyScheduleDialog(w),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "Daily Schedule",
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 17, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    onPressed: () => _openEditWorkerDialog(w),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 17, color: Color(0xFFEF4444)),
                    onPressed: () => _confirmDeleteWorker(w),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MODAL DIALOG LAUNCHERS (BOTTOM SHEET IN MOBILE)
  // ===========================================================================

  Future<T?> _showMobilePopup<T>(Widget Function(BuildContext) builder) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      useSafeArea: true,
      builder: (ctx) => builder(ctx),
    );
  }

  void _openAddSiteDialog() {
    _showMobilePopup(
      (ctx) => AddSiteDialog(
        isBottomSheet: true,
        onSave: (name, loc, status, endDate) async {
          try {
            await _labourService.createSite(
              siteName: name,
              locationDetails: loc,
              status: status,
              endDate: endDate,
            );
            if (mounted) {
              context.showToast("Site created successfully!", isSuccess: true);
              _loadInitialData();
            }
          } catch (e) {
            if (mounted) context.showExceptionToast(e, fallback: "Failed to create site.");
          }
        },
      ),
    );
  }

  void _openEditSiteDialog(LabourSite site) {
    _showMobilePopup(
      (ctx) => AddSiteDialog(
        initialSite: site,
        isBottomSheet: true,
        onSave: (name, loc, status, endDate) async {
          try {
            await _labourService.updateSite(
              siteId: site.siteId,
              siteName: name,
              locationDetails: loc,
              status: status,
              endDate: endDate,
            );
            if (mounted) {
              context.showToast("Site updated successfully!", isSuccess: true);
              _loadInitialData();
            }
          } catch (e) {
            if (mounted) context.showExceptionToast(e, fallback: "Failed to update site.");
          }
        },
      ),
    );
  }

  void _confirmDeleteSite(LabourSite site) {
    _showMobilePopup(
      (ctx) => ConfirmActionDialog(
        title: "Delete Construction Site",
        message: "Are you sure you want to delete '${site.siteName}'? This will permanently remove its site allocations and schedules.",
        isDestructive: true,
        confirmText: "Delete Site",
        isBottomSheet: true,
        onConfirm: () async {
          try {
            await _labourService.deleteSite(site.siteId);
            if (mounted) {
              context.showToast("Site deleted successfully", isSuccess: true);
              _loadInitialData();
            }
          } catch (e) {
            if (mounted) context.showExceptionToast(e, fallback: "Failed to delete site.");
          }
        },
      ),
    );
  }

  void _openAddWorkerDialog() {
    _showMobilePopup(
      (ctx) => AddWorkerDialog(
        availableSites: _sites,
        isBottomSheet: true,
        onSave: (data) async {
          try {
            await _labourService.createLabour(data);
            if (mounted) {
              context.showToast("Worker profile registered successfully!", isSuccess: true);
              _loadInitialData();
            }
          } catch (e) {
            if (mounted) context.showExceptionToast(e, fallback: "Failed to create worker.");
          }
        },
      ),
    );
  }

  void _openEditWorkerDialog(LabourWorker worker) {
    _showMobilePopup(
      (ctx) => AddWorkerDialog(
        initialWorker: worker,
        availableSites: _sites,
        isBottomSheet: true,
        onSave: (data) async {
          try {
            await _labourService.updateLabour(worker.labourId, data);
            if (mounted) {
              context.showToast("Worker profile updated!", isSuccess: true);
              _loadInitialData();
            }
          } catch (e) {
            if (mounted) context.showExceptionToast(e, fallback: "Failed to update worker.");
          }
        },
      ),
    );
  }

  void _confirmDeleteWorker(LabourWorker worker) {
    _showMobilePopup(
      (ctx) => ConfirmActionDialog(
        title: "Delete Worker Profile",
        message: "Are you sure you want to delete '${worker.name}'? This action cannot be undone.",
        isDestructive: true,
        confirmText: "Delete Worker",
        isBottomSheet: true,
        onConfirm: () async {
          try {
            await _labourService.deleteLabour(worker.labourId);
            if (mounted) {
              context.showToast("Worker profile deleted", isSuccess: true);
              _loadInitialData();
            }
          } catch (e) {
            if (mounted) context.showExceptionToast(e, fallback: "Failed to delete worker.");
          }
        },
      ),
    );
  }

  void _openBulkTransferDialog([List<int> initialSelected = const []]) {
    _showMobilePopup(
      (ctx) => BulkTransferDialog(
        sites: _sites,
        workers: _workers,
        initialSourceSiteId: _selectedSite?.siteId ?? 'All',
        initialSelectedLabourIds: initialSelected,
        isBottomSheet: true,
        onTransfer: ({required sourceSiteId, required destinationSiteId, required labourIds, required roleFilter}) async {
          try {
            await _labourService.bulkTransferLabours(
              sourceSiteId: sourceSiteId,
              destinationSiteId: destinationSiteId,
              labourIds: labourIds,
              roleFilter: roleFilter,
            );
            if (mounted) {
              context.showToast("Transferred ${labourIds.length} worker(s) successfully!", isSuccess: true);
              _loadInitialData();
              if (_selectedSite != null) _loadAttendanceRoster();
            }
          } catch (e) {
            if (mounted) context.showExceptionToast(e, fallback: "Failed to transfer workers.");
          }
        },
      ),
    );
  }

  void _openBorrowWorkerDialog() {
    if (_selectedSite == null) return;
    final existingIds = _attendanceRoster.map((r) => r.labourId).toSet();

    _showMobilePopup(
      (ctx) => BorrowWorkerDialog(
        currentSiteId: _selectedSite!.siteId,
        currentSiteName: _selectedSite!.siteName,
        allWorkers: _workers,
        existingLabourIds: existingIds,
        isBottomSheet: true,
        onBorrow: (worker) {
          setState(() {
            _attendanceRoster.add(
              LabourAttendanceItem(
                labourId: worker.labourId,
                name: worker.name,
                role: worker.role,
                wageType: worker.wageType,
                status: 'Present',
                isBorrowed: true,
                overtimePayPerHour: worker.overtimePayPerHour,
                overtimeHours: 0.0,
              ),
            );
          });
          context.showToast("Added ${worker.name} to roster. Click Save to confirm.", isSuccess: true);
        },
      ),
    );
  }

  void _openLogAdvanceDialog(LabourPayoutSummary summary) {
    _showMobilePopup(
      (ctx) => LogAdvanceDialog(
        labourId: summary.labourId,
        labourName: summary.name,
        siteId: _selectedSite?.siteId,
        siteName: _selectedSite?.siteName ?? summary.siteName,
        isBottomSheet: true,
        onSave: ({required labourId, siteId, required amount, required date, required notes}) async {
          try {
            await _labourService.logAdvance(
              labourId: labourId,
              siteId: siteId,
              amount: amount,
              date: date,
              notes: notes,
            );
            if (mounted) {
              context.showToast("Salary advance logged successfully!", isSuccess: true);
              _loadFinances();
            }
          } catch (e) {
            if (mounted) context.showExceptionToast(e, fallback: "Failed to log advance.");
          }
        },
      ),
    );
  }

  void _openSettlePayoutDialog(LabourPayoutSummary summary) {
    final monthStr = DateFormat('yyyy-MM').format(_attendanceDate);
    _showMobilePopup(
      (ctx) => SettlePayoutDialog(
        summary: summary,
        siteId: _selectedSite?.siteId,
        month: monthStr,
        isBottomSheet: true,
        onSave: ({required labourId, siteId, required amount, required date, required paymentMode, required notes}) async {
          try {
            await _labourService.logPayout(
              labourId: labourId,
              siteId: siteId,
              amount: amount,
              date: date,
              paymentMode: paymentMode,
              notes: notes,
            );
            if (mounted) {
              context.showToast("Payout settled successfully!", isSuccess: true);
              _loadFinances();
            }
          } catch (e) {
            if (mounted) context.showExceptionToast(e, fallback: "Failed to process payout.");
          }
        },
      ),
    );
  }

  void _openLabourHistoryDialog(LabourWorker worker) {
    _showMobilePopup(
      (ctx) => LabourHistoryDialog(
        labour: worker,
        labourService: _labourService,
        isBottomSheet: true,
      ),
    );
  }

  void _openDailyScheduleDialog(LabourWorker worker) {
    _showMobilePopup(
      (ctx) => DailyScheduleDialog(
        labour: worker,
        sites: _sites,
        labourService: _labourService,
        isBottomSheet: true,
        onSaved: () {
          context.showToast("Daily schedule updated!", isSuccess: true);
          _loadInitialData();
        },
      ),
    );
  }

  void _openBulkUploadDialog() {
    _showMobilePopup(
      (ctx) => BulkUploadDialog(
        labourService: _labourService,
        isBottomSheet: true,
        onSuccess: () {
          context.showToast("Workers imported successfully from Excel!", isSuccess: true);
          _loadInitialData();
        },
      ),
    );
  }
}

// [upd:2026-04-13T09:00:00+05:30]
