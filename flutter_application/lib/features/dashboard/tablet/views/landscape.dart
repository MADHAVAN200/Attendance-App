import 'dashboard_view.dart';
// ... existing imports ...

class TabletLandscape extends StatelessWidget {
  const TabletLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF334155)]
              : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            const AppSidebar(),
            Expanded(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: const CustomAppBar(showDrawerButton: false),
                body: const DashboardView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
