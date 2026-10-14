import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moose_time/screens/home_screen.dart';
import 'package:moose_time/services/announcement_service.dart';

Future<List<Map<String, dynamic>>> sampleRows() async => [
  for (var id = 1; id <= 3; id++)
    {
      'id': id,
      'title': 'Announcement $id',
      'body': 'Body $id',
      'created_at': '2026-10-13T12:00:00Z',
    },
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Read IDs persist across service instances', () async {
    final service = AnnouncementService(
      await SharedPreferences.getInstance(),
      fetchRows: sampleRows,
    );
    await service.refresh();
    expect(service.unreadCount, 3);
    await service.markAsRead('1');
    await service.markAsRead('1');
    final reopened = AnnouncementService(
      await SharedPreferences.getInstance(),
      fetchRows: sampleRows,
    );
    await reopened.refresh();
    expect(reopened.unreadCount, 2);
    expect(reopened.isRead('1'), isTrue);
    service.dispose();
    reopened.dispose();
  });

  test(
    'Failed refresh preserves read IDs and last list; retry recovers',
    () async {
      var fail = false;
      final service = AnnouncementService(
        await SharedPreferences.getInstance(),
        fetchRows: () async {
          if (fail) throw Exception('Offline');
          return sampleRows();
        },
      );
      await service.refresh();
      await Future.wait([service.markAsRead('1'), service.markAsRead('2')]);
      fail = true;
      await service.refresh();
      expect(service.errorMessage, isNotNull);
      expect(service.unreadCount, 1);
      expect(service.isRead('1'), isTrue);
      expect(service.isRead('2'), isTrue);
      fail = false;
      await service.refresh();
      expect(service.errorMessage, isNull);
      expect(service.unreadCount, 1);
      service.dispose();
    },
  );

  testWidgets(
    'List preserves unread state; opening items updates and hides badge',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final service = AnnouncementService(
        await SharedPreferences.getInstance(),
        fetchRows: sampleRows,
      );
      await service.refresh();
      addTearDown(service.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(announcementService: service, onCalculated: (_) {}),
        ),
      );
      expect(find.byTooltip('Announcements (3 unread)'), findsOneWidget);
      await tester.tap(find.byTooltip('Announcements (3 unread)'));
      await tester.pumpAndSettle();
      expect(service.unreadCount, 3);
      expect(find.textContaining('Unread'), findsNWidgets(3));
      for (final announcement in service.announcements) {
        await tester.tap(find.text(announcement.title));
        await tester.pumpAndSettle();
        expect(find.text(announcement.body), findsOneWidget);
        expect(service.isRead(announcement.id), isTrue);
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
      }
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byTooltip('Announcements'), findsOneWidget);
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
