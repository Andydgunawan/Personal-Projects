import '../services/theme_service.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../services/announcement_service.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key, required this.service});

  final AnnouncementService service;

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  String? _openingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(widget.service.refresh());
    });
  }

  String _date(DateTime date) => '${date.month}/${date.day}/${date.year}';

  Future<void> _openAnnouncement(Announcement announcement) async {
    if (_openingId != null || widget.service.offlineMode.isOfflineMode) return;
    setState(() => _openingId = announcement.id);
    try {
      await widget.service.markAsRead(announcement.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: appColor(context, 0xFFF5F8FC),
          title: Text(
            announcement.title,
            style: TextStyle(color: appTextColor(context, 0xFF0A2B5A)),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _date(announcement.date),
                  style: TextStyle(color: appTextColor(context, 0xFF6C819B)),
                ),
                SizedBox(height: 16),
                Text(announcement.body),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save read status. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  Future<void> _goOnline() async {
    try {
      await widget.service.offlineMode.setOfflineMode(false);
      await widget.service.refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not turn off Offline Mode. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColor(context, 0xFFF5F8FC),
      appBar: AppBar(
        title: Text('Announcements'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? darkHeaderStart
            : const Color(0xFF0A2B5A),
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: widget.service,
        builder: (context, _) => widget.service.offlineMode.isOfflineMode
            ? RefreshIndicator(
                onRefresh: widget.service.refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Icon(Icons.cloud_off, size: 40),
                    const SizedBox(height: 16),
                    const Text(
                      'Offline Mode is enabled.\nAnnouncements are unavailable while Offline Mode is active.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: widget.service.offlineMode.isSaving
                          ? null
                          : _goOnline,
                      child: const Text('Turn Off Offline Mode'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  if (widget.service.isLoading) LinearProgressIndicator(),
                  if (widget.service.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            widget.service.errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          TextButton.icon(
                            onPressed: widget.service.isLoading
                                ? null
                                : widget.service.refresh,
                            icon: Icon(Icons.refresh),
                            label: Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: widget.service.refresh,
                      child: widget.service.announcements.isEmpty
                          ? ListView(
                              physics: AlwaysScrollableScrollPhysics(),
                              children: [
                                if (!widget.service.isLoading &&
                                    widget.service.errorMessage == null)
                                  Padding(
                                    padding: EdgeInsets.all(32),
                                    child: Text(
                                      'No announcements yet.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            )
                          : ListView.separated(
                              physics: AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: widget.service.announcements.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final announcement =
                                    widget.service.announcements[index];
                                final unread = !widget.service.isRead(
                                  announcement.id,
                                );
                                return Material(
                                  color: unread
                                      ? appColor(context, 0xFFEAF3FA)
                                      : appColor(context, 0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(16),
                                  clipBehavior: Clip.antiAlias,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: Icon(
                                      unread
                                          ? Icons.mark_email_unread_outlined
                                          : Icons.drafts_outlined,
                                      color: appColor(context, 0xFF0A2B5A),
                                    ),
                                    title: Text(
                                      announcement.title,
                                      style: TextStyle(
                                        color: appTextColor(
                                          context,
                                          0xFF0A2B5A,
                                        ),
                                        fontWeight: unread
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        '${_date(announcement.date)} | ${unread ? 'Unread' : 'Read'}',
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.chevron_right,
                                      color: appColor(context, 0xFF0A2B5A),
                                    ),
                                    onTap: _openingId == null
                                        ? () => _openAnnouncement(announcement)
                                        : null,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
