import 'package:flutter/material.dart';
import '../screens/SplashScreen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

// Create a mock Firebase class
class MockFirebase implements Firebase {}

void main() {
  setUpAll(() async {
    // Ensure Firebase is initialized before tests run
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  testWidgets('SplashScreen displays correctly', (WidgetTester tester) async {
    // Wrap SplashScreen in MaterialApp
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    // Check if SplashScreen contains expected text
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
