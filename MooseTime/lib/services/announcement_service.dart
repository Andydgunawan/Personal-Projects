import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/announcement.dart';
import 'offline_mode_service.dart';

class AnnouncementService extends ChangeNotifier {
  AnnouncementService(
    this._preferences, {
    this.client,
    this.fetchRows,
    OfflineModeService? offlineMode,
  }) : offlineMode = offlineMode ?? OfflineModeService(_preferences),
       _ownsOfflineMode = offlineMode == null {
    _readIds.addAll(_preferences.getStringList(storageKey) ?? []);
    this.offlineMode.addListener(_offlineModeChanged);
  }

  final OfflineModeService offlineMode;
  final bool _ownsOfflineMode;
  bool _disposed = false;
  int _requestVersion = 0;

  void _offlineModeChanged() {
    // Ignore completions from requests started before this settings change.
    _requestVersion++;
    _refreshFuture = null;
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    offlineMode.removeListener(_offlineModeChanged);
    if (_ownsOfflineMode) offlineMode.dispose();
    super.dispose();
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
    if (_disposed || offlineMode.isOfflineMode) return Future.value();
    if (_refreshFuture != null) return _refreshFuture!;
    final version = ++_requestVersion;
    return _refreshFuture = _loadAnnouncements(version).whenComplete(() {
      if (version == _requestVersion) _refreshFuture = null;
    });
  }

  Future<void> _loadAnnouncements(int version) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      offlineMode.requireOnline();
      final rows =
          await (fetchRows != null
                  ? fetchRows!()
                  : (client ?? Supabase.instance.client)
                        .from('announcements')
                        .select()
                        .eq('is_active', true)
                        .order('created_at', ascending: false))
              .timeout(const Duration(seconds: 15));
      if (_disposed ||
          version != _requestVersion ||
          offlineMode.isOfflineMode) {
        return;
      }
      _announcements = rows.map(Announcement.fromJson).toList();
    } catch (_) {
      if (_disposed ||
          version != _requestVersion ||
          offlineMode.isOfflineMode) {
        return;
      }
      // Keep both the last successful list and all locally saved read IDs.
      errorMessage =
          'Could not load announcements. Check your connection and try again.';
    } finally {
      if (!_disposed && version == _requestVersion) {
        isLoading = false;
        notifyListeners();
      }
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
