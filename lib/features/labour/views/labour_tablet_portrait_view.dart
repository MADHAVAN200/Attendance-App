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

class LabourTabletContent extends StatefulWidget {
  const LabourTabletContent({super.key});

  @override
  State<LabourTabletContent> createState() => _LabourTabletContentState();
}

/// Tablet Portrait Mode View
typedef LabourTabletPortraitView = LabourTabletContent;
typedef LabourTabletPortraitContent = LabourTabletContent;

class _LabourTabletContentState extends State<LabourTabletContent> {
  late LabourService _labourService;
  bool _isLoading = true;
  bool _isSavingAttendance = false;

  // Active Tab: 'sites' or 'directory'
  String _activeTab = 'sites';

  // Selected site for drill-down
  LabourSite? _selectedSite;

  // Subtab: 'attendance', 'grid', 'finances'
  String _subTab = 'attendance';

  // Data
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
        context.showExceptionToast(e, fallback: "Failed to load attendance roster.");
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
        context.showExceptionToast(e, fallback: "Failed to load finances.");
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
        context.showExceptionToast(e, fallback: "Failed to save attendance.");
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
    context.showToast("All workers marked present. Click 'Save Attendance' to confirm.", isSuccess: true);
  }

  // ===========================================================================
  // BUILD METHOD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LoadingScreen(
      isLoading: _isLoading,
      message: "Loading Labour Portal...",
      child: Container(
        color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Primary Navigation Bar
            _buildTabletNavBar(isDark),
            const SizedBox(height: 14),

            // Content Area
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
  // TABLET NAVIGATION BAR
  // ---------------------------------------------------------------------------
  Widget _buildTabletNavBar(bool isDark) {
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
  // SITES OVERVIEW
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
                title: "Active Sites",
                value: "$activeCount",
                icon: Icons.construction_rounded,
                iconColor: const Color(0xFF10B981),
                subtitle: "Ongoing construction",
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
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
            const SizedBox(width: 10),
            Expanded(
              child: LabourStatCard(
                title: "Total Labours",
                value: "$totalWorkers",
                icon: Icons.groups_rounded,
                iconColor: const Color(0xFF6366F1),
                subtitle: "Registered workforce",
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
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
        const SizedBox(height: 14),

        // Search & Action Toolbar
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  onChanged: (val) => setState(() => _siteSearch = val.trim()),
                  style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Search site name or location...",
                    hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search, size: 18),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Status Chips
            ...['All', 'Active', 'Completed', 'On Hold'].map((st) {
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
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? const Color(0xFF6366F1) : (isDark ? Colors.grey[400] : Colors.grey[700]),
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                  ),
                ),
              );
            }),
            const SizedBox(width: 6),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: const BorderSide(color: Color(0xFF6366F1)),
              ),
              onPressed: () => _openBulkTransferDialog(),
              icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: Color(0xFF6366F1)),
              label: Text("Bulk Transfer", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
            ),
            const SizedBox(width: 6),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _openAddSiteDialog,
              icon: const Icon(Icons.add, color: Colors.white, size: 16),
              label: Text("+ Add Site", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Responsive Site Grid (2 columns)
        Expanded(
          child: filteredSites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_city_outlined, size: 48, color: Colors.grey[500]),
                      const SizedBox(height: 10),
                      Text("No construction sites found matching filters", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500])),
                    ],
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 3.2,
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
                ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SITE DRILL-DOWN DASHBOARD (TABLET PORTRAIT)
  // ---------------------------------------------------------------------------
  Widget _buildSiteDashboard(bool isDark) {
    final site = _selectedSite!;

    return Column(
      children: [
        // Breadcrumb Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text("/", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  site.siteName,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SiteStatusBadge(status: site.status),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Sub-tabs Row
        Row(
          children: [
            _buildTabletSubTabChip('attendance', Icons.fact_check_rounded, "Daily Attendance", isDark),
            const SizedBox(width: 8),
            _buildTabletSubTabChip('grid', Icons.grid_on_rounded, "Monthly Grid", isDark),
            const SizedBox(width: 8),
            _buildTabletSubTabChip('finances', Icons.account_balance_wallet_rounded, "Salary & Advance Tracker", isDark),
          ],
        ),
        const SizedBox(height: 12),

        // Sub-tab Body
        Expanded(
          child: _subTab == 'attendance'
              ? _buildAttendanceSubTab(isDark)
              : (_subTab == 'grid' ? _buildMonthlyGridSubTab(isDark) : _buildFinancesSubTab(isDark)),
        ),
      ],
    );
  }

  Widget _buildTabletSubTabChip(String id, IconData icon, String label, bool isDark) {
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
          padding: const EdgeInsets.symmetric(vertical: 8),
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
              Icon(icon, size: 16, color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700])),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ATTENDANCE SUB-TAB (TABLET)
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
        // Controls Toolbar Row 1: Navigator, Filter, Search
        Row(
          children: [
            // Date Navigator
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: () {
                setState(() => _attendanceDate = _attendanceDate.subtract(const Duration(days: 1)));
                _loadAttendanceRoster();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 4),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161B22) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 13, color: Color(0xFF6366F1)),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEE, dd MMM yyyy').format(_attendanceDate),
                      style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () {
                setState(() => _attendanceDate = _attendanceDate.add(const Duration(days: 1)));
                _loadAttendanceRoster();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),

            // Role Filter
            CustomDropdown<String>(
              value: _attendanceRoleFilter,
              height: 36,
              fontSize: 11,
              items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r == 'All' ? 'All Roles' : r))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _attendanceRoleFilter = val);
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  onChanged: (val) => setState(() => _attendanceSearch = val.trim()),
                  style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Search labours...",
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                side: const BorderSide(color: Color(0xFF10B981)),
                minimumSize: Size.zero,
              ),
              onPressed: _openBorrowWorkerDialog,
              icon: const Icon(Icons.person_add, color: Color(0xFF10B981), size: 15),
              label: Text("Borrow Worker", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
            ),
            const Spacer(),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                side: const BorderSide(color: Color(0xFF6366F1)),
                minimumSize: Size.zero,
              ),
              onPressed: _markAllPresent,
              child: Text("Mark All Present", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                minimumSize: Size.zero,
              ),
              onPressed: _isSavingAttendance ? null : _saveAttendance,
              icon: _isSavingAttendance
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_rounded, color: Colors.white, size: 15),
              label: Text("Save Attendance", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Summary Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  "Roster: ${_attendanceRoster.length} workers",
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(width: 14),
                _buildCountChip("Present: $presentCount", const Color(0xFF10B981)),
                const SizedBox(width: 6),
                _buildCountChip("Half Day: $halfCount", const Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                _buildCountChip("Absent: $absentCount", const Color(0xFFEF4444)),
                const SizedBox(width: 6),
                _buildCountChip("Paid Leave: $plCount", const Color(0xFF3B82F6)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Attendance Roster List
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
    );
  }

  Widget _buildCountChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildAttendanceRosterCard(LabourAttendanceItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 2),
                Row(
                  children: [
                    SkillBadge(skill: item.role),
                    const SizedBox(width: 6),
                    Text(
                      "OT: ₹${item.overtimePayPerHour.toStringAsFixed(0)}/hr",
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // 4 Status Buttons
          _buildAttendanceButton(item, 'Present', 'P', const Color(0xFF10B981)),
          const SizedBox(width: 5),
          _buildAttendanceButton(item, 'Half Day', 'HD', const Color(0xFFF59E0B)),
          const SizedBox(width: 5),
          _buildAttendanceButton(item, 'Absent', 'A', const Color(0xFFEF4444)),
          const SizedBox(width: 5),
          _buildAttendanceButton(item, 'Paid Leave', 'PL', const Color(0xFF3B82F6)),
          const SizedBox(width: 10),

          // OT Hours Stepper
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 17),
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${item.overtimeHours.toStringAsFixed(1)}h",
                  style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1)),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 17),
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

  Widget _buildAttendanceButton(LabourAttendanceItem item, String status, String label, Color color) {
    final isSelected = item.status == status;
    return InkWell(
      onTap: () => setState(() => item.status = isSelected ? '' : status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
  // MONTHLY GRID (TABLET)
  // ---------------------------------------------------------------------------
  Widget _buildMonthlyGridSubTab(bool isDark) {
    final daysInMonth = DateTime(_gridMonth.year, _gridMonth.month + 1, 0).day;
    final filteredGrid = _gridData.where((r) {
      if (_gridRoleFilter != 'All' && r.role != _gridRoleFilter) return false;
      return true;
    }).toList();

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 22),
              onPressed: () {
                setState(() => _gridMonth = DateTime(_gridMonth.year, _gridMonth.month - 1));
                _loadMonthlyGrid();
              },
            ),
            Text(
              DateFormat('MMMM yyyy').format(_gridMonth),
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 22),
              onPressed: () {
                setState(() => _gridMonth = DateTime(_gridMonth.year, _gridMonth.month + 1));
                _loadMonthlyGrid();
              },
            ),
            const SizedBox(width: 10),
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _gridRoleFilter,
                  dropdownColor: isDark ? const Color(0xFF161B22) : Colors.white,
                  style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.white : Colors.black87),
                  items: ['All', ...{..._gridData.map((r) => r.role)}].map((r) => DropdownMenuItem(value: r, child: Text(r == 'All' ? 'All Roles' : r))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _gridRoleFilter = val);
                  },
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: _exportMonthlyGridToExcel,
              icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 16),
              label: Text("Export Excel Matrix", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Grid View Table
        Expanded(
          child: _gridLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
              : filteredGrid.isEmpty
                  ? Center(child: Text("No monthly grid attendance logged", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])))
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
                            headingRowHeight: 38,
                            dataRowMinHeight: 38,
                            dataRowMaxHeight: 42,
                            columnSpacing: 14,
                            horizontalMargin: 12,
                            columns: [
                              const DataColumn(label: Text("Worker Name")),
                              const DataColumn(label: Text("Role")),
                              const DataColumn(label: Text("Wage (₹)")),
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
                                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: _getGridCellFg(st)),
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
      context.showToast("No grid data to export", isSuccess: false);
      return;
    }
    try {
      await LabourExcelExportHelper.exportMonthlyGridToExcel(
        grid: _gridData,
        siteName: _selectedSite?.siteName ?? 'Site',
        month: _gridMonth,
      );
      if (mounted) context.showToast("Exported monthly attendance to Excel!", isSuccess: true);
    } catch (e) {
      if (mounted) context.showExceptionToast(e, fallback: "Failed to export Excel.");
    }
  }

  // ---------------------------------------------------------------------------
  // FINANCES SUB-TAB (TABLET)
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
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: LabourStatCard(
                title: "Advances Disbursed",
                value: "₹${totalAdvances.toStringAsFixed(0)}",
                icon: Icons.price_change_rounded,
                iconColor: const Color(0xFFF59E0B),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: LabourStatCard(
                title: "Net Payable Balance",
                value: "₹${totalNet.toStringAsFixed(0)}",
                icon: Icons.pending_actions_rounded,
                iconColor: const Color(0xFF10B981),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
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

        // Header & Export Action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Wage & Salary Ledger (${filteredFinances.length} Workers)",
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _financeRoleFilter,
                      dropdownColor: isDark ? const Color(0xFF161B22) : Colors.white,
                      style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.white : Colors.black87),
                      items: ['All', ...{..._financeSummary.map((f) => f.role)}].map((r) => DropdownMenuItem(value: r, child: Text(r == 'All' ? 'All Roles' : r))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _financeRoleFilter = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: _exportPayoutsToExcel,
                  icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 16),
                  label: Text("Export Payroll", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Ledger Table
        Expanded(
          child: _financeLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
              : filteredFinances.isEmpty
                  ? Center(child: Text("No wage ledger records for this site", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])))
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
                            headingRowHeight: 38,
                            dataRowMinHeight: 44,
                            dataRowMaxHeight: 48,
                            columnSpacing: 14,
                            columns: const [
                              DataColumn(label: Text("Worker")),
                              DataColumn(label: Text("Role")),
                              DataColumn(label: Text("Rate")),
                              DataColumn(label: Text("Days Worked")),
                              DataColumn(label: Text("OT")),
                              DataColumn(label: Text("Accrued")),
                              DataColumn(label: Text("Advance")),
                              DataColumn(label: Text("Net Payable")),
                              DataColumn(label: Text("Actions")),
                            ],
                            rows: filteredFinances.map((f) {
                              final isSettled = f.netPayable <= 0;
                              return DataRow(
                                cells: [
                                  DataCell(Text(f.name, style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87))),
                                  DataCell(SkillBadge(skill: f.role)),
                                  DataCell(Text("₹${f.dailyRate.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.white : Colors.black87))),
                                  DataCell(Text("${f.daysPresent}P + ${f.halfDays}HD", style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.white : Colors.black87))),
                                  DataCell(Text("${f.overtimeHours.toStringAsFixed(1)}h", style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.white : Colors.black87))),
                                  DataCell(Text("₹${f.accruedCredit.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF6366F1)))),
                                  DataCell(Text("-₹${f.totalAdvance.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFFEF4444)))),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: (f.netPayable > 0 ? const Color(0xFF10B981) : Colors.grey).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "₹${f.netPayable.toStringAsFixed(0)}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: f.netPayable > 0 ? const Color(0xFF10B981) : Colors.grey,
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
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            side: const BorderSide(color: Color(0xFFF59E0B)),
                                            minimumSize: Size.zero,
                                          ),
                                          onPressed: () => _openLogAdvanceDialog(f),
                                          child: Text("+ Adv", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                                        ),
                                        const SizedBox(width: 6),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isSettled ? Colors.grey[700] : const Color(0xFF10B981),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            minimumSize: Size.zero,
                                          ),
                                          onPressed: () => _openSettlePayoutDialog(f),
                                          child: Text(
                                            isSettled ? "Settled ✓" : "Settle",
                                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
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
      context.showToast("No payouts data to export", isSuccess: false);
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
      if (mounted) context.showToast("Exported payroll sheet to Excel!", isSuccess: true);
    } catch (e) {
      if (mounted) context.showExceptionToast(e, fallback: "Failed to export Excel.");
    }
  }

  // ---------------------------------------------------------------------------
  // SUB-TAB 4: LABOUR DIRECTORY (TABLET PORTRAIT)
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
        // Action Toolbar Row 1: Search + Filters
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  onChanged: (val) => setState(() => _directorySearch = val.trim()),
                  style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Search workers by name, phone or skill...",
                    hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search, size: 18),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Site Filter
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<dynamic>(
                  value: _directorySiteFilter,
                  dropdownColor: isDark ? const Color(0xFF161B22) : Colors.white,
                  style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.white : Colors.black87),
                  items: [
                    const DropdownMenuItem(value: 'All', child: Text("All Sites")),
                    const DropdownMenuItem(value: 'Unassigned', child: Text("Unassigned")),
                    ..._sites.map((s) => DropdownMenuItem(value: s.siteId, child: Text(s.siteName))),
                  ],
                  onChanged: (val) => setState(() => _directorySiteFilter = val),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Role Filter
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _directoryRoleFilter,
                  dropdownColor: isDark ? const Color(0xFF161B22) : Colors.white,
                  style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.white : Colors.black87),
                  items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r == 'All' ? 'All Roles' : r))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _directoryRoleFilter = val);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Action Toolbar Row 2: Buttons
        Row(
          children: [
            const Spacer(),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                side: const BorderSide(color: Color(0xFF6366F1)),
                minimumSize: Size.zero,
              ),
              onPressed: () => _openBulkTransferDialog(_selectedDirectoryIds.toList()),
              icon: const Icon(Icons.swap_horiz_rounded, size: 15, color: Color(0xFF6366F1)),
              label: Text("Bulk Transfer", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                side: const BorderSide(color: Color(0xFF10B981)),
                minimumSize: Size.zero,
              ),
              onPressed: _openBulkUploadDialog,
              icon: const Icon(Icons.upload_file_rounded, size: 15, color: Color(0xFF10B981)),
              label: Text("Bulk Upload", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                minimumSize: Size.zero,
              ),
              onPressed: _openAddWorkerDialog,
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 15),
              label: Text("+ Add Worker", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Directory Data Table
        Expanded(
          child: filteredWorkers.isEmpty
              ? Center(child: Text("No workers found in directory", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])))
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
                          DataColumn(label: Text("Worker Name")),
                          DataColumn(label: Text("Phone")),
                          DataColumn(label: Text("Role")),
                          DataColumn(label: Text("Daily Rate")),
                          DataColumn(label: Text("OT Rate")),
                          DataColumn(label: Text("Assigned Sites")),
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF6366F1),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(w.phone ?? 'N/A', style: GoogleFonts.poppins(fontSize: 11))),
                              DataCell(SkillBadge(skill: w.role)),
                              DataCell(Text("₹${w.monthlySalary.toStringAsFixed(0)}/day", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF10B981)))),
                              DataCell(Text("₹${w.overtimePayPerHour.toStringAsFixed(0)}/hr", style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF8B5CF6)))),
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF6366F1)),
                                      onPressed: () => _openDailyScheduleDialog(w),
                                      tooltip: "Daily Multi-Site Schedule",
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                      onPressed: () => _openEditWorkerDialog(w),
                                      tooltip: "Edit Worker",
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
  // MODAL DIALOG LAUNCHERS
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
              context.showToast("Payout processed successfully!", isSuccess: true);
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
