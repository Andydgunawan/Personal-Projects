import '../services/theme_service.dart';
import '../services/offline_mode_service.dart';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'about_moosetime_screen.dart';
import 'about_creator_screen.dart';
import 'feedback_screen.dart';
import 'support_moosetime_screen.dart';
import 'terms_screen.dart';
import 'privacy_screen.dart';
import 'disclaimer_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});
  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String? _version;
  bool _versionFailed = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = info.version);
    } catch (_) {
      if (mounted) setState(() => _versionFailed = true);
    }
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
    child: Text(
      text,
      style: TextStyle(
        color: appTextColor(context, 0xFF0A2B5A),
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
  );

  Widget _entry(String title, IconData icon, Widget page) => Card(
    color: appColor(context, 0xFFFFFFFF),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: ListTile(
      leading: Icon(icon, color: appColor(context, 0xFF0A2B5A)),
      title: Text(
        title,
        style: TextStyle(color: appTextColor(context, 0xFF0A2B5A)),
      ),
      trailing: Icon(Icons.chevron_right, color: appColor(context, 0xFF0A2B5A)),
      onTap: () =>
          Navigator.of(context)
              .push<void>(MaterialPageRoute(builder: (context) => page)),
    ),
  );

  Widget _offlineSetting(BuildContext context) {
    final service = OfflineModeScope.maybeOf(context);
    return Card(
      color: appColor(context, 0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SwitchListTile(
        key: const ValueKey('offline-mode-switch'),
        secondary: Icon(Icons.cloud_off, color: appColor(context, 0xFF0A2B5A)),
        title: const Text('Offline Mode'),
        subtitle: const Text(
          'Disables online features such as announcements and feedback. Calculator functionality remains available.',
        ),
        value: service?.isOfflineMode ?? false,
        onChanged: service == null || service.isSaving
            ? null
            : (value) async {
                try {
                  await service.setOfflineMode(value);
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not save Offline Mode. Please try again.',
                      ),
                    ),
                  );
                }
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: appColor(context, 0xFFF5F8FC),
    appBar: AppBar(
      title: Text('More'),
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? darkHeaderStart
          : const Color(0xFF0A2B5A),
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _heading('APP'),
        _offlineSetting(context),
        Card(
          color: appColor(context, 0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: SwitchListTile(
            secondary: Icon(
              Icons.dark_mode_outlined,
              color: appColor(context, 0xFF0A2B5A),
            ),
            title: const Text('Dark mode'),
            value: ThemeScope.maybeOf(context)?.isDark ?? false,
            onChanged: ThemeScope.maybeOf(context) == null
                ? null
                : (value) async {
                    try {
                      await ThemeScope.maybeOf(context)!.setDark(value);
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Could not save appearance. Please try again.',
                          ),
                        ),
                      );
                    }
                  },
          ),
        ),
        _entry('About MooseTime', Icons.info_outline, AboutMooseTimeScreen()),
        _entry('About the Creator', Icons.person_outline, AboutCreatorScreen()),
        _heading('SUPPORT'),
        _entry('Feedback & Support', Icons.support_agent, FeedbackScreen()),
        _entry(
          'Support MooseTime',
          Icons.favorite_outline,
          SupportMooseTimeScreen(),
        ),
        _heading('LEGAL'),
        _entry('Terms of Use', Icons.description_outlined, TermsScreen()),
        _entry('Privacy Policy', Icons.privacy_tip_outlined, PrivacyScreen()),
        _entry('Disclaimer', Icons.rule, DisclaimerScreen()),
        SizedBox(height: 28),
        Text(
          'MooseTime',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: appTextColor(context, 0xFF0A2B5A),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          _version != null
              ? 'Version $_version'
              : _versionFailed
              ? 'Version unavailable'
              : 'Loading version...',
          textAlign: TextAlign.center,
          style: TextStyle(color: appTextColor(context, 0xFF6C819B)),
        ),
        SizedBox(height: 16),
      ],
    ),
  );
}
