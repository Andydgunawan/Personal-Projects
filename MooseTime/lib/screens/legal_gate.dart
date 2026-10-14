import 'package:flutter/material.dart';

import '../services/announcement_service.dart';
import '../services/legal_agreement_service.dart';
import 'legal_agreement_screen.dart';
import 'root_screen.dart';

class LegalGate extends StatefulWidget {
  const LegalGate({
    super.key,
    required this.legalService,
    required this.announcementService,
  });
  final LegalAgreementService legalService;
  final AnnouncementService announcementService;

  @override
  State<LegalGate> createState() => _LegalGateState();
}

class _LegalGateState extends State<LegalGate> {
  late bool _accepted;

  @override
  void initState() {
    super.initState();
    // Preferences were loaded before runApp, so the Calculator never flashes.
    _accepted = widget.legalService.hasAcceptedCurrentVersion;
  }

  @override
  Widget build(BuildContext context) => _accepted
      ? RootScreen(announcementService: widget.announcementService)
      : LegalAgreementScreen(
          service: widget.legalService,
          onAccepted: () => setState(() => _accepted = true),
        );
}
