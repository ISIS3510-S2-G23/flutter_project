import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecosphere/views/walkthrough/walkthrough_1.dart';

void main() {
  testWidgets('Walkthrough1 renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Walkthrough1()),
    );

    expect(find.text('Welcome to EcoSphere!'), findsOneWidget);
    expect(
        find.text(
            'Discover a new way to recycle, share, and learn about sustainability in your community.'),
        findsOneWidget);
    expect(find.byIcon(Icons.arrow_circle_right_outlined), findsOneWidget);
  });
}
