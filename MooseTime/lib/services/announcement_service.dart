import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/announcement.dart';

class AnnouncementService extends ChangeNotifier {
  AnnouncementService(this._preferences, {this.client, this.fetchRows}) {
    _readIds.addAll(_preferences.getStringList(storageKey) ?? []);
  }

  static const storageKey = 'read_announcement_ids';
  final SharedPreferences _preferences;
  final Set<String> _readIds = {};

  final SupabaseClient? client;
  final Future<List<Map<String, dynamic>>> Function()? fetchRows;
  List<Announcement> _announcements = [];
  List<Announcement> get announcements => List.unmodifiable(_announcements);
  bool isLoading = false;
  String? errorMessage;
  Future<void>? _refreshFuture;
  Future<void> _readWrite = Future.value();

  Future<void> refresh() {
    return _refreshFuture ??= _loadAnnouncements().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<void> _loadAnnouncements() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final rows =
          await (fetchRows != null
                  ? fetchRows!()
                  : (client ?? Supabase.instance.client)
                        .from('announcements')
                        .select()
                        .eq('is_active', true)
                        .order('created_at', ascending: false))
              .timeout(const Duration(seconds: 15));
      _announcements = rows.map(Announcement.fromJson).toList();
    } catch (_) {
      // Keep both the last successful list and all locally saved read IDs.
      errorMessage =
          'Could not load announcements. Check your connection and try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool isRead(String id) => _readIds.contains(id);

  int get unreadCount =>
      announcements.where((announcement) => !isRead(announcement.id)).length;

  Future<void> markAsRead(String id) {
    final write = _readWrite.then((_) => _saveReadId(id));
    _readWrite = write.catchError((Object _) {});
    return write;
  }

  Future<void> _saveReadId(String id) async {
    if (isRead(id)) return;
    if (!announcements.any((announcement) => announcement.id == id)) {
      throw ArgumentError.value(id, 'id', 'Unknown announcement');
    }
    // Publish read state only after the save succeeds.
    final updatedIds = {..._readIds, id};
    final saved = await _preferences.setStringList(
      storageKey,
      updatedIds.toList(),
    );
    if (!saved) throw StateError('Could not save announcement read status');
    _readIds.add(id);
    notifyListeners();
  }
}

