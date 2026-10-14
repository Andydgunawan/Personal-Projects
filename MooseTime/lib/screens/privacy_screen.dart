import 'package:flutter/material.dart';

import 'feedback_screen.dart';

import 'package:url_launcher/url_launcher.dart';

// Update this date when revising the policy.
const privacyLastUpdated = 'October 14, 2026';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});
  static const _navy = Color(0xFF0A2B5A);
  static const _bodyStyle = TextStyle(fontSize: 16, height: 1.6, color: _navy);

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
              color: _navy,
            ),
          ),
          const SizedBox(height: 12),
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
                        foregroundColor: const Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        textStyle: _bodyStyle.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      child: Text(linkLabel!),
                    ),
                  ),
                  TextSpan(text: part),
                ],
              ],
            ),
            style: _bodyStyle,
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
          const SnackBar(
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
    backgroundColor: const Color(0xFFF5F8FC),
    appBar: AppBar(
      title: const Text('Privacy Policy'),
      backgroundColor: _navy,
      foregroundColor: Colors.white,
    ),
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Last updated: $privacyLastUpdated',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6C819B)),
                ),
                _section(
                  context,
                  "1. Information MooseTime Collects",
                  "MooseTime does not require users to create an account or sign in.\n\nThe app may collect information only when you choose to use certain features, such as submitting feedback or support requests.",
                ),
                _section(
                  context,
                  "Feedback and Support",
                  "When you submit feedback through MooseTime, the app may collect:\n\n- Feedback type\n- Subject\n- Message\n- Optional contact email address\n- App version\n- Device platform\n- Date and time of submission\n\nThe contact email field is optional. You may submit feedback without providing an email address.\n\nFeedback submissions are stored using Supabase.",
                  subsection: true,
                ),
                _section(
                  context,
                  "2. Calculator Data",
                  "MooseTime's mission and duty-time calculations are intended to be performed locally on your device.\n\nCalculator inputs and calculated results are not intentionally uploaded to Supabase or stored on MooseTime's servers.\n\nMooseTime does not maintain a cloud history of your calculations.\n\nIf this behavior changes in a future version, this Privacy Policy will be updated.",
                ),
                _section(
                  context,
                  "3. Announcement Data",
                  "MooseTime retrieves in-app announcements from Supabase.\n\nThe app may store the IDs of announcements you have read locally on your device so that it can determine which announcements should appear as unread.\n\nThis read/unread information is stored locally using device storage such as SharedPreferences and is not intended to be uploaded to MooseTime's servers.",
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
                  "MooseTime may provide users with an optional way to financially support the app.\n\nIf donations, in-app purchases, or other payment features are added, payment processing may be handled by Apple, Google, or another third-party payment provider.\n\nMooseTime does not intend to directly store payment card information.\n\nThis Privacy Policy should be updated if payment functionality changes.",
                ),
                _section(
                  context,
                  "9. Sensitive Information",
                  "Please do not submit sensitive information through the Feedback & Support form.\n\nThis includes, but is not limited to:\n- Classified information\n- Controlled or restricted operational information\n- Passwords\n- Authentication credentials\n- Social Security numbers\n- Financial account information\n- Medical information\n- Any information you are not authorized to share\n\nFeedback submissions should contain only the information necessary to explain your issue, suggestion, or question.",
                  linkLabel: 'Feedback & Support',
                  onLinkTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => const FeedbackScreen(),
                    ),
                  ),
                ),
                _section(
                  context,
                  "10. Data Retention",
                  "Feedback and support submissions may be retained for as long as reasonably necessary to review the submission, respond to issues, improve MooseTime, or maintain development records.\n\nSubmissions may later be deleted when they are no longer needed.\n\nLocally stored information, such as announcement read status, generally remains on your device until:\n- the app clears or replaces that information;\n- you clear the app's data; or\n- you uninstall MooseTime.",
                ),
                _section(
                  context,
                  "11. Data Security",
                  "Reasonable efforts are made to protect information associated with MooseTime.\n\nMooseTime uses access controls and database security features, including Supabase Row Level Security, to limit how application data can be accessed.\n\nHowever, no electronic storage, transmission, or online service can be guaranteed to be completely secure.",
                ),
                _section(
                  context,
                  "12. Children's Privacy",
                  "MooseTime is not designed specifically for children and is intended for users who have a legitimate reason to use its mission and duty-time planning functionality.\n\nMooseTime does not knowingly seek to collect personal information from children.\n\nIf you believe personal information from a child has been submitted through MooseTime, please contact the developer through the Feedback & Support section.",
                  linkLabel: 'Feedback & Support',
                  onLinkTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => const FeedbackScreen(),
                    ),
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
                  "If you have questions about this Privacy Policy or how MooseTime handles information, you can contact the developer through the Feedback & Support section of the app.",
                  linkLabel: 'Feedback & Support',
                  onLinkTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => const FeedbackScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Draft notice: This Privacy Policy is a draft and should be reviewed before MooseTime is publicly released.',
                    style: TextStyle(fontSize: 14, height: 1.5, color: _navy),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
