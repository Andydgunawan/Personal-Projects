import '../services/theme_service.dart';

import 'package:flutter/material.dart';

import 'feedback_screen.dart';
import 'privacy_screen.dart';

// Update this date when revising the terms.
const termsLastUpdated = 'October 22, 2026';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  Widget _section(
    BuildContext context,
    String heading,
    String body, {
    String? linkLabel,
    Widget? linkPage,
  }) {
    final parts = linkLabel == null ? [body] : body.split(linkLabel);
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: TextStyle(
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.bold,
              color: appTextColor(context, 0xFF0A2B5A),
            ),
          ),
          SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: parts.first),
                for (final part in parts.skip(1)) ...[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(builder: (context) => linkPage!),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: appTextColor(context, 0xFF1976D2),
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        textStyle: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: appTextColor(context, 0xFF0A2B5A),
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                      child: Text(linkLabel!),
                    ),
                  ),
                  TextSpan(text: part),
                ],
              ],
            ),
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: appTextColor(context, 0xFF0A2B5A),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: appColor(context, 0xFFF5F8FC),
    appBar: AppBar(
      title: Text('Terms of Use'),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? darkHeaderStart
          : const Color(0xFF0A2B5A),
      foregroundColor: Colors.white,
    ),
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Last updated: $termsLastUpdated',
                  style: TextStyle(
                    fontSize: 14,
                    color: appTextColor(context, 0xFF6C819B),
                  ),
                ),
                _section(
                  context,
                  "1. Purpose of MooseTime",
                  "MooseTime is a mission and duty-time planning tool designed to help users perform and organize common time calculations more efficiently.\n\nMooseTime is intended as a convenience and planning aid only. It is not an official source of operational guidance, regulations, policies, or procedures.",
                ),
                _section(
                  context,
                  "2. No Official Affiliation",
                  "MooseTime is an independently developed application.\n\nMooseTime is not officially affiliated with, endorsed by, sponsored by, approved by, or operated by the United States Air Force, the United States Department of Defense, or any other government agency or military organization.\n\nAny references to military terminology, procedures, calculations, regulations, or publications are provided solely for context and to support the app’s functionality. Such references do not imply official approval, validation, endorsement, or affiliation",
                ),
                _section(
                  context,
                  "3. User Responsibility",
                  "You are responsible for verifying all calculations and information produced by MooseTime against all applicable official publications, regulations, policies, procedures, and unit guidance, including any current Air Force or C-17-specific guidance that applies to your operation.\n\nYou should not use MooseTime as the sole basis for operational, mission, safety, legal, medical, or regulatory decisions.\n\nIf there is any conflict between information shown by MooseTime and an official source, the official source takes precedence.",
                ),
                _section(
                  context,
                  "4. Accuracy of Calculations",
                  "Every reasonable effort is made to provide accurate calculations and functionality. However, MooseTime may contain errors, bugs, outdated information, incorrect assumptions, or other inaccuracies.\n\nThe developer does not guarantee that:\n- calculations will always be accurate;\n- the app will reflect the most current rules or regulations;\n- the app will be free from errors or interruptions; or\n- every feature will work correctly on every device.\n\nUsers are responsible for independently checking important results.",
                ),
                _section(
                  context,
                  "5. No Warranty",
                  "MooseTime is provided on an \"as is\" and \"as available\" basis without warranties of any kind, whether express or implied.\n\nTo the fullest extent permitted by law, the developer makes no warranties regarding the reliability, availability, accuracy, suitability, or fitness of MooseTime for any particular purpose.",
                ),
                _section(
                  context,
                  "6. Limitation of Liability",
                  "To the fullest extent permitted by law, the developer of MooseTime will not be responsible for any loss, damage, injury, delay, operational issue, financial loss, or other consequence arising from:\n- use of the app;\n- inability to use the app;\n- incorrect calculations;\n- outdated information;\n- reliance on information produced by the app; or\n- errors, bugs, or service interruptions.\n\nYou use MooseTime at your own discretion and risk.",
                ),
                _section(
                  context,
                  "7. Acceptable Use",
                  "You agree not to:\n- misuse or intentionally disrupt the app;\n- attempt to interfere with the app's services or infrastructure;\n- attempt to gain unauthorized access to systems or data associated with MooseTime;\n- use MooseTime for unlawful purposes; or\n- reverse engineer, redistribute, resell, or commercially exploit MooseTime except where permitted by applicable law.",
                ),
                _section(
                  context,
                  "8. Intellectual Property",
                  "Unless otherwise stated, MooseTime's original software, design, branding, written content, and other original materials are owned by the developer.\n\nThird-party technologies, libraries, trademarks, and services remain the property of their respective owners.\n\nThe availability of MooseTime for free does not transfer ownership of the app or its source code to users.",
                ),
                _section(
                  context,
                  "9. Feedback and Support",
                  "MooseTime allows users to submit bug reports, feature requests, general feedback, and other support messages.\n\nBy submitting feedback, you give the developer permission to use that feedback to improve MooseTime without an obligation to compensate you.\n\nPlease do not submit classified information, controlled information, sensitive operational information, passwords, or other information that you are not authorized to share.",
                ),
                _section(
                  context,
                  "10. Donations and Support",
                  "MooseTime may offer users an optional way to financially support development.\n\nAny donation or contribution is voluntary and does not provide additional rights, ownership, guaranteed features, priority support, or guaranteed continued availability of MooseTime unless specifically stated otherwise.\n\nCore functionality is intended to remain available without requiring a donation.",
                ),
                _section(
                  context,
                  "11. Third-Party Services",
                  "MooseTime may rely on third-party services for certain features, such as:\n- Supabase for app-related backend services;\n- Apple App Store services;\n- Google Play services; and\n- external links such as GitHub or LinkedIn.\n\nThe developer is not responsible for the availability, security, terms, or practices of third-party services.\n\nUse of those services may also be subject to their own terms and privacy policies.",
                ),
                _section(
                  context,
                  "12. Availability and Updates",
                  "MooseTime may be updated, changed, suspended, or discontinued at any time.\n\nThe developer does not guarantee:\n- continued availability on any app store;\n- continued support for every operating system or device;\n- future updates;\n- maintenance of every feature; or\n- compatibility with future regulatory or procedural changes.\n\nFeatures may be added, changed, or removed as the app develops.",
                ),
                _section(
                  context,
                  "13. Privacy",
                  "Use of MooseTime is also subject to the app's Privacy Policy.\n\nPlease review the Privacy Policy for information about what data MooseTime collects, how it is used, and how services such as Supabase may be involved.",
                  linkLabel: 'Privacy Policy',
                  linkPage: PrivacyScreen(),
                ),
                _section(
                  context,
                  "14. Changes to These Terms",
                  "These Terms of Use may be updated as MooseTime changes.\n\nWhen material changes are made, the \"Last updated\" date at the top of this page may be revised.\n\nContinued use of MooseTime after updated terms become effective constitutes acceptance of the revised terms.",
                ),
                _section(
                  context,
                  "15. Contact",
                  "MooseTime is independently developed and operated by Andy Dylan Gunawan.\n\nIf you have questions, concerns, feedback, legal inquiries, or support requests regarding MooseTime or these Terms of Use, you may contact:\n\nmoosetime.support@gmail.com\n\nYou may also contact the developer through the Feedback & Support section of the app.",
                  linkLabel: 'Feedback & Support',
                  linkPage: FeedbackScreen(),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
