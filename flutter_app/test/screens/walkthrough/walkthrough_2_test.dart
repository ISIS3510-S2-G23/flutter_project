import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecosphere/views/walkthrough/walkthrough_2.dart';

void main() {
  testWidgets('Walkthrough2 renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Walkthrough2(),
      ),
    );

    expect(find.text('Recycling has never been easier'), findsOneWidget);
    expect(
        find.text(
            'Find nearby recycling points,  complete challenges, earn rewards and connect with a committed community.'),
        findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.arrow_circle_right_outlined), findsOneWidget);
  });
}
