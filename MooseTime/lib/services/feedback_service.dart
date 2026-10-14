import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackService {
  FeedbackService({this.client});

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
    final info = await PackageInfo.fromPlatform();
    // Insert only: feedback intentionally has no public SELECT policy.
    await (client ?? Supabase.instance.client).from('feedback').insert({
      'type': type,
      'subject': subject.trim(),
      'message': message.trim(),
      'contact_email': email.trim().isEmpty ? null : email.trim(),
      'app_version': '${info.version}+${info.buildNumber}',
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
    });
  }
}
