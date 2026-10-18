import '../services/theme_service.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'support_moosetime_screen.dart';

// Public profile links for the creator.
const githubUrl = 'https://github.com/Andydgunawan';
const linkedinUrl = 'https://www.linkedin.com/in/andydgunawan/';

class AboutCreatorScreen extends StatelessWidget {
  const AboutCreatorScreen({super.key});

  Widget _section(BuildContext context, String heading, String text) => Padding(
    padding: const EdgeInsets.only(top: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: appTextColor(context, 0xFF0A2B5A),
          ),
        ),
        SizedBox(height: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: appTextColor(context, 0xFF0A2B5A),
          ),
        ),
      ],
    ),
  );

  Future<void> _openProfile(
    BuildContext context,
    String url,
    String platform,
  ) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$platform profile coming soon.')));
      return;
    }
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw StateError('Could not open $platform.');
      }
    } catch (error) {
      debugPrint('Could not open $platform profile: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $platform. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: appColor(context, 0xFFF5F8FC),
    appBar: AppBar(
      title: Text('About the Creator'),
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
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 520),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/creator_photo.JPG',
                        fit: BoxFit.contain,
                        semanticLabel: 'Creator photo of Andy',
                        errorBuilder: (context, error, stack) => AspectRatio(
                          aspectRatio: 1220 / 810,
                          child: ColoredBox(
                            color: appColor(context, 0xFFEAF3FA),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 64,
                                  color: appColor(context, 0xFF0A2B5A),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Creator photo coming soon',
                                  style: TextStyle(
                                    color: appTextColor(context, 0xFF0A2B5A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Hi, I'm Andy.",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: appTextColor(context, 0xFF0A2B5A),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "I'm a fourth-year Information Science student at the University of Maryland, College Park, with an interest in software development, data, and building practical tools.",
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: appTextColor(context, 0xFF0A2B5A),
                  ),
                ),
                _section(
                  context,
                  "Inspiration",
                  "MooseTime was inspired by my close friend and AC, Captain Ronald Ramsaran. Without him, I would never have had the idea to create the app. \n\nThe project began after Ronald showed me another tool used for similar mission-planning calculations and walked me through how he used it in practice. As we talked, he pointed out several features he wished were easier to use or more accessible, which gave me the idea to create my own version with a cleaner interface and additional functionality.\n\nOn a whim, I told him, “I think I could build a better app for you,” and that's how the project began."
                ),
                _section(
                  context,
                  "Goal",
                  "My original goal with this project was simply to build something that I could eventually put on my r\u00e9sum\u00e9. As I continued developing MooseTime, though, that goal started to change.\n\nWhen Ronald told me that the app he had been using was a paid app, I was surprised because of the issues it had and the lack of fixes or improvements from its developers.\n\nI realized that MooseTime could actually be useful to ACs in their everyday work. These calculations are something ACs already know how to perform, but doing them manually can be repetitive and time-consuming. Because of that, I didn't want MooseTime to be locked behind a paywall.\n\nMy goal became to create something useful, easy to use, and freely available to the people who could benefit from it.",
                ),
                _section(
                  context,
                  "Development",
                  "Once the idea was there, I spent a couple of days talking with Ronald about the rules, regulations, and calculations the app needed to follow. After I got the gist of how the calculator should work, I started turning his explanations into actual calculator logic.\n\nA large part of the development process involved translating mission-planning rules into code, testing the calculations, prototyping the logic in Python, porting it to Flutter, and repeatedly changing the interface based on what felt confusing or inconvenient.\n\nBefore this project, I had zero experience with Flutter, Supabase, APIs, or mobile app development in general. MooseTime became a way for me to learn all of those things while also learning what it takes to build a complete application from the ground up.\n\nWhat started as me casually saying, \"I think I could build a better app,\" eventually turned into one of the largest projects I've worked on.",
                ),
                _section(
                  context,
                  "Support",
                  "As a college student, I am, admittedly, kind of broke.\n\nI've spent a lot of time working on MooseTime and have paid the costs associated with publishing the app myself because I wanted to keep it free to use.\n\nJust knowing that people are actually using something I created means a lot to me, so first and foremost: Thank you for using MooseTime.\n\nIf the app has been useful to you, one of the best ways you can support it is by leaving a review on the App Store or Google Play Store.\n\nIf you're in a position to support the project financially, I also have an optional way to donate toward the costs of keeping MooseTime available and continuing development.\n\nPlease do not feel obligated to donate. MooseTime is free because I wanted to make these calculations easier and more convenient for ACs, and I intend for the core app to remain free.\n\nPublishing and maintaining an app still comes with costs. I paid the store registration and developer fees out of my own pocket. Because maintaining the iOS version involves an ongoing annual cost, I may not always be able to keep it available on the App Store indefinitely without support.\n\nRegardless of whether you donate, leave a review, send feedback, or simply use the app, I appreciate the support.",
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => SupportMooseTimeScreen(),
                    ),
                  ),
                  icon: Icon(Icons.favorite_outline),
                  label: Text('Support MooseTime'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor(context, 0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                _section(
                  context,
                  'Socials',
                  'If you want to see more of my projects or connect with me, you can find me on GitHub and LinkedIn below.',
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          _openProfile(context, githubUrl, 'GitHub'),
                      icon: Icon(Icons.code),
                      label: Text('GitHub'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: appTextColor(context, 0xFF0A2B5A),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _openProfile(context, linkedinUrl, 'LinkedIn'),
                      icon: Icon(Icons.business_outlined),
                      label: Text('LinkedIn'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: appTextColor(context, 0xFF0A2B5A),
                      ),
                    ),
                  ],
                ),
                _section(
                  context,
                  'Acknowledgment',
                  "Once again, a huge thank you to Captain Ronald Ramsaran for the original inspiration, for taking the time to explain the mission-planning rules to me, and for continuously giving me feedback throughout development.\n\nWithout those conversations, MooseTime would not exist.",
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
