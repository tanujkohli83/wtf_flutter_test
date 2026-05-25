import 'package:flutter_test/flutter_test.dart';

import 'package:trainer_app/app/trainer_app.dart';

void main() {
  testWidgets('renders mock login and opens dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TrainerApp());

    expect(find.text('Trainer Portal'), findsOneWidget);
    expect(find.text('Login as Aarav'), findsOneWidget);

    await tester.tap(find.text('Login as Aarav'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Members'), findsOneWidget);
    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);

    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();

    expect(find.text('Trainer requests'), findsOneWidget);
    expect(find.text('Kabir Shah'), findsOneWidget);
    expect(find.text('Conflict'), findsOneWidget);
    expect(find.text('Approve'), findsWidgets);
    expect(find.text('Decline'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sessions'));
    await tester.pumpAndSettle();

    expect(find.text('Completed sessions'), findsOneWidget);
    expect(find.text('Maya Rao'), findsOneWidget);
    expect(find.text('60m'), findsOneWidget);
    expect(
      find.text('Strong form on squats. Increase deadlift load next session.'),
      findsOneWidget,
    );
  });
}
