import 'dashboard_view.dart';
// ... existing imports ...

class TabletLandscape extends StatelessWidget {
  const TabletLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF101828) : const Color(0xFFF8FAFC), // Solid background
      // decoration: BoxDecoration(...) removed for flat design
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
