import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/main.dart';

void main() {
  testWidgets('Attendance app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AttendanceApp());

    // Verify that the app loads
    expect(find.byType(AttendanceApp), findsOneWidget);
  });
}
