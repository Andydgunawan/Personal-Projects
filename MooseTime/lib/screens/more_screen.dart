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
  static const navy = Color(0xFF0A2B5A);

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
      style: const TextStyle(
        color: navy,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
  );

  Widget _entry(String title, IconData icon, Widget page) => Card(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: ListTile(
      leading: Icon(icon, color: navy),
      title: Text(title, style: const TextStyle(color: navy)),
      trailing: const Icon(Icons.chevron_right, color: navy),
      onTap: () =>
          Navigator.of(context)
              .push<void>(MaterialPageRoute(builder: (context) => page)),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F8FC),
    appBar: AppBar(
      title: const Text('More'),
      automaticallyImplyLeading: false,
      backgroundColor: navy,
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _heading('APP'),
        _entry(
          'About MooseTime',
          Icons.info_outline,
          const AboutMooseTimeScreen(),
        ),
        _entry(
          'About the Creator',
          Icons.person_outline,
          const AboutCreatorScreen(),
        ),
        _heading('SUPPORT'),
        _entry(
          'Feedback & Support',
          Icons.support_agent,
          const FeedbackScreen(),
        ),
        _entry(
          'Support MooseTime',
          Icons.favorite_outline,
          const SupportMooseTimeScreen(),
        ),
        _heading('LEGAL'),
        _entry('Terms of Use', Icons.description_outlined, const TermsScreen()),
        _entry(
          'Privacy Policy',
          Icons.privacy_tip_outlined,
          const PrivacyScreen(),
        ),
        _entry('Disclaimer', Icons.rule, const DisclaimerScreen()),
        const SizedBox(height: 28),
        const Text(
          'MooseTime',
          textAlign: TextAlign.center,
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _version != null
              ? 'Version $_version'
              : _versionFailed
              ? 'Version unavailable'
              : 'Loading version...',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF6C819B)),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
