import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moose_time/screens/root_screen.dart';
import 'package:moose_time/screens/home_screen.dart';
import 'package:moose_time/screens/results_screen.dart';
import 'package:moose_time/services/announcement_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'MooseTime',
      packageName: 'moosetime',
      version: '1.2.3',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  testWidgets(
    'Tabs preserve inputs, show latest calculation, and reuse support pages',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final service = AnnouncementService(
        await SharedPreferences.getInstance(),
        fetchRows: () async => [],
      );
      addTearDown(service.dispose);
      await tester.pumpWidget(
        MaterialApp(home: RootScreen(announcementService: service)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
      await tester.tap(find.text('Results'));
      await tester.pumpAndSettle();
      expect(find.text('No calculation yet'), findsOneWidget);
      await tester.tap(find.text('Calculator'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '200');
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('Version 1.2.3'), findsOneWidget);
      expect(find.text('Feedback & Support'), findsOneWidget);
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();
      expect(find.textContaining('DRAFT'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calculator'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byType(TextField).first)
            .controller!
            .text
            .replaceAll(':', ''),
        '0200',
      );
      await tester.tap(find.text('Calculate'));
      await tester.pump();
      expect(find.text('Calculating...'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1,
      );
      expect(
        tester.widget<ResultsScreen>(find.byType(ResultsScreen)).zuluTime.hour,
        2,
      );
      expect(find.byTooltip('Back'), findsNothing);
      await tester.tap(find.text('Calculator'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '1530');
      await tester.tap(find.text('Calculate'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.byType(ResultsScreen), findsOneWidget);
      final latest = tester.widget<ResultsScreen>(find.byType(ResultsScreen));
      expect(latest.zuluTime.hour, 15);
      expect(latest.zuluTime.minute, 30);
      await tester.tap(find.text('Calculator'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '9999');
      await tester.tap(find.text('Calculate'));
      await tester.pump();
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
      expect(find.text('Calculating...'), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
