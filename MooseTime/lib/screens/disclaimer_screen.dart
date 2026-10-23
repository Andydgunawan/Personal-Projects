import '../services/theme_service.dart';

import 'package:flutter/material.dart';

import 'feedback_screen.dart';

// Update this date when revising the disclaimer.
const disclaimerLastUpdated = 'October 22, 2026';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  Widget _section(
    BuildContext context,
    String heading,
    String body, {
    String? linkLabel,
    VoidCallback? onLinkTap,
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

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: appColor(context, 0xFFF5F8FC),
    appBar: AppBar(
      title: Text('Disclaimer'),
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
                  'Last updated: $disclaimerLastUpdated',
                  style: TextStyle(
                    fontSize: 14,
                    color: appTextColor(context, 0xFF6C819B),
                  ),
                ),
                _section(
                  context,
                  "1. Introduction",
                  "MooseTime is an independently developed mission and duty-time planning tool intended to help users perform and organize common scheduling calculations more efficiently.\n\nMooseTime is provided for convenience and planning purposes only.",
                ),
                _section(
                  context,
                  "2. Not Official Guidance",
                  "MooseTime is not an official source of operational guidance, regulations, policies, procedures, or instructions.\n\nMooseTime is not affiliated with, endorsed by, sponsored by, approved by, or operated by the United States Air Force, the United States Department of Defense, or any other government or military organization.",
                ),
                _section(
                  context,
                  "3. Verify All Calculations",
                  "Users are responsible for independently verifying all calculations and information produced by MooseTime against current official publications, regulations, policies, procedures, and unit guidance, including, where applicable, AFMAN 202V3_AMCSup Flight Operations, AFMAN 2C-17V3, and any other applicable regulations or guidance.\n\nIf information provided by MooseTime conflicts with an official source, the official source always takes precedence.\n\nMooseTime should not be used as the sole basis for operational, mission, safety, legal, regulatory, or other critical decisions.",
                ),
                _section(
                  context,
                  "4. Accuracy",
                  "Every reasonable effort is made to ensure MooseTime's calculations and functionality are accurate. However, the app may contain:\n\n- calculation errors;\n- software bugs;\n- outdated information;\n- incorrect assumptions;\n- incomplete functionality; or\n- other inaccuracies.\n\nNo guarantee is made that MooseTime will always produce correct results or reflect the most current applicable guidance.",
                ),
                _section(
                  context,
                  "5. User Responsibility",
                  "Use of MooseTime is at the user's own discretion and risk.\n\nThe user remains responsible for understanding and following all applicable rules, regulations, publications, policies, and unit guidance.\n\nMooseTime does not replace professional judgment, official planning procedures, required briefings, or established verification processes.",
                ),
                _section(
                  context,
                  "6. Limitation of Liability",
                  "To the fullest extent permitted by law, the developer of MooseTime is not responsible for any loss, damage, injury, delay, operational issue, financial loss, or other consequence resulting from:\n\n- use of MooseTime;\n- reliance on MooseTime's calculations or information;\n- incorrect or outdated calculations;\n- software errors or bugs;\n- inability to access or use the app; or\n- failure to independently verify information against official sources.",
                ),
                _section(
                  context,
                  "7. Sensitive Information",
                  "Do not enter or submit classified information, controlled information, sensitive operational information, authentication credentials, or any information you are not authorized to share through MooseTime.",
                ),
                _section(
                  context,
                  "8. Changes to MooseTime",
                  "MooseTime may be updated, modified, suspended, or discontinued at any time.\n\nFeatures, calculations, and functionality may change as the app is developed and improved.\n\nUsers are responsible for ensuring they are using appropriate and current official guidance regardless of the version of MooseTime being used.",
                ),
                _section(
                  context,
                  "9. Questions or Concerns",
                  "If you believe MooseTime contains an incorrect calculation, outdated rule, software bug, or other issue, please report it through the Feedback & Support section of the app or contact:\n\nmoosetime.support@gmail.com\n\nMooseTime is independently developed and operated by Andy Dylan Gunawan.",
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
