import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moose_time/screens/more_screen.dart';
import 'package:moose_time/services/theme_service.dart';
import 'package:moose_time/screens/root_screen.dart';
import 'package:moose_time/services/announcement_service.dart';

void main() {
  testWidgets('Changing appearance preserves calculator inputs', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final service = ThemeService(preferences);
    final announcements = AnnouncementService(
      preferences,
      fetchRows: () async => [],
    );
    addTearDown(service.dispose);
    addTearDown(announcements.dispose);
    await tester.pumpWidget(
      ThemeScope(
        service: service,
        child: AnimatedBuilder(
          animation: service,
          builder: (context, _) => MaterialApp(
            theme: ThemeData.light(),
            darkTheme: buildDarkTheme(),
            themeMode: service.isDark ? ThemeMode.dark : ThemeMode.light,
            home: RootScreen(announcementService: announcements),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).first, '1234');
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SwitchListTile, 'Dark mode'));
    await tester.pumpAndSettle();
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
    expect(
      Theme.of(tester.element(find.byType(TextField).first)).brightness,
      Brightness.dark,
    );
  });
  testWidgets('More switch changes palette and persists across launches', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final service = ThemeService(preferences);
    await tester.pumpWidget(
      ThemeScope(
        service: service,
        child: AnimatedBuilder(
          animation: service,
          builder: (context, _) => MaterialApp(
            theme: ThemeData.light(),
            darkTheme: buildDarkTheme(),
            themeMode: service.isDark ? ThemeMode.dark : ThemeMode.light,
            home: const MoreScreen(),
          ),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.text('Dark mode')).dy,
      lessThan(tester.getTopLeft(find.text('About MooseTime')).dy),
    );
    await tester.tap(find.widgetWithText(SwitchListTile, 'Dark mode'));
    await tester.pumpAndSettle();
    expect(service.isDark, isTrue);
    expect(ThemeService(preferences).isDark, isTrue);
    final context = tester.element(find.byType(MoreScreen));
    expect(appColor(context, 0xFFF5F8FC), darkBackground);
    expect(appColor(context, 0xFF0A2B5A), darkAccent);
    await tester.tap(find.widgetWithText(SwitchListTile, 'Dark mode'));
    await tester.pumpAndSettle();
    expect(ThemeService(preferences).isDark, isFalse);
    expect(appColor(context, 0xFFF5F8FC), const Color(0xFFF5F8FC));
  });
}
