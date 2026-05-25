import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guru_app/app/app.dart';

void main() {
  testWidgets('Dashboard connects to profile setup', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.tap(find.byTooltip('Set up profile'));
    await tester.pumpAndSettle();

    expect(find.text('Set up profile'), findsOneWidget);
    expect(find.text('DK'), findsNWidgets(2));
  });

  testWidgets('Dashboard connects to chat list and chat screen', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.tap(find.text('Chat with Trainer'));
    await tester.pumpAndSettle();

    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Aarav Sharma'), findsOneWidget);

    await tester.tap(find.text('Aarav Sharma'));
    await tester.pumpAndSettle();

    expect(
      find.text('No messages yet. Start the conversation.'),
      findsOneWidget,
    );
    expect(find.text('On my way'), findsOneWidget);
  });

  testWidgets('Dashboard connects to appointment scheduling', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.tap(find.text('Schedule Call'));
    await tester.pumpAndSettle();

    expect(find.text('Pick a time'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('9:00 AM'), findsOneWidget);

    expect(find.text('Request Appointment'), findsOneWidget);
  });

  testWidgets('Appointment note is limited and request can be sent', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.tap(find.text('Schedule Call'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10:30 AM'));
    await tester.enterText(
      find.byType(TextField),
      'Focus on shoulder mobility.',
    );
    await tester.tap(find.text('Request Appointment'));
    await tester.pump();

    expect(find.text('Requested 10:30 AM appointment'), findsOneWidget);
    expect(find.text('113 characters left'), findsOneWidget);
  });

  testWidgets('Dashboard connects to session history', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.tap(find.text('My Sessions'));
    await tester.pumpAndSettle();

    expect(find.text('Session History'), findsOneWidget);
    expect(find.text('Completed sessions'), findsOneWidget);
    expect(find.text('Upper Body Strength'), findsOneWidget);
    expect(find.text('45 min'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(
      find.text('Strong pressing today. Keep shoulders packed on rows.'),
      findsOneWidget,
    );
  });

  testWidgets('Session history sorts cards by rating', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.tap(find.text('My Sessions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Newest first'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Highest rating').last);
    await tester.pumpAndSettle();

    final cardioTop = tester.getTopLeft(find.text('Cardio Conditioning'));
    final strengthTop = tester.getTopLeft(find.text('Upper Body Strength'));

    expect(cardioTop.dy, lessThan(strengthTop.dy));
  });

  testWidgets('Chat screen shows empty realtime state', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.tap(find.text('Chat with Trainer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aarav Sharma'));
    await tester.pumpAndSettle();

    expect(
      find.text('No messages yet. Start the conversation.'),
      findsOneWidget,
    );
    expect(find.text('On my way'), findsOneWidget);
    expect(find.byTooltip('Send message'), findsOneWidget);
  });
}
