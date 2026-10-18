import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'offline_mode_service.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackService {
  FeedbackService({this.client, this.offlineMode});

  final OfflineModeService? offlineMode;

  final SupabaseClient? client;
  static const types = [
    'Bug Report',
    'Feature Request',
    'General Feedback',
    'Other',
  ];

  Future<void> submit({
    required String type,
    required String subject,
    required String message,
    required String email,
  }) async {
    // Direct callers without a widget scope still respect the saved setting.
    final preferences = offlineMode == null
        ? await SharedPreferences.getInstance()
        : null;
    void requireOnline() {
      offlineMode?.requireOnline();
      if (preferences?.getBool(OfflineModeService.storageKey) == true) {
        throw const OfflineModeException();
      }
    }

    requireOnline();
    final info = await PackageInfo.fromPlatform();
    // The user may have enabled Offline Mode while metadata was loading.
    requireOnline();
    // Insert only: feedback intentionally has no public SELECT policy.
    await (client ?? Supabase.instance.client)
        .from('feedback')
        .insert({
          'type': type,
          'subject': subject.trim(),
          'message': message.trim(),
          'contact_email': email.trim().isEmpty ? null : email.trim(),
          'app_version': '${info.version}+${info.buildNumber}',
          'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
        })
        .timeout(const Duration(seconds: 15));
    requireOnline();
  }
}
