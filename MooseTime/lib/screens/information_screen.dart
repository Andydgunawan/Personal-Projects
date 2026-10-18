import '../services/theme_service.dart';

import 'package:flutter/material.dart';

// Shared presentation only; each information page supplies its own content.
class InformationScreen extends StatelessWidget {
  const InformationScreen({
    super.key,
    required this.title,
    required this.paragraphs,
    this.draft = false,
    this.footer,
  });
  final String title;
  final List<String> paragraphs;
  final bool draft;
  final Widget? footer;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: appColor(context, 0xFFF5F8FC),
    appBar: AppBar(
      title: Text(title),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF174529)
          : const Color(0xFF0A2B5A),
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (draft)
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              'DRAFT ? Review and revise before release.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: appColor(context, 0xFF0A2B5A),
              ),
            ),
          ),
        for (final paragraph in paragraphs)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              paragraph,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: appColor(context, 0xFF0A2B5A),
              ),
            ),
          ),
        ?footer,
      ],
    ),
  );
}
