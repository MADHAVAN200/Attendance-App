import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TabData {
  final String id;
  final String label;
  final int? count;

  const TabData({
    required this.id, 
    required this.label, 
    this.count,
  });
}

class CustomTabSwitcher extends StatelessWidget {
  final List<TabData> tabs;
  final String activeTab;
  final ValueChanged<String> onTabChanged;

  const CustomTabSwitcher({
    super.key,
    required this.tabs,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: tabs.map((tab) => _buildTab(tab)).toList(),
        ),
      ),
    );
  }

  Widget _buildTab(TabData tab) {
    final isActive = activeTab == tab.id;
    return GestureDetector(
      onTap: () => onTabChanged(tab.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive 
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))] 
              : [],
        ),
        child: Row(
          children: [
            Text(
              tab.label,
              style: GoogleFonts.inter(
                color: isActive ? Colors.indigo : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (tab.count != null && tab.count! > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444), // Red-500
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${tab.count}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
