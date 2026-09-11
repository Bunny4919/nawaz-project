import 'package:flutter_test/flutter_test.dart';
import 'package:nawaz/main.dart';

void main() {
  testWidgets('App loads LoginScreen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StudyApp());

    // Verify that the login screen title and sign in button are displayed.
    expect(find.text('Personal Study & Mock Test'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
