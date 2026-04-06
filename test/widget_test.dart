import 'package:flutter_test/flutter_test.dart';
import 'package:patient_management_system/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PatientManagementApp());
    expect(find.text('Vitalis Clinical'), findsOneWidget);
  });
}
