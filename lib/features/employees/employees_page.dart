import 'package:flutter/material.dart';
import 'package:flutter_application/features/employees/views/employees_mobile_portrait_view.dart';
import 'package:flutter_application/features/employees/views/employees_tablet_portrait_view.dart';

class EmployeesPage extends StatelessWidget {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const EmployeesMobileView();
        }
        return const EmployeesView();
      },
    );
  }
}

// [mod:2026-02-21T09:00:00+05:30]
