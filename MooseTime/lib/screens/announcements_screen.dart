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
    if (_openingId != null) return;
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
            style: TextStyle(color: appColor(context, 0xFF0A2B5A)),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _date(announcement.date),
                  style: TextStyle(color: appColor(context, 0xFF6C819B)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColor(context, 0xFFF5F8FC),
      appBar: AppBar(
        title: Text('Announcements'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF174529)
            : const Color(0xFF0A2B5A),
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: widget.service,
        builder: (context, _) => Column(
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
                                  color: appColor(context, 0xFF0A2B5A),
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
