import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moose_time/screens/results_screen.dart';
import 'package:moose_time/screens/feedback_screen.dart';
import 'package:moose_time/services/result_export_service.dart';

class FakeExporter extends ResultExportService {
  String? action;
  bool fail = false;
  @override
  Future<Uint8List> capturePng(GlobalKey key) async {
    expect(
      key.currentContext!.findRenderObject(),
      isA<RenderRepaintBoundary>(),
    );
    return Uint8List.fromList([137, 80, 78, 71]);
  }

  @override
  Future<String?> save(Uint8List png, String name, Rect origin) async {
    action = 'save';
    if (fail) throw Exception('Unavailable');
    expect(name, '2026-10-13_Airland-Basic_ZuluConversion+4.png');
    return 'Result image saved.';
  }

  @override
  Future<void> copy(Uint8List png) async {
    action = 'copy';
  }

  @override
  Future<void> share(Uint8List png, String name, Rect origin) async {
    action = 'share';
  }
}

void main() {
  Future<void> show(
    WidgetTester tester,
    String mode, {
    ResultExportService? exporter,
    double height = 1800,
  }) async {
    await tester.binding.setSurfaceSize(Size(430, height));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: ResultsScreen(
          mode: mode,
          zuluTime: DateTime.utc(2026, 10, 13, 12),
          zuluConstant: 4,
          exportService: exporter,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> menu(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip('Results options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    if (label == 'Export result') {
      // The header spinner remains active while the export sheet is open.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    } else {
      await tester.pumpAndSettle();
    }
  }

  testWidgets(
    'Visibility options match every mode and Show All restores hidden rows',
    (tester) async {
      for (final mode in [
        'Airland Basic',
        'Airdrop Basic',
        'Airland Augmented',
        'Airdrop Augmented',
        'Alpha Alert',
        'Bravo Alert',
      ]) {
        await show(tester, mode);
        await menu(tester, 'Customize visible times');
        final checkboxes = tester
            .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
            .map((checkbox) => (checkbox.title! as Text).data)
            .toList();
        expect(checkboxes.contains('3 Stops Left'), mode.contains('Augmented'));
        expect(checkboxes.contains('2 AC for AR'), mode.contains('Augmented'));
        expect(checkboxes.contains('Takeoff'), !mode.contains('Alert'));
        expect(checkboxes.contains('Burnout'), mode.contains('Alert'));
        await tester.tap(find.widgetWithText(CheckboxListTile, 'Last Drink'));
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(find.text('Last Drink'), findsNothing);
        await menu(tester, 'Customize visible times');
        await tester.tap(find.text('Show All'));
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(find.text('Last Drink'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'Exports dispatch save, copy and share; errors remain recoverable',
    (tester) async {
      final exporter = FakeExporter();
      await show(tester, 'Airland Basic', exporter: exporter);
      for (final entry in {
        'Save as Image': 'save',
        'Copy Image to Clipboard': 'copy',
        'Share': 'share',
      }.entries) {
        await menu(tester, 'Export result');
        await tester.tap(find.text(entry.key));
        await tester.pumpAndSettle();
        expect(exporter.action, entry.value);
      }
      exporter.fail = true;
      await menu(tester, 'Export result');
      await tester.tap(find.text('Save as Image'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Could not export the result:'),
        findsOneWidget,
      );
      expect(find.byTooltip('Results options'), findsOneWidget);
      await menu(tester, 'Feedback & Support');
      expect(find.byType(FeedbackScreen), findsOneWidget);
    },
  );

  testWidgets(
    'PNG captures full scroll content without Results controls or bottom navigation',
    (tester) async {
      await show(tester, 'Airland Augmented', height: 600);
      final boundaryFinder = find
          .ancestor(
            of: find.text('Julian Day'),
            matching: find.byType(RepaintBoundary),
          )
          .first;
      final boundaryWidget = tester.widget<RepaintBoundary>(boundaryFinder);
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        boundaryFinder,
      );
      expect(boundary.size.height, greaterThan(600));
      expect(
        find.descendant(
          of: boundaryFinder,
          matching: find.byType(PopupMenuButton<String>),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: boundaryFinder,
          matching: find.byType(NavigationBar),
        ),
        findsNothing,
      );
      final bytes = await tester.runAsync(
        () =>
            ResultExportService().capturePng(boundaryWidget.key! as GlobalKey),
      );
      expect(bytes!.take(8).toList(), [137, 80, 78, 71, 13, 10, 26, 10]);
      await tester.runAsync(() async {
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        expect(frame.image.height, (boundary.size.height * 2).ceil());
        frame.image.dispose();
        codec.dispose();
      });
    },
  );
}
