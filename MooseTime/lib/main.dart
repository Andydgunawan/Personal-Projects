import 'dart:async';

import 'services/theme_service.dart';
import 'services/offline_mode_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import 'screens/legal_gate.dart';
import 'services/legal_agreement_service.dart';
import 'services/in_app_purchase_service.dart';

import 'package:flutter/foundation.dart';

import 'services/announcement_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final offlineMode = OfflineModeService(preferences);
  await Supabase.initialize(
    url: 'https://npotmylpbbzloczodxuz.supabase.co',
    httpClient: OfflineHttpClient(offlineMode),
    // The supplied publishable key uses the requested anonKey parameter.
    // ignore: deprecated_member_use
    anonKey: 'sb_publishable_Ddi5Xp76qPjWY2vN0uRqNQ_Wo4dCWDI',
  );
  final legalService = LegalAgreementService(preferences);
  // Debug-only first-launch helper for terms and announcement read history.
  if (kDebugMode && const bool.fromEnvironment('RESET_LEGAL_AGREEMENT')) {
    await legalService.resetForDevelopment();
    final removed = await preferences.remove(AnnouncementService.storageKey);
    if (!removed) {
      throw StateError('Could not reset announcement read status.');
    }
  }
  final announcements = AnnouncementService(
    preferences,
    client: Supabase.instance.client,
    offlineMode: offlineMode,
  );
  // Listen early for unfinished mobile tips without blocking app startup.
  if (!offlineMode.isOfflineMode) {
    unawaited(InAppPurchaseService.instance.initialize());
  }
  // Start fetching without delaying the Calculator screen on network access.
  if (!offlineMode.isOfflineMode) unawaited(announcements.refresh());
  runApp(
    MooseTimeApp(
      announcementService: announcements,
      legalService: legalService,
      themeService: ThemeService(preferences),
    ),
  );
}

class MooseTimeApp extends StatelessWidget {
  const MooseTimeApp({
    super.key,
    required this.announcementService,
    required this.legalService,
    this.themeService,
  });

  final AnnouncementService announcementService;
  final ThemeService? themeService;
  final LegalAgreementService legalService;

  @override
  Widget build(BuildContext context) {
    final app = AnimatedBuilder(
      animation: themeService ?? const AlwaysStoppedAnimation<bool>(false),
      builder: (context, _) => MaterialApp(
        title: 'MooseTime',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        darkTheme: buildDarkTheme(),
        themeMode: themeService?.isDark == true
            ? ThemeMode.dark
            : ThemeMode.light,
        home: LegalGate(
          announcementService: announcementService,
          legalService: legalService,
        ),
      ),
    );
    return OfflineModeScope(
      service: announcementService.offlineMode,
      child: themeService == null
          ? app
          : ThemeScope(service: themeService!, child: app),
    );
  }
}
