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

/// Tablet Landscape Mode View for Labour & Site Worker Management
class LabourTabletLandscapeView extends StatefulWidget {
  const LabourTabletLandscapeView({super.key});

  @override
  State<LabourTabletLandscapeView> createState() => _LabourTabletLandscapeViewState();
}

// Backward compatibility alias
typedef LabourTabletLandscapeContent = LabourTabletLandscapeView;
typedef LabourDesktopContent = LabourTabletLandscapeView;

class _LabourTabletLandscapeViewState extends State<LabourTabletLandscapeView> {
  late LabourService _labourService;
  bool _isLoading = true;
  bool _isSavingAttendance = false;

  // Active Primary Tab: 'sites' or 'directory'
  String _activeTab = 'sites';

  // Selected site for drill-down (null = Site Directory, non-null = Site Dashboard)
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
  String _siteStatusFilter = 'All';

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
  dynamic _directorySiteFilter = 'All';
  String _directoryRoleFilter = 'All';
  final Set<int> _selectedDirectoryIds = {};

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
        context.showExceptionToast(e, fallback: "Failed to load labour portal data.");
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
        context.showExceptionToast(e, fallback: "Failed to load attendance checklist.");
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
        context.showExceptionToast(e, fallback: "Failed to load wage ledger.");
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
        context.showToast("Attendance roster saved successfully!", isSuccess: true);
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
    context.showToast("All workers marked present. Click 'Save Attendance' to commit.", isSuccess: true);
  }

  // ===========================================================================
  // BUILD METHOD (TABLET LANDSCAPE)
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LoadingScreen(
      isLoading: _isLoading,
      message: "Loading Labour Management (Tablet Landscape)...",
      child: Container(
        color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top Primary Navigation Bar
            _buildLandscapeNavBar(isDark),
            const SizedBox(height: 16),

            // Main Content Area
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
  // TABLET LANDSCAPE NAVIGATION BAR
  // ---------------------------------------------------------------------------
  Widget _buildLandscapeNavBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeTab = 'sites'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _activeTab == 'sites'
                      ? const Color(0xFF6366F1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business_rounded,
                      size: 18,
                      color: _activeTab == 'sites' ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Sites Overview (${_sites.length})",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _activeTab == 'sites' ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeTab = 'directory'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _activeTab == 'directory'
                      ? const Color(0xFF6366F1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      size: 18,
                      color: _activeTab == 'directory' ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Labour Directory (${_workers.length})",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
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
  // SITES OVERVIEW (TABLET LANDSCAPE)
  // ---------------------------------------------------------------------------
  Widget _buildSitesOverview(bool isDark) {
    final activeCount = _sites.where((s) => s.status == 'Active').length;
    final completedCount = _sites.where((s) => s.status == 'Completed').length;
    final totalWorkers = _workers.length;

    final filteredSites = _sites.where((s) {
      if (_siteStatusFilter != 'All' && s.status != _siteStatusFilter) return false;
      if (_siteSearch.isNotEmpty) {
        final q = _siteSearch.toLowerCase();
        final matchName = s.siteName.toLowerCase().contains(q);
        final matchLoc = s.locationDetails?.toLowerCase().contains(q) ?? false;
        if (!matchName && !matchLoc) return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // 4 KPI Summary Cards Row
        Row(
          children: [
            Expanded(
              child: LabourStatCard(
                title: "Active Contract Sites",
                value: "$activeCount",
                icon: Icons.construction_rounded,
                iconColor: const Color(0xFF10B981),
                subtitle: "Active operational projects",
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabourStatCard(
                title: "Completed Projects",
                value: "$completedCount",
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF3B82F6),
                subtitle: "Successfully delivered",
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabourStatCard(
                title: "Total Registered Workforce",
                value: "$totalWorkers",
                icon: Icons.groups_rounded,
                iconColor: const Color(0xFF6366F1),
                subtitle: "Active labour personnel",
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabourStatCard(
                title: "Total Contract Sites",
                value: "${_sites.length}",
                icon: Icons.apartment_rounded,
                iconColor: const Color(0xFFF59E0B),
                subtitle: "All recorded locations",
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search and Actions Bar
        Row(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 42,
                child: TextField(
                  onChanged: (val) => setState(() => _siteSearch = val.trim()),
                  style: GoogleFonts.poppins(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Search construction sites by name or address...",
                    hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search, size: 20),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Status Chips
            ...['All', 'Active', 'Completed', 'On Hold'].map((st) {
              final isSelected = _siteStatusFilter == st;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(st),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _siteStatusFilter = st),
                  selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFF6366F1),
                  backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? const Color(0xFF6366F1) : (isDark ? Colors.grey[400] : Colors.grey[700]),
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                  ),
                ),
              );
            }),
            const Spacer(),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: const BorderSide(color: Color(0xFF6366F1)),
              ),
              onPressed: () => _openBulkTransferDialog(),
              icon: const Icon(Icons.swap_horiz_rounded, size: 18, color: Color(0xFF6366F1)),
              label: Text("Bulk Transfer", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _openAddSiteDialog,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: Text("+ Add New Site", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Site Grid (Responsive Columns)
        Expanded(
          child: filteredSites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_city_outlined, size: 56, color: Colors.grey[500]),
                      const SizedBox(height: 12),
                      Text("No construction sites found matching filters", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 1300 ? 4 : (constraints.maxWidth > 850 ? 3 : 2);
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3.0,
                      ),
                      itemCount: filteredSites.length,
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
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SITE DRILL-DOWN DASHBOARD (TABLET LANDSCAPE)
  // ---------------------------------------------------------------------------
  Widget _buildSiteDashboard(bool isDark) {
    final site = _selectedSite!;

    return Column(
      children: [
        // Breadcrumb and Subtab Navigation Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: _onBackToSites,
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF6366F1)),
                    const SizedBox(width: 6),
                    Text(
                      "Sites Overview",
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text("/", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[500])),
              const SizedBox(width: 10),
              Text(
                site.siteName,
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
              const SizedBox(width: 10),
              SiteStatusBadge(status: site.status),
              const Spacer(),
              // Subtabs Segmented Buttons
              _buildLandscapeSubTabButton('attendance', Icons.fact_check_rounded, "Daily Attendance", isDark),
              const SizedBox(width: 6),
              _buildLandscapeSubTabButton('grid', Icons.grid_on_rounded, "Monthly Grid", isDark),
              const SizedBox(width: 6),
              _buildLandscapeSubTabButton('finances', Icons.account_balance_wallet_rounded, "Finances & Ledger", isDark),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Subtab Content
        Expanded(
          child: _subTab == 'attendance'
              ? _buildAttendanceSubTab(isDark)
              : (_subTab == 'grid' ? _buildMonthlyGridSubTab(isDark) : _buildFinancesSubTab(isDark)),
        ),
      ],
    );
  }

  Widget _buildLandscapeSubTabButton(String id, IconData icon, String label, bool isDark) {
    final isSelected = _subTab == id;
    return InkWell(
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700])),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ATTENDANCE SUB-TAB (TABLET LANDSCAPE)
  // ---------------------------------------------------------------------------
  Widget _buildAttendanceSubTab(bool isDark) {
    final roles = ['All', ...{..._attendanceRoster.map((r) => r.role)}];

    final filteredRoster = _attendanceRoster.where((r) {
      if (_attendanceRoleFilter != 'All' && r.role != _attendanceRoleFilter) return false;
      if (_attendanceSearch.isNotEmpty) {
        final q = _attendanceSearch.toLowerCase();
        if (!r.name.toLowerCase().contains(q) && !r.role.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();

    final presentCount = _attendanceRoster.where((r) => r.status == 'Present').length;
    final halfCount = _attendanceRoster.where((r) => r.status == 'Half Day').length;
    final absentCount = _attendanceRoster.where((r) => r.status == 'Absent').length;
    final plCount = _attendanceRoster.where((r) => r.status == 'Paid Leave').length;

    return Column(
      children: [
        // Controls Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              // Date Navigator
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 22),
                onPressed: () {
                  setState(() => _attendanceDate = _attendanceDate.subtract(const Duration(days: 1)));
                  _loadAttendanceRoster();
                },
              ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Color(0xFF6366F1)),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(_attendanceDate),
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 22),
                onPressed: () {
                  setState(() => _attendanceDate = _attendanceDate.add(const Duration(days: 1)));
                  _loadAttendanceRoster();
                },
              ),
              const SizedBox(width: 14),

              // Role Filter
              CustomDropdown<String>(
                value: _attendanceRoleFilter,
                height: 38,
                fontSize: 11.5,
                items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r == 'All' ? 'All Roles' : r))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _attendanceRoleFilter = val);
                },
              ),
              const SizedBox(width: 14),

              // Search Filter
              SizedBox(
                width: 220,
                height: 38,
                child: TextField(
                  onChanged: (val) => setState(() => _attendanceSearch = val.trim()),
                  style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Search roster...",
                    hintStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search, size: 16),
                    fillColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
              const Spacer(),

              // Quick Actions
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: const BorderSide(color: Color(0xFF10B981)),
                ),
                onPressed: _openBorrowWorkerDialog,
                icon: const Icon(Icons.person_add, color: Color(0xFF10B981), size: 16),
                label: Text("Borrow Worker", style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: const BorderSide(color: Color(0xFF6366F1)),
                ),
                onPressed: _markAllPresent,
                child: Text("Mark All Present", style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: _isSavingAttendance ? null : _saveAttendance,
                icon: _isSavingAttendance
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded, color: Colors.white, size: 16),
                label: Text("Save Attendance", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Summary Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Text(
                "Total Roster: ${_attendanceRoster.length} workers",
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(width: 16),
              _buildCountChip("Present: $presentCount", const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _buildCountChip("Half Day: $halfCount", const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              _buildCountChip("Absent: $absentCount", const Color(0xFFEF4444)),
              const SizedBox(width: 8),
              _buildCountChip("Paid Leave: $plCount", const Color(0xFF3B82F6)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Roster Table
        Expanded(
          child: _attendanceLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
              : filteredRoster.isEmpty
                  ? Center(child: Text("No workers on roster for this date", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500])))
                  : ListView.builder(
                      itemCount: filteredRoster.length,
                      itemBuilder: (context, i) {
                        final item = filteredRoster[i];
                        return _buildAttendanceRosterRow(item, isDark);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildCountChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildAttendanceRosterRow(LabourAttendanceItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: item.status.isNotEmpty
              ? const Color(0xFF6366F1).withValues(alpha: 0.3)
              : (isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          // Worker Name & Details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.isBorrowed) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text("Borrowed", style: GoogleFonts.poppins(fontSize: 8.5, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                      ),
                    ],
                    if (item.isScheduledMultiSite) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text("Multi-Site", style: GoogleFonts.poppins(fontSize: 8.5, fontWeight: FontWeight.bold, color: const Color(0xFF8B5CF6))),
                      ),
                    ],
                  ],
                ),
                Text(
                  "OT Rate: ₹${item.overtimePayPerHour.toStringAsFixed(0)}/hr",
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          SkillBadge(skill: item.role),
          const SizedBox(width: 14),

          // 4 Status Buttons
          _buildLandscapeAttendanceButton(item, 'Present', 'P', const Color(0xFF10B981)),
          const SizedBox(width: 5),
          _buildLandscapeAttendanceButton(item, 'Half Day', 'HD', const Color(0xFFF59E0B)),
          const SizedBox(width: 5),
          _buildLandscapeAttendanceButton(item, 'Absent', 'A', const Color(0xFFEF4444)),
          const SizedBox(width: 5),
          _buildLandscapeAttendanceButton(item, 'Paid Leave', 'PL', const Color(0xFF3B82F6)),
          const SizedBox(width: 14),

          // Overtime Stepper & Calculated Pay
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 18),
                onPressed: () {
                  if (item.overtimeHours > 0) {
                    setState(() => item.overtimeHours = (item.overtimeHours - 0.5).clamp(0.0, 24.0));
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${item.overtimeHours.toStringAsFixed(1)}h OT (+₹${(item.overtimeHours * item.overtimePayPerHour).toStringAsFixed(0)})",
                  style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1)),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 18),
                onPressed: () {
                  setState(() => item.overtimeHours = (item.overtimeHours + 0.5).clamp(0.0, 24.0));
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

  Widget _buildLandscapeAttendanceButton(LabourAttendanceItem item, String status, String label, Color color) {
    final isSelected = item.status == status;
    return InkWell(
      onTap: () => setState(() => item.status = isSelected ? '' : status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MONTHLY GRID (TABLET LANDSCAPE)
  // ---------------------------------------------------------------------------
  Widget _buildMonthlyGridSubTab(bool isDark) {
    final daysInMonth = DateTime(_gridMonth.year, _gridMonth.month + 1, 0).day;
    final filteredGrid = _gridData.where((r) {
      if (_gridRoleFilter != 'All' && r.role != _gridRoleFilter) return false;
      return true;
    }).toList();

    return Column(
      children: [
        // Month Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 22),
                onPressed: () {
                  setState(() => _gridMonth = DateTime(_gridMonth.year, _gridMonth.month - 1));
                  _loadMonthlyGrid();
                },
              ),
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
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 22),
                onPressed: () {
                  setState(() => _gridMonth = DateTime(_gridMonth.year, _gridMonth.month + 1));
                  _loadMonthlyGrid();
                },
              ),
              const SizedBox(width: 20),
              // Legend
              _buildLegendItem("P", "Present", const Color(0xFF10B981)),
              const SizedBox(width: 10),
              _buildLegendItem("HD", "Half Day", const Color(0xFFF59E0B)),
              const SizedBox(width: 10),
              _buildLegendItem("A", "Absent", const Color(0xFFEF4444)),
              const SizedBox(width: 10),
              _buildLegendItem("PL", "Paid Leave", const Color(0xFF3B82F6)),
              const SizedBox(width: 16),
              CustomDropdown<String>(
                value: _gridRoleFilter,
                height: 38,
                fontSize: 11.5,
                items: ['All', ...{..._gridData.map((r) => r.role)}].map((r) => DropdownMenuItem(value: r, child: Text(r == 'All' ? 'All Roles' : r))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _gridRoleFilter = val);
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: _exportMonthlyGridToExcel,
                icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 16),
                label: Text("Export Excel Matrix", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Matrix Table
        Expanded(
          child: _gridLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
              : filteredGrid.isEmpty
                  ? Center(child: Text("No monthly grid attendance logged", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500])))
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
                            headingRowHeight: 40,
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 44,
                            columnSpacing: 14,
                            horizontalMargin: 12,
                            columns: [
                              const DataColumn(label: Text("Worker Name")),
                              const DataColumn(label: Text("Role")),
                              const DataColumn(label: Text("Base Wage")),
                              ...List.generate(
                                daysInMonth,
                                (d) => DataColumn(
                                  label: Text(
                                    "${d + 1}",
                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const DataColumn(label: Text("Present (P)")),
                              const DataColumn(label: Text("Half (HD)")),
                              const DataColumn(label: Text("Absent (A)")),
                              const DataColumn(label: Text("Leave (PL)")),
                              const DataColumn(label: Text("OT (Hrs)")),
                            ],
                            rows: filteredGrid.map((row) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(row.name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold))),
                                  DataCell(SkillBadge(skill: row.role)),
                                  DataCell(Text("₹${row.monthlySalary.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400]))),
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
                                            style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.bold, color: _getGridCellFg(st)),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  DataCell(Text("${row.totalPresent}", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)))),
                                  DataCell(Text("${row.totalHalfDays}", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)))),
                                  DataCell(Text("${row.totalAbsent}", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)))),
                                  DataCell(Text("${row.totalPaidLeaves}", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6)))),
                                  DataCell(Text("${row.totalOvertimeHours.toStringAsFixed(1)}h", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF8B5CF6)))),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String code, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Text(code, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
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
  // FINANCES SUB-TAB (TABLET LANDSCAPE)
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

    return Column(
      children: [
        // 4 KPI Summary Cards
        Row(
          children: [
            Expanded(
              child: LabourStatCard(
                title: "Total Accrued Credit",
                value: "₹${totalAccrued.toStringAsFixed(0)}",
                icon: Icons.account_balance_wallet_rounded,
                iconColor: const Color(0xFF6366F1),
                subtitle: "Calculated wages & OT",
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabourStatCard(
                title: "Total Advances Disbursed",
                value: "₹${totalAdvances.toStringAsFixed(0)}",
                icon: Icons.price_change_rounded,
                iconColor: const Color(0xFFF59E0B),
                subtitle: "Pre-settlement advances",
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabourStatCard(
                title: "Net Payable Balance",
                value: "₹${totalNet.toStringAsFixed(0)}",
                icon: Icons.pending_actions_rounded,
                iconColor: const Color(0xFF10B981),
                subtitle: "Outstanding payable",
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabourStatCard(
                title: "Total Settled / Paid",
                value: "₹${totalPaid.toStringAsFixed(0)}",
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF3B82F6),
                subtitle: "Confirmed transactions",
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Header & Export
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Wage & Salary Ledger (${filteredFinances.length} Workers)",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
              Row(
                children: [
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _financeRoleFilter,
                        dropdownColor: isDark ? const Color(0xFF161B22) : Colors.white,
                        style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? Colors.white : Colors.black87),
                        items: ['All', ...{..._financeSummary.map((f) => f.role)}].map((r) => DropdownMenuItem(value: r, child: Text(r == 'All' ? 'All Roles' : r))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _financeRoleFilter = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: _exportPayoutsToExcel,
                    icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 16),
                    label: Text("Export Payroll Sheet", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Ledger Table
        Expanded(
          child: _financeLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
              : filteredFinances.isEmpty
                  ? Center(child: Text("No wage ledger entries for this site", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500])))
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
                            headingRowHeight: 40,
                            dataRowMinHeight: 48,
                            dataRowMaxHeight: 52,
                            columnSpacing: 16,
                            columns: const [
                            DataColumn(label: Text("Worker Name")),
                            DataColumn(label: Text("Role")),
                            DataColumn(label: Text("Daily Rate")),
                            DataColumn(label: Text("Days Worked")),
                            DataColumn(label: Text("Overtime")),
                            DataColumn(label: Text("Accrued Credit")),
                            DataColumn(label: Text("Advances Logged")),
                            DataColumn(label: Text("Net Payable")),
                            DataColumn(label: Text("Status")),
                            DataColumn(label: Text("Actions")),
                          ],
                          rows: filteredFinances.map((f) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  InkWell(
                                    onTap: () {
                                      final worker = _workers.firstWhere(
                                        (w) => w.labourId == f.labourId,
                                        orElse: () => LabourWorker(
                                          labourId: f.labourId,
                                          name: f.name,
                                          role: f.role,
                                          wageType: 'Daily Wage',
                                          monthlySalary: f.dailyRate,
                                          allowedLeaves: 0,
                                          overtimePayPerHour: f.overtimeRate,
                                          status: 'Active',
                                          sex: 'Male',
                                        ),
                                      );
                                      _openLabourHistoryDialog(worker);
                                    },
                                    child: Text(
                                      f.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF6366F1),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(SkillBadge(skill: f.role)),
                                DataCell(Text("₹${f.dailyRate.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontSize: 12))),
                                DataCell(Text("${f.daysPresent}P + ${f.halfDays}HD", style: GoogleFonts.poppins(fontSize: 12))),
                                DataCell(Text("${f.overtimeHours.toStringAsFixed(1)}h (+₹${f.otEarning.toStringAsFixed(0)})", style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF8B5CF6)))),
                                DataCell(Text("₹${f.accruedCredit.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1)))),
                                DataCell(Text("-₹${f.totalAdvance.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)))),
                                DataCell(Text("₹${f.netPayable.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: (f.status == 'Paid' ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      f.status.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: f.status == 'Paid' ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          side: const BorderSide(color: Color(0xFFF59E0B)),
                                          minimumSize: Size.zero,
                                        ),
                                        onPressed: () => _openLogAdvanceDialog(f),
                                        child: Text("+ Advance", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF10B981),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          minimumSize: Size.zero,
                                        ),
                                        onPressed: () => _openSettlePayoutDialog(f),
                                        child: Text("Settle Payout", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
        ),
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
      if (mounted) context.showToast("Payroll ledger exported to Excel!", isSuccess: true);
    } catch (e) {
      if (mounted) context.showExceptionToast(e, fallback: "Failed to export Excel file.");
    }
  }

  // ---------------------------------------------------------------------------
  // SUB-TAB 4: LABOUR DIRECTORY (TABLET LANDSCAPE)
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

    return Column(
      children: [
        // Top Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    onChanged: (val) => setState(() => _directorySearch = val.trim()),
                    style: GoogleFonts.poppins(fontSize: 12.5, color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Search labours by name, phone number, skill trade...",
                      hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      fillColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Site Filter
              CustomDropdown<dynamic>(
                value: _directorySiteFilter,
                height: 40,
                fontSize: 11.5,
                items: [
                  const DropdownMenuItem(value: 'All', child: Text("All Construction Sites")),
                  const DropdownMenuItem(value: 'Unassigned', child: Text("Unassigned (General Pool)")),
                  ..._sites.map((s) => DropdownMenuItem(value: s.siteId, child: Text(s.siteName))),
                ],
                onChanged: (val) => setState(() => _directorySiteFilter = val),
              ),
              const SizedBox(width: 10),

              // Role Filter
              CustomDropdown<String>(
                value: _directoryRoleFilter,
                height: 40,
                fontSize: 11.5,
                items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r == 'All' ? 'All Roles' : r))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _directoryRoleFilter = val);
                },
              ),
              const SizedBox(width: 14),

              // Action Buttons
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: const BorderSide(color: Color(0xFF6366F1)),
                ),
                onPressed: () => _openBulkTransferDialog(_selectedDirectoryIds.toList()),
                icon: const Icon(Icons.swap_horiz_rounded, size: 18, color: Color(0xFF6366F1)),
                label: Text("Bulk Transfer", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: const BorderSide(color: Color(0xFF10B981)),
                ),
                onPressed: _openBulkUploadDialog,
                icon: const Icon(Icons.upload_file_rounded, size: 18, color: Color(0xFF10B981)),
                label: Text("Bulk Upload", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _openAddWorkerDialog,
                icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 18),
                label: Text("+ Add Worker", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Workers Table
        Expanded(
          child: filteredWorkers.isEmpty
              ? Center(child: Text("No workers found matching filters", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500])))
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
                        showCheckboxColumn: true,
                        onSelectAll: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedDirectoryIds.addAll(filteredWorkers.map((w) => w.labourId));
                            } else {
                              _selectedDirectoryIds.clear();
                            }
                          });
                        },
                        headingRowHeight: 36,
                        dataRowMinHeight: 38,
                        dataRowMaxHeight: 44,
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        columns: const [
                          DataColumn(label: Text("Worker Full Name")),
                          DataColumn(label: Text("Mobile Phone")),
                          DataColumn(label: Text("Gender")),
                          DataColumn(label: Text("Skill / Role")),
                          DataColumn(label: Text("Base Daily Wage")),
                          DataColumn(label: Text("Overtime Rate")),
                          DataColumn(label: Text("Assigned Site")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: filteredWorkers.map((w) {
                          final isChecked = _selectedDirectoryIds.contains(w.labourId);
                          return DataRow(
                            selected: isChecked,
                            onSelectChanged: (selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedDirectoryIds.add(w.labourId);
                                } else {
                                  _selectedDirectoryIds.remove(w.labourId);
                                }
                              });
                            },
                            cells: [
                              DataCell(
                                InkWell(
                                  onTap: () => _openLabourHistoryDialog(w),
                                  child: Text(
                                    w.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF6366F1),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(w.phone ?? 'N/A', style: GoogleFonts.poppins(fontSize: 11.5))),
                              DataCell(Text(w.sex, style: GoogleFonts.poppins(fontSize: 11.5))),
                              DataCell(SkillBadge(skill: w.role)),
                              DataCell(Text("₹${w.monthlySalary.toStringAsFixed(0)}/day", style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)))),
                              DataCell(Text("₹${w.overtimePayPerHour.toStringAsFixed(0)}/hr", style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF8B5CF6)))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(w.siteName, style: GoogleFonts.poppins(fontSize: 10.5, color: isDark ? Colors.grey[300] : Colors.grey[800]), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text("ACTIVE", style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF6366F1)),
                                      onPressed: () => _openDailyScheduleDialog(w),
                                      tooltip: "Multi-Site Schedule Planner",
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                      onPressed: () => _openEditWorkerDialog(w),
                                      tooltip: "Edit Worker Profile",
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                                      onPressed: () => _confirmDeleteWorker(w),
                                      tooltip: "Delete Worker",
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                    ),
                  ),
                ),
              ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MODAL LAUNCHERS
  // ===========================================================================

  void _openAddSiteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddSiteDialog(
        onSave: (name, loc, status, endDate) async {
          try {
            await _labourService.createSite(
              siteName: name,
              locationDetails: loc,
              status: status,
              endDate: endDate,
            );
            if (mounted) {
              context.showToast("Construction site created successfully!", isSuccess: true);
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
    showDialog(
      context: context,
      builder: (ctx) => AddSiteDialog(
        initialSite: site,
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
              context.showToast("Construction site updated successfully!", isSuccess: true);
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
    showDialog(
      context: context,
      builder: (ctx) => ConfirmActionDialog(
        title: "Delete Construction Site",
        message: "Are you sure you want to delete '${site.siteName}'? This will remove all associated workers and schedules.",
        isDestructive: true,
        confirmText: "Delete Site",
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
    showDialog(
      context: context,
      builder: (ctx) => AddWorkerDialog(
        availableSites: _sites,
        onSave: (data) async {
          try {
            await _labourService.createLabour(data);
            if (mounted) {
              context.showToast("Worker registered successfully!", isSuccess: true);
              _loadInitialData();
            }
          } catch (e) {
            if (mounted) context.showExceptionToast(e, fallback: "Failed to register worker.");
          }
        },
      ),
    );
  }

  void _openEditWorkerDialog(LabourWorker worker) {
    showDialog(
      context: context,
      builder: (ctx) => AddWorkerDialog(
        initialWorker: worker,
        availableSites: _sites,
        onSave: (data) async {
          try {
            await _labourService.updateLabour(worker.labourId, data);
            if (mounted) {
              context.showToast("Worker updated successfully!", isSuccess: true);
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
    showDialog(
      context: context,
      builder: (ctx) => ConfirmActionDialog(
        title: "Delete Worker Profile",
        message: "Are you sure you want to delete '${worker.name}'? This action cannot be undone.",
        isDestructive: true,
        confirmText: "Delete Worker",
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
    showDialog(
      context: context,
      builder: (ctx) => BulkTransferDialog(
        sites: _sites,
        workers: _workers,
        initialSourceSiteId: _selectedSite?.siteId ?? 'All',
        initialSelectedLabourIds: initialSelected,
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

    showDialog(
      context: context,
      builder: (ctx) => BorrowWorkerDialog(
        currentSiteId: _selectedSite!.siteId,
        currentSiteName: _selectedSite!.siteName,
        allWorkers: _workers,
        existingLabourIds: existingIds,
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
          context.showToast("Added ${worker.name} to roster. Click Save Attendance to commit.", isSuccess: true);
        },
      ),
    );
  }

  void _openLogAdvanceDialog(LabourPayoutSummary summary) {
    showDialog(
      context: context,
      builder: (ctx) => LogAdvanceDialog(
        labourId: summary.labourId,
        labourName: summary.name,
        siteId: _selectedSite?.siteId,
        siteName: _selectedSite?.siteName ?? summary.siteName,
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
              context.showToast("Advance logged successfully!", isSuccess: true);
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
    showDialog(
      context: context,
      builder: (ctx) => SettlePayoutDialog(
        summary: summary,
        siteId: _selectedSite?.siteId,
        month: monthStr,
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
    showDialog(
      context: context,
      builder: (ctx) => LabourHistoryDialog(
        labour: worker,
        labourService: _labourService,
      ),
    );
  }

  void _openDailyScheduleDialog(LabourWorker worker) {
    showDialog(
      context: context,
      builder: (ctx) => DailyScheduleDialog(
        labour: worker,
        sites: _sites,
        labourService: _labourService,
        onSaved: () {
          context.showToast("Daily schedule saved!", isSuccess: true);
          _loadInitialData();
        },
      ),
    );
  }

  void _openBulkUploadDialog() {
    showDialog(
      context: context,
      builder: (ctx) => BulkUploadDialog(
        labourService: _labourService,
        onSuccess: () {
          context.showToast("Workers imported from Excel file!", isSuccess: true);
          _loadInitialData();
        },
      ),
    );
  }
}

// [upd:2026-04-15T09:00:00+05:30]
