import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';

class LiveActivityCard extends StatelessWidget {
  final List<ActivityItem> activities;

  const LiveActivityCard({super.key, required this.activities});

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981), // Green dot
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...activities.map((activity) => _buildActivityItem(context, activity)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).dividerColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'View Full Feed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityItem item) {
    Color statusColor = const Color(0xFF10B981); // Green
    if (item.status.contains('Late')) statusColor = const Color(0xFFF59E0B);
    if (item.status.contains('Leave')) statusColor = const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFEEF2FF), // Maybe adjust for dark mode? OK for now
            child: Text(
              item.name[0],
              style: const TextStyle(
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${item.role} • ${item.status}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.time,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnomaliesCard extends StatelessWidget {
  final List<AnomalyItem> anomalies;

  const AnomaliesCard({super.key, required this.anomalies});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warningBg = isDark ? const Color(0xFF78350F).withOpacity(0.3) : const Color(0xFFFFFBEB);
    final warningBorder = isDark ? const Color(0xFF92400E).withOpacity(0.5) : const Color(0xFFFEF3C7);
    final warningText = isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E);

    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Text(
                'Anomalies',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...anomalies.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: warningBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: warningBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD97706),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: warningText,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
