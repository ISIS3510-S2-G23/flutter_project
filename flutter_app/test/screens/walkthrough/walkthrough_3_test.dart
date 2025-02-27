import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecosphere/screens/walkthrough/walkthrough_3.dart';

void main() {
  testWidgets('Walkthrough3 renders correctly and navigates to Login',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Walkthrough3(),
        routes: {
          '/login': (context) => Scaffold(body: Text('Login')),
        },
      ),
    );

    expect(find.text('Join the community'), findsOneWidget);
    expect(
        find.text(
            'Create an account or log in to start your journey toward a more sustainable world!'),
        findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Walkthrough3 navigates to Signup', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Walkthrough3(),
        routes: {
          '/signup': (context) => Scaffold(body: Text('Signup')),
        },
      ),
    );

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Signup'), findsOneWidget);
  });
}
