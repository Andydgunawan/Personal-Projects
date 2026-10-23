import '../services/theme_service.dart';

import 'package:flutter/material.dart';

import '../services/feedback_service.dart';
import '../services/offline_mode_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key, this.service});
  final FeedbackService? service;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  final _email = TextEditingController();
  String? _type;
  bool _submitting = false;

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    _email.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  Future<void> _submit() async {
    final offlineMode = OfflineModeScope.maybeOf(context);
    if (offlineMode?.isOfflineMode == true) return;
    if (_submitting || !_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await (widget.service ?? FeedbackService(offlineMode: offlineMode))
          .submit(
            type: _type!,
            subject: _subject.text,
            message: _message.text,
            email: _email.text,
          );
      if (!mounted || offlineMode?.isOfflineMode == true) return;
      _formKey.currentState!.reset();
      _subject.clear();
      _message.clear();
      _email.clear();
      setState(() => _type = null);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thank you! Your feedback was submitted.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is OfflineModeException
                ? 'Offline Mode is enabled. Your feedback has been kept.'
                : 'Could not submit feedback. Please try again. Your message has been kept.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _goOnline() async {
    final service = OfflineModeScope.maybeOf(context);
    if (service == null) return;
    try {
      await service.setOfflineMode(false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not turn off Offline Mode. Please try again.'),
        ),
      );
    }
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: appColor(context, 0xFFFFFFFF),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );

  @override
  Widget build(BuildContext context) {
    final offlineMode = OfflineModeScope.maybeOf(context);
    final isOffline = offlineMode?.isOfflineMode ?? false;
    return Scaffold(
      backgroundColor: appColor(context, 0xFFF5F8FC),
      appBar: AppBar(
        title: Text('Feedback & Support'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? darkHeaderStart
            : const Color(0xFF0A2B5A),
        foregroundColor: Colors.white,
      ),
      body: isOffline
          ? ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Icon(Icons.cloud_off, size: 40),
                const SizedBox(height: 16),
                const Text(
                  'Offline Mode is enabled.\nFeedback is unavailable while Offline Mode is active.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: offlineMode!.isSaving ? null : _goOnline,
                  child: const Text('Turn Off Offline Mode'),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Report a bug, suggest a feature, or share feedback.',
                      style: TextStyle(
                        color: appTextColor(context, 0xFF0A2B5A),
                      ),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: _decoration('Type'),
                      items: FeedbackService.types
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: _submitting
                          ? null
                          : (value) => setState(() => _type = value),
                      validator: _required,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _subject,
                      enabled: !_submitting,
                      decoration: _decoration('Subject'),
                      validator: _required,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _message,
                      enabled: !_submitting,
                      decoration: _decoration('Message'),
                      minLines: 5,
                      maxLines: 10,
                      validator: _required,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      enabled: !_submitting,
                      decoration: _decoration('Contact Email (optional)'),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isNotEmpty &&
                            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                .hasMatch(email)) {
                          return 'Enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Feedback is sent to MooseTime through Supabase. Your app version and device platform are included to help diagnose issues. Contact email is optional.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: appTextColor(context, 0xFF6C819B),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submitting || isOffline ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColor(context, 0xFF1976D2),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: appColor(
                            context,
                            0xFF1976D2,
                          ),
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _submitting
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Submitting...'),
                                ],
                              )
                            : Text('Submit Feedback'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
