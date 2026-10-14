import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moose_time/screens/legal_gate.dart';
import 'package:moose_time/screens/legal_agreement_screen.dart';
import 'package:moose_time/screens/root_screen.dart';
import 'package:moose_time/services/announcement_service.dart';
import 'package:moose_time/services/legal_agreement_service.dart';

class FailingLegalService extends LegalAgreementService {
  FailingLegalService(super.preferences);
  @override
  Future<void> acceptCurrentVersion() async =>
      throw StateError('Storage failure');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'MooseTime',
      packageName: 'moosetime',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  test(
    'Missing and outdated versions require agreement; acceptance persists',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LegalAgreementService(prefs);
      expect(service.hasAcceptedCurrentVersion, isFalse);
      await prefs.setInt(
        LegalAgreementService.acceptedVersionKey,
        currentLegalVersion - 1,
      );
      expect(service.hasAcceptedCurrentVersion, isFalse);
      await service.acceptCurrentVersion();
      expect(
        LegalAgreementService(await SharedPreferences.getInstance())
            .hasAcceptedCurrentVersion,
        isTrue,
      );
      await service.resetForDevelopment();
      expect(service.hasAcceptedCurrentVersion, isFalse);
    },
  );

  testWidgets(
    'Documents preserve checkbox; only Continue saves and enters root; relaunch bypasses agreement',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final prefs = await SharedPreferences.getInstance();
      final announcements = AnnouncementService(
        prefs,
        fetchRows: () async => [],
      );
      addTearDown(announcements.dispose);
      Widget app() => MaterialApp(
        home: LegalGate(
          legalService: LegalAgreementService(prefs),
          announcementService: announcements,
        ),
      );
      await tester.pumpWidget(app());
      expect(find.byType(RootScreen), findsNothing);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      expect(prefs.getInt(LegalAgreementService.acceptedVersionKey), isNull);
      for (final title in ['Terms of Use', 'Privacy Policy', 'Disclaimer']) {
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
          isTrue,
        );
      }
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.byType(RootScreen), findsOneWidget);
      expect(
        prefs.getInt(LegalAgreementService.acceptedVersionKey),
        currentLegalVersion,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.byType(LegalAgreementScreen), findsNothing);
      expect(find.byType(RootScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Failed save keeps agreement visible and permits retry', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var accepted = false;
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MaterialApp(
        home: LegalAgreementScreen(
          service: FailingLegalService(prefs),
          onAccepted: () => accepted = true,
        ),
      ),
    );
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(accepted, isFalse);
    expect(prefs.getInt(LegalAgreementService.acceptedVersionKey), isNull);
    expect(
      find.text('Could not save your agreement. Please try again.'),
      findsOneWidget,
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
  });
}
