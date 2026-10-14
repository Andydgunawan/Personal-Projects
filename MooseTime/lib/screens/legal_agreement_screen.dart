import 'package:flutter/material.dart';

import '../services/legal_agreement_service.dart';
import 'terms_screen.dart';
import 'privacy_screen.dart';
import 'disclaimer_screen.dart';

class LegalAgreementScreen extends StatefulWidget {
  const LegalAgreementScreen({
    super.key,
    required this.service,
    required this.onAccepted,
  });
  final LegalAgreementService service;
  final VoidCallback onAccepted;

  @override
  State<LegalAgreementScreen> createState() => _LegalAgreementScreenState();
}

class _LegalAgreementScreenState extends State<LegalAgreementScreen> {
  bool _acknowledged = false;
  bool _saving = false;
  static const _navy = Color(0xFF0A2B5A);

  Future<void> _continue() async {
    if (!_acknowledged || _saving) return;
    setState(() => _saving = true);
    try {
      await widget.service.acceptCurrentVersion();
      if (!mounted) return;
      widget.onAccepted();
    } catch (error, stack) {
      debugPrint('Could not save legal agreement: $error');
      debugPrintStack(stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your agreement. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _document(String label, Widget page) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    title: Text(label, style: const TextStyle(color: _navy)),
    trailing: const Icon(Icons.chevron_right, color: _navy),
    onTap: () =>
        Navigator.of(context)
            .push<void>(MaterialPageRoute(builder: (context) => page)),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F8FC),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to MooseTime',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Before using MooseTime, please review the Terms of Use, Privacy Policy, and Disclaimer.',
                    style: TextStyle(fontSize: 16, height: 1.5, color: _navy),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'MooseTime is a planning aid and is not an official source of operational guidance. Calculations should be verified against current official publications, regulations, and unit guidance.',
                      style: TextStyle(fontSize: 16, height: 1.5, color: _navy),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Legal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _document('Terms of Use', const TermsScreen()),
                        const Divider(height: 1),
                        _document('Privacy Policy', const PrivacyScreen()),
                        const Divider(height: 1),
                        _document('Disclaimer', const DisclaimerScreen()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF1976D2),
                    value: _acknowledged,
                    onChanged: _saving
                        ? null
                        : (value) =>
                              setState(() => _acknowledged = value ?? false),
                    title: const Text(
                      'I agree to the Terms of Use and acknowledge the Privacy Policy and Disclaimer.',
                      style: TextStyle(fontSize: 16, height: 1.5, color: _navy),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _acknowledged && !_saving ? _continue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFDDEAF5),
                        disabledForegroundColor: const Color(0xFF526780),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _saving
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Saving...'),
                              ],
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
