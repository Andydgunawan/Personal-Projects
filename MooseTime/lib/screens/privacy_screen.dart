import '../services/theme_service.dart';

import 'package:flutter/material.dart';

import 'feedback_screen.dart';

import 'package:url_launcher/url_launcher.dart';

// Update this date when revising the policy.
const privacyLastUpdated = 'October 22, 2026';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  Widget _section(
    BuildContext context,
    String heading,
    String body, {
    String? linkLabel,
    VoidCallback? onLinkTap,
    bool subsection = false,
  }) {
    final formattedBody = body.replaceAll('\n- ', '\n\u2022 ');
    final parts = linkLabel == null
        ? [formattedBody]
        : formattedBody.split(linkLabel);
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: TextStyle(
              fontSize: subsection ? 18 : 20,
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
                      onPressed: onLinkTap,
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

  Future<void> _openSupabasePrivacy(BuildContext context) async {
    try {
      final opened = await launchUrl(
        Uri.parse('https://supabase.com/privacy'),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) throw StateError('Could not open the privacy page.');
    } catch (error) {
      debugPrint('Could not open Supabase privacy page: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open Supabase privacy information. Please try again.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: appColor(context, 0xFFF5F8FC),
    appBar: AppBar(
      title: Text('Privacy Policy'),
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
                  'Last updated: $privacyLastUpdated',
                  style: TextStyle(
                    fontSize: 14,
                    color: appTextColor(context, 0xFF6C819B),
                  ),
                ),
                _section(
                  context,
                  "1. Information MooseTime Collects",
                  "MooseTime does not require users to create an account or sign in.\n\nMost calculator functionality is performed locally on your device. However, MooseTime connects to third-party backend services for certain features, including retrieving in-app announcements and submitting feedback or support requests.",
                ),
                _section(
                  context,
                  "Feedback and Support",
                  "When you submit feedback through MooseTime, the app sends the following information to Supabase:\n\n- Feedback type\n- Subject\n- Message\n- Optional contact email address\n- App version\n- Device platform\n- Date and time of submission\n\nThe contact email field is optional. You may submit feedback without providing an email address.\n\nFeedback submissions are stored using Supabase.",
                  subsection: true,
                ),
                _section(
                  context,
                  "Automatic Network and Service Logs",
                  "When MooseTime communicates with Supabase, including when retrieving announcements or submitting feedback, Supabase infrastructure may automatically process and retain technical information associated with the request.\n\nDepending on Supabase's logging and infrastructure configuration, this information may include items such as:\n- IP Address\n- User agent or application environment\n- Request method and request URL or endpoint\n- Date and time of the request\n- Response status and other request or diagnostic metadata\n- Limited network or geographic information derived by Supabase's infrastructure\n\nThis technical information may be processed by Supabase for purposes such as operating the service, security, abuse prevention, troubleshooting, diagnostics, and service monitoring.\n\nMooseTime does not use these infrastructure logs to create user profiles or advertising profiles.",
                  subsection: true,
                ),
                _section(
                  context,
                  "2. Calculator Data",
                  "MooseTime performs its mission and duty-time calculations locally on your device.\n\nCalculator inputs and calculated results are not transmitted by MooseTime to Supabase and are not stored in MooseTime's feedback or announcement databases.\n\nMooseTime does not maintain a cloud history of your calculator inputs or calculated results.\n\nNetwork requests made for other app features, such as retrieving announcements or submitting feedback, may generate service and infrastructure logs as described in this Privacy Policy.\n\nIf MooseTime's handling of calculator data changes in a future version, this Privacy Policy will be updated accordingly.",
                ),
                _section(
                  context,
                  "3. Announcement Data",
                  "MooseTime retrieves in-app announcements from Supabase. Retrieving announcements requires a network request to Supabase and may result in technical request information being processed or logged by Supabase as described in the Automatic Network and Service Logs section of this Privacy Policy.\n\nMooseTime stores the identifiers of announcements you have read locally on your device so that it can determine which announcements should appear as unread.\n\nMooseTime does not transmit those locally stored read/unread identifiers to its announcement database.",
                ),
                _section(
                  context,
                  "4. Information Stored Locally",
                  "MooseTime may store limited information locally on your device to support app functionality.\n\nThis may include:\n- Announcement read/unread status\n- App preferences or settings\n- Temporary application state\n\nThis information generally remains on your device unless otherwise stated.",
                ),
                _section(
                  context,
                  "5. How Information Is Used",
                  "Information collected through MooseTime may be used to:\n\n- Respond to support requests\n- Review bug reports\n- Evaluate feature requests\n- Improve MooseTime\n- Diagnose technical issues\n- Understand which version or platform a reported issue occurred on\n- Provide in-app announcements and updates\n\nMooseTime does not sell your personal information.",
                ),
                _section(
                  context,
                  "6. Supabase",
                  "MooseTime uses Supabase for certain backend services.\n\nSupabase is currently used to:\n- Deliver in-app announcements\n- Store feedback and support submissions\n\nInformation sent through these features may be processed and stored through Supabase infrastructure.\n\nSupabase's handling of information is also subject to its own privacy and security practices.",
                  linkLabel: 'Supabase',
                  onLinkTap: () => _openSupabasePrivacy(context),
                ),
                _section(
                  context,
                  "7. App Stores and Third-Party Services",
                  "MooseTime may be distributed through third-party platforms such as:\n- Apple App Store\n- Google Play Store\n\nThose platforms may independently collect information related to downloads, purchases, device information, diagnostics, or account activity according to their own privacy policies.\n\nMooseTime may also contain links to third-party websites or services, such as GitHub or LinkedIn.\n\nMooseTime is not responsible for the privacy practices of third-party services.",
                ),
                _section(
                  context,
                  "8. Donations and Payments",
                  "MooseTime may provide users with an optional way to financially support development.\n\nWhere an optional support or payment feature is available, payment processing is handled through the applicable third-party platform or payment service.\n\nMooseTime does not directly collect or store users' payment card information.\n\nPayment providers and app-store platforms may independently process information related to purchases, transactions, accounts, devices, or payment activity according to their own privacy policies.",
                ),
                _section(
                  context,
                  "9. Sensitive Information",
                  "Please do not submit sensitive information through the Feedback & Support form.\n\nThis includes, but is not limited to:\n- Classified information\n- Controlled or restricted operational information\n- Passwords\n- Authentication credentials\n- Social Security numbers\n- Financial account information\n- Medical information\n- Any information you are not authorized to share\n\nFeedback submissions should contain only the information necessary to explain your issue, suggestion, or question.",
                  linkLabel: 'Feedback & Support',
                  onLinkTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (context) => FeedbackScreen()),
                  ),
                ),
                _section(
                  context,
                  "10. Data Retention and Deletion",
                  "Feedback and support submissions may be retained for as long as reasonably necessary to review the submission, respond to issues, improve MooseTime, maintain development records, protect the service, or satisfy applicable legal obligations.\n\nYou may request deletion of personal information contained in a feedback or support submission by contacting:\n\nmoosetime.support@gmail.com\n\nPlease provide enough information for the developer to reasonably identify the submission you would like deleted. This may include the email address used with the submission, the approximate submission date, its subject, or other identifying details.\n\nIf feedback was submitted anonymously and does not contain information that can reasonably be associated with you, the developer may be unable to identify which submission belongs to you and therefore may be unable to fulfill a request to delete that specific submission.\n\nRequests will be evaluated and processed as reasonably appropriate, subject to any information that must be retained for legitimate security, legal, fraud-prevention, dispute-resolution, or other lawful purposes.\n\nLocally stored information, such as announcement read status and app preferences, generally remains on your device until:\n- the app clears or replaces that information;\n- you clear the app's data; or\n- you uninstall MooseTime.\n\nTechnical logs maintained by third-party service providers may be retained according to those providers' applicable retention policies.",
                ),
                _section(
                  context,
                  "11. Data Security",
                  "Reasonable technical and organizational measures are used to protect information associated with MooseTime.\n\nMooseTime uses Supabase for certain backend services. Access to MooseTime's Supabase database is restricted through database access controls, including Row Level Security policies where configured.\n\nNo electronic storage, transmission, database, or online service can be guaranteed to be completely secure.",
                ),
                _section(
                  context,
                  "12. Children's Privacy",
                  "MooseTime is not designed specifically for children and is intended for users who have a legitimate reason to use its mission and duty-time planning functionality.\n\nMooseTime does not knowingly seek to collect personal information from children.\n\nIf you believe personal information from a child has been submitted through MooseTime, please contact the developer at moosetime.support@gmail.com or through the Feedback & Support section of the app.",
                  linkLabel: 'Feedback & Support',
                  onLinkTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (context) => FeedbackScreen()),
                  ),
                ),
                _section(
                  context,
                  "13. Your Choices",
                  "You may use MooseTime's calculator functionality without providing a contact email address.\n\nYou may choose not to submit feedback or support requests.\n\nIf you submit feedback without an email address, the developer may not have a way to contact you directly regarding your submission.",
                ),
                _section(
                  context,
                  "14. Changes to This Privacy Policy",
                  "This Privacy Policy may be updated as MooseTime changes.\n\nIf features are added that affect how information is collected, stored, or used, this policy may be revised accordingly.\n\nThe Last updated date at the top of this page will reflect meaningful changes.",
                ),
                _section(
                  context,
                  "15. Contact",
                  "MooseTime is independently developed and operated by Andy Dylan Gunawan.\n\nIf you have questions about this Privacy Policy, MooseTime's handling of information, or a request concerning your personal information, contact:\n\nmoosetime.support@gmail.com\n\nYou may also contact the developer through the Feedback & Support section of the app.",
                  linkLabel: 'Feedback & Support',
                  onLinkTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (context) => FeedbackScreen()),
                  ),
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
