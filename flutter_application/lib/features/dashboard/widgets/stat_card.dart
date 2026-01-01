import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';

class StatCard extends StatelessWidget {
  final DashboardStat stat;

  const StatCard({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    // For smaller mobile screens, we might want a CompactStatCard, 
    // but this design fits responsive grids well.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          stat.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            // color: const Color(0xFF6B7280), // Let theme handle color
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: stat.iconBgColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          stat.icon,
                          color: stat.iconBgColor,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        stat.value,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (stat.total.isNotEmpty)
                        Text(
                          ' / ${stat.total}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        stat.percentageChange,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: stat.isPositiveChange 
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'vs last week',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
