import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moose_time/screens/feedback_screen.dart';
import 'package:moose_time/services/feedback_service.dart';

class TestFeedbackService extends FeedbackService {
  int calls = 0;
  Completer<void> request = Completer<void>();
  @override
  Future<void> submit({
    required String type,
    required String subject,
    required String message,
    required String email,
  }) {
    calls++;
    return request.future;
  }
}

void main() {
  testWidgets(
    'Validation, double-submit prevention, failure preservation and successful reset',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final service = TestFeedbackService();
      await tester.pumpWidget(
        MaterialApp(home: FeedbackScreen(service: service)),
      );
      await tester.tap(find.text('Submit Feedback'));
      await tester.pump();
      expect(service.calls, 0);
      expect(find.text('This field is required.'), findsNWidgets(3));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bug Report').last);
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Test subject');
      await tester.enterText(fields.at(1), 'Keep this message');
      await tester.enterText(fields.at(2), 'invalid-email');
      await tester.tap(find.text('Submit Feedback'));
      await tester.pump();
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(service.calls, 0);
      await tester.enterText(fields.at(2), '');
      await tester.tap(find.text('Submit Feedback'));
      await tester.pump();
      expect(service.calls, 1);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      service.request.completeError(Exception('Offline'));
      await tester.pumpAndSettle();
      expect(find.text('Keep this message'), findsOneWidget);
      service.request = Completer<void>();
      await tester.tap(find.text('Submit Feedback'));
      await tester.pump();
      service.request.complete();
      await tester.pumpAndSettle();
      expect(service.calls, 2);
      expect(find.text('Keep this message'), findsNothing);
      expect(find.text('Test subject'), findsNothing);
      expect(
        find.text('Thank you! Your feedback was submitted.'),
        findsOneWidget,
      );
    },
  );
}
