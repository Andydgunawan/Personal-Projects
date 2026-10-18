import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OfflineModeException implements Exception {
  const OfflineModeException();

  @override
  String toString() => 'Offline Mode is enabled.';
}

class OfflineModeService extends ChangeNotifier {
  OfflineModeService(this.preferences)
    : _isOfflineMode = preferences.getBool(storageKey) ?? false;

  static const storageKey = 'offline_mode';
  final SharedPreferences preferences;
  bool _isOfflineMode;
  bool _saving = false;
  bool get isOfflineMode => _isOfflineMode;
  bool get isSaving => _saving;

  void requireOnline() {
    if (isOfflineMode) throw const OfflineModeException();
  }

  Future<void> setOfflineMode(bool value) async {
    if (_saving || value == _isOfflineMode) return;
    final previous = _isOfflineMode;
    _saving = true;
    // Block requests immediately when enabling. Re-enable only after saving.
    if (value) _isOfflineMode = true;
    notifyListeners();
    try {
      if (!await preferences.setBool(storageKey, value)) {
        throw StateError('Could not save Offline Mode.');
      }
      _isOfflineMode = value;
    } catch (_) {
      _isOfflineMode = previous;
      rethrow;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}

// Same small inherited-notifier pattern used by ThemeScope.
class OfflineModeScope extends InheritedNotifier<OfflineModeService> {
  const OfflineModeScope({
    super.key,
    required OfflineModeService service,
    required super.child,
  }) : super(notifier: service);

  static OfflineModeService? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OfflineModeScope>()?.notifier;
}

/// A backstop for Supabase HTTP calls, including SDK auth recovery and retries.
/// Requests already handed to the transport cannot be recalled.
class OfflineHttpClient extends http.BaseClient {
  OfflineHttpClient(this.offlineMode, {http.Client? inner})
    : _inner = inner ?? http.Client();

  final OfflineModeService offlineMode;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    offlineMode.requireOnline();
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
