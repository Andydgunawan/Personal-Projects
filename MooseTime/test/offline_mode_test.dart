import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moose_time/main.dart';
import 'package:moose_time/screens/announcements_screen.dart';
import 'package:moose_time/screens/feedback_screen.dart';
import 'package:moose_time/services/announcement_service.dart';
import 'package:moose_time/services/feedback_service.dart';
import 'package:moose_time/services/legal_agreement_service.dart';
import 'package:moose_time/services/offline_mode_service.dart';
import 'package:moose_time/services/theme_service.dart';

List<Map<String, dynamic>> rows(String title) => [
  {
    'id': 1,
    'title': title,
    'body': 'Body',
    'created_at': '2026-10-13T12:00:00Z',
  },
];

class RecordingFeedbackService extends FeedbackService {
  RecordingFeedbackService(OfflineModeService settings)
    : super(offlineMode: settings);
  int calls = 0;

  @override
  Future<void> submit({
    required String type,
    required String subject,
    required String message,
    required String email,
  }) async {
    offlineMode!.requireOnline();
    calls++;
  }
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
    'Setting persists and HTTP transport blocks all sends until re-enabled',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final settings = OfflineModeService(prefs);
      addTearDown(settings.dispose);
      var sends = 0;
      final client = OfflineHttpClient(
        settings,
        inner: MockClient((request) async {
          sends++;
          return http.Response('{}', 200);
        }),
      );
      addTearDown(client.close);
      await client.get(Uri.parse('https://example.test/'));
      expect(sends, 1);
      final save = settings.setOfflineMode(true);
      // Blocking takes effect before persistence completes.
      expect(settings.isOfflineMode, isTrue);
      await expectLater(
        client.get(Uri.parse('https://example.test/')),
        throwsA(isA<OfflineModeException>()),
      );
      await save;
      final reopened = OfflineModeService(prefs);
      addTearDown(reopened.dispose);
      expect(reopened.isOfflineMode, isTrue);
      expect(prefs.getBool('offline_mode'), isTrue);
      expect(sends, 1);
      await settings.setOfflineMode(false);
      await client.get(Uri.parse('https://example.test/'));
      expect(sends, 2);
    },
  );

  test('Announcements preserve cache/read IDs and block startup and manual refresh offline', () async {
    final prefs = await SharedPreferences.getInstance();
    var fetches = 0;
    final service = AnnouncementService(
      prefs,
      fetchRows: () async {
        fetches++;
        return rows('Cached');
      },
    );
    addTearDown(service.dispose);
    await service.refresh();
    await service.markAsRead('1');
    await service.offlineMode.setOfflineMode(true);
    await service.refresh();
    await service.refresh();
    expect(fetches, 1);
    expect(service.announcements.single.title, 'Cached');
    expect(service.isRead('1'), isTrue);
    final reopened = AnnouncementService(
      prefs,
      fetchRows: () async {
        fetches++;
        return rows('New');
      },
    );
    addTearDown(reopened.dispose);
    expect(reopened.offlineMode.isOfflineMode, isTrue);
    // Same guarded entry point used by main.dart and screen-open callbacks.
    await reopened.refresh();
    expect(fetches, 1);
    expect(reopened.isRead('1'), isTrue);
    await reopened.offlineMode.setOfflineMode(false);
    await reopened.refresh();
    expect(fetches, 2);
    expect(reopened.isRead('1'), isTrue);
  });

  test('An old announcement request cannot overwrite a newer list or leave loading stuck', () async {
    final prefs = await SharedPreferences.getInstance();
    final pending = Completer<List<Map<String, dynamic>>>();
    var fetches = 0;
    final service = AnnouncementService(
      prefs,
      fetchRows: () {
        fetches++;
        return fetches == 1 ? pending.future : Future.value(rows('New'));
      },
    );
    addTearDown(service.dispose);
    final oldRequest = service.refresh();
    expect(service.isLoading, isTrue);
    await service.offlineMode.setOfflineMode(true);
    expect(service.isLoading, isFalse);
    await service.offlineMode.setOfflineMode(false);
    await service.refresh();
    pending.complete(rows('Stale'));
    await oldRequest;
    expect(service.announcements.single.title, 'New');
    expect(service.isLoading, isFalse);
    expect(service.errorMessage, isNull);
  });

  test('Feedback service blocks before transport, preserves schema and resumes online', () async {
    final prefs = await SharedPreferences.getInstance();
    final settings = OfflineModeService(prefs);
    addTearDown(settings.dispose);
    var sends = 0;
    final transport = MockClient((request) async {
      sends++;
      expect(request.url.path, '/rest/v1/feedback');
      expect(request.method, 'POST');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['subject'], 'Subject');
      expect(body['contact_email'], isNull);
      expect(body['app_version'], '1.0.0+1');
      return http.Response('', 201, request: request);
    });
    final client = SupabaseClient(
      'https://example.test',
      'test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: transport,
    );
    addTearDown(client.dispose);
    addTearDown(transport.close);
    final service = FeedbackService(client: client, offlineMode: settings);
    Future<void> submit(FeedbackService target) => target.submit(
      type: 'Bug Report',
      subject: ' Subject ',
      message: 'Message',
      email: '',
    );
    await submit(service);
    expect(sends, 1);
    await settings.setOfflineMode(true);
    await expectLater(submit(service), throwsA(isA<OfflineModeException>()));
    // No scope and no explicitly supplied settings: persisted mode still wins.
    await expectLater(
      submit(FeedbackService(client: client)),
      throwsA(isA<OfflineModeException>()),
    );
    expect(sends, 1);
    await settings.setOfflineMode(false);
    await submit(service);
    expect(sends, 2);
  });

  test('Feedback checks again after metadata awaits and handles a request already sent', () async {
    final prefs = await SharedPreferences.getInstance();
    final settings = OfflineModeService(prefs);
    addTearDown(settings.dispose);
    var sends = 0;
    final started = Completer<void>();
    final response = Completer<http.Response>();
    final transport = MockClient((request) async {
      sends++;
      started.complete();
      final reply = await response.future;
      return http.Response(reply.body, reply.statusCode, request: request);
    });
    final client = SupabaseClient(
      'https://example.test',
      'test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: transport,
    );
    addTearDown(client.dispose);
    addTearDown(transport.close);
    final service = FeedbackService(client: client, offlineMode: settings);
    Future<void> submit() => service.submit(
      type: 'Bug Report',
      subject: 'Subject',
      message: 'Message',
      email: '',
    );
    final beforeMetadata = submit();
    final blocked = expectLater(
      beforeMetadata,
      throwsA(isA<OfflineModeException>()),
    );
    await settings.setOfflineMode(true);
    await blocked;
    expect(sends, 0);
    await settings.setOfflineMode(false);
    final alreadySent = submit();
    final interrupted = expectLater(
      alreadySent,
      throwsA(isA<OfflineModeException>()),
    );
    await started.future;
    await settings.setOfflineMode(true);
    response.complete(http.Response('', 201));
    await interrupted;
    expect(sends, 1);
  });

  testWidgets(
    'Announcements opening/pull-to-refresh stays offline; button restores fetching',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'offline_mode': true,
        'read_announcement_ids': ['1'],
      });
      var fetches = 0;
      final service = AnnouncementService(
        await SharedPreferences.getInstance(),
        fetchRows: () async {
          fetches++;
          return rows('Announcement');
        },
      );
      addTearDown(service.dispose);
      await tester.pumpWidget(
        MaterialApp(home: AnnouncementsScreen(service: service)),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Announcements are unavailable'),
        findsOneWidget,
      );
      expect(fetches, 0);
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pumpAndSettle();
      expect(fetches, 0);
      expect(service.isRead('1'), isTrue);
      await tester.tap(find.text('Turn Off Offline Mode'));
      await tester.pumpAndSettle();
      expect(fetches, 1);
      expect(find.text('Announcement'), findsOneWidget);
      expect(service.isRead('1'), isTrue);
    },
  );

  testWidgets(
    'Feedback hides all controls offline and restores the draft after re-enabling',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final settings = OfflineModeService(
        await SharedPreferences.getInstance(),
      );
      addTearDown(settings.dispose);
      final service = RecordingFeedbackService(settings);
      await tester.pumpWidget(
        OfflineModeScope(
          service: settings,
          child: MaterialApp(home: FeedbackScreen(service: service)),
        ),
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bug Report').last);
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'My subject');
      await tester.enterText(fields.at(1), 'Keep my message');
      await tester.enterText(fields.at(2), 'me@example.test');
      await settings.setOfflineMode(true);
      await tester.pumpAndSettle();
      expect(find.textContaining('Feedback is unavailable'), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      expect(find.text('Submit Feedback'), findsNothing);
      expect(service.calls, 0);
      await tester.tap(find.text('Turn Off Offline Mode'));
      await tester.pumpAndSettle();
      expect(settings.isOfflineMode, isFalse);
      expect(find.text('Keep my message'), findsOneWidget);
      expect(find.text('My subject'), findsOneWidget);
      expect(find.text('me@example.test'), findsOneWidget);
      await tester.tap(find.text('Submit Feedback'));
      await tester.pumpAndSettle();
      expect(service.calls, 1);
      expect(find.text('Keep my message'), findsNothing);
    },
  );

  testWidgets(
    'Persisted offline setting precedes Dark mode and calculator state survives toggling',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({'offline_mode': true});
      final prefs = await SharedPreferences.getInstance();
      final legal = LegalAgreementService(prefs);
      await legal.acceptCurrentVersion();
      var fetches = 0;
      final announcements = AnnouncementService(
        prefs,
        fetchRows: () async {
          fetches++;
          return [];
        },
      );
      final theme = ThemeService(prefs);
      addTearDown(announcements.dispose);
      addTearDown(theme.dispose);
      await tester.pumpWidget(
        MooseTimeApp(
          announcementService: announcements,
          legalService: legal,
          themeService: theme,
        ),
      );
      await tester.pumpAndSettle();
      expect(fetches, 0);
      await tester.enterText(find.byType(TextField).first, '1234');
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Offline Mode')).dy,
        lessThan(tester.getTopLeft(find.text('Dark mode')).dy),
      );
      final toggle = find.byKey(const ValueKey('offline-mode-switch'));
      expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(prefs.getBool('offline_mode'), isFalse);
      await tester.tap(find.text('Calculator'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byType(TextField).first)
            .controller!
            .text
            .replaceAll(':', ''),
        '1234',
      );
    },
  );
}
