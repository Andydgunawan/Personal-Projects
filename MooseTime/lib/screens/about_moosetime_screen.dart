import '../services/theme_service.dart';

import 'package:flutter/material.dart';

import 'disclaimer_screen.dart';
import 'information_screen.dart';

class AboutMooseTimeScreen extends StatelessWidget {
  const AboutMooseTimeScreen({super.key});

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
    paragraphs: [
      'MooseTime is a mission and duty-time planning calculator designed to help aircrew quickly work through common scheduling calculations.',
      'The app supports Airland Basic, Airland Augmented, Airdrop Basic, Airdrop Augmented, Alpha Alert, and Bravo Alert calculations.',
      'MooseTime uses Zulu time as the primary time reference, with local-time conversion provided for convenience.',
      'The goal of MooseTime is to make mission-related time calculations faster, easier to read, and available in one place without relying on manual math.',
    ],
    footer: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Key Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: appColor(context, 0xFF0A2B5A),
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appColor(context, 0xFFFFFFFF),
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
                      Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: appColor(context, 0xFF1976D2),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 16,
                            color: appColor(context, 0xFF0A2B5A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 24),
        Material(
          color: appColor(context, 0xFFEAF3FA),
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Icon(
              Icons.info_outline,
              color: appColor(context, 0xFF0A2B5A),
            ),
            title: Text(
              'Important usage information',
              style: TextStyle(
                color: appColor(context, 0xFF0A2B5A),
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'See Disclaimer',
              style: TextStyle(color: appColor(context, 0xFF1976D2)),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: appColor(context, 0xFF0A2B5A),
            ),
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (context) => DisclaimerScreen()),
            ),
          ),
        ),
      ],
    ),
  );
}
