import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DropdownOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  const DropdownOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });
}

class CustomDropdownSelector<T> extends StatelessWidget {
  final String label;
  final String placeholder;
  final IconData icon;
  final T selectedValue;
  final List<DropdownOption<T>> options;
  final ValueChanged<T> onSelected;
  final bool isSearchable;

  const CustomDropdownSelector({
    super.key,
    required this.label,
    required this.placeholder,
    required this.icon,
    required this.selectedValue,
    required this.options,
    required this.onSelected,
    this.isSearchable = false,
  });

  void _openSelectionModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DropdownSelectionSheet<T>(
        title: label,
        options: options,
        selectedValue: selectedValue,
        onSelected: (val) {
          Navigator.pop(ctx);
          onSelected(val);
        },
        isSearchable: isSearchable,
        isDark: isDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedOpt = options.firstWhere(
      (o) => o.value == selectedValue,
      orElse: () => options.isNotEmpty
          ? options.first
          : DropdownOption(value: selectedValue, label: placeholder),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _openSelectionModal(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF21262D) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selectedOpt.icon ?? icon,
                  size: 15,
                  color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedOpt.label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownSelectionSheet<T> extends StatefulWidget {
  final String title;
  final List<DropdownOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final bool isSearchable;
  final bool isDark;

  const _DropdownSelectionSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    required this.isSearchable,
    required this.isDark,
  });

  @override
  State<_DropdownSelectionSheet<T>> createState() => _DropdownSelectionSheetState<T>();
}

class _DropdownSelectionSheetState<T> extends State<_DropdownSelectionSheet<T>> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options.where((opt) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return opt.label.toLowerCase().contains(q) ||
          (opt.subtitle?.toLowerCase().contains(q) == true);
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 12,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SELECT ${widget.title.toUpperCase()}",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Search Box if searchable or more than 5 options
          if (widget.isSearchable || widget.options.length > 5) ...[
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
                ),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.poppins(fontSize: 12),
                decoration: InputDecoration(
                  hintText: "Search option...",
                  hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, size: 16),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Options List
          Flexible(
            child: filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        "No options found",
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, idx) {
                      final opt = filtered[idx];
                      final isSelected = opt.value == widget.selectedValue;

                      return InkWell(
                        onTap: () => widget.onSelected(opt.value),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6366F1).withValues(alpha: widget.isDark ? 0.2 : 0.1)
                                : (widget.isDark ? const Color(0xFF21262D) : const Color(0xFFF8FAFC)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF6366F1)
                                  : (widget.isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (opt.icon != null) ...[
                                Icon(
                                  opt.icon,
                                  size: 16,
                                  color: isSelected
                                      ? const Color(0xFF6366F1)
                                      : (widget.isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B)),
                                ),
                                const SizedBox(width: 10),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt.label,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected
                                            ? const Color(0xFF6366F1)
                                            : (widget.isDark ? Colors.white : const Color(0xFF0F172A)),
                                      ),
                                    ),
                                    if (opt.subtitle != null)
                                      Text(
                                        opt.subtitle!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: widget.isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF6366F1)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// [mod:2026-02-26T11:30:00+05:30]

// [upd:2026-05-04T11:30:00+05:30]

// [rev:2026-08-24T08:30:00+05:30]
