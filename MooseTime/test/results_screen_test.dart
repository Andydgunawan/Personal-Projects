import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moose_time/screens/results_screen.dart';

void main() {
  Future<void> showResults(WidgetTester tester, String mode) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: ResultsScreen(
          mode: mode,
          zuluTime: DateTime.utc(2026, 9, 22, 12),
          zuluConstant: 4,
          qualifyingLeg: true,
        ),
      ),
    );
  }

  testWidgets(
    'Basic flight modes omit augmented rows and show calculated times',
    (tester) async {
      for (final mode in ['Airland Basic', 'Airdrop Basic']) {
        await showResults(tester, mode);
        expect(find.text('3 Stops Left'), findsNothing);
        expect(find.text('2 AC for AR'), findsNothing);
        expect(find.text(mode), findsOneWidget);
        expect(
          find.text(mode == 'Airland Basic' ? '08:15' : '07:45'),
          findsOneWidget,
        );
        expect(find.text('12:00'), findsOneWidget);
        expect(find.text('-1'), findsWidgets);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('Augmented results include extra rows and next-day badges', (
    tester,
  ) async {
    await showResults(tester, 'Airland Augmented');
    expect(find.text('3 Stops Left'), findsOneWidget);
    expect(find.text('2 AC for AR'), findsOneWidget);
    expect(find.text('09:15'), findsWidgets);
    expect(find.text('+1'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Alert modes show burnout and reset instead of flight times', (
    tester,
  ) async {
    for (final mode in ['Alpha Alert', 'Bravo Alert']) {
      await showResults(tester, mode);
      expect(find.text('Burnout'), findsOneWidget);
      expect(find.text('Earliest Reset'), findsOneWidget);
      expect(find.text('Takeoff'), findsNothing);
      expect(find.text('+2'), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });
}
