import 'package:flutter/material.dart';

import 'disclaimer_screen.dart';
import 'information_screen.dart';

class AboutMooseTimeScreen extends StatelessWidget {
  const AboutMooseTimeScreen({super.key});

  static const _navy = Color(0xFF0A2B5A);
  static const _features = [
    'Multiple calculator modes',
    'Zulu and Local time display',
    'Julian Day support',
    'Duty-limit calculations',
    'Customizable result displays',
    'Exportable result tables',
    'In-app announcements',
    'Feedback and support',
  ];

  @override
  Widget build(BuildContext context) => InformationScreen(
    title: 'About MooseTime',
    paragraphs: const [
      'MooseTime is a mission and duty-time planning calculator designed to help aircrew quickly work through common scheduling calculations.',
      'The app supports Airland Basic, Airland Augmented, Airdrop Basic, Airdrop Augmented, Alpha Alert, and Bravo Alert calculations.',
      'MooseTime uses Zulu time as the primary time reference, with local-time conversion provided for convenience.',
      'The goal of MooseTime is to make mission-related time calculations faster, easier to read, and available in one place without relying on manual math.',
    ],
    footer: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Key Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _navy,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (final feature in _features)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: Color(0xFF1976D2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 16, color: _navy),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Material(
          color: const Color(0xFFEAF3FA),
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: const Icon(Icons.info_outline, color: _navy),
            title: const Text(
              'Important usage information',
              style: TextStyle(color: _navy, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'See Disclaimer',
              style: TextStyle(color: Color(0xFF1976D2)),
            ),
            trailing: const Icon(Icons.chevron_right, color: _navy),
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (context) => const DisclaimerScreen()),
            ),
          ),
        ),
      ],
    ),
  );
}
