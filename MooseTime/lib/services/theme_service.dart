import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  ThemeService(this.preferences)
    : isDark = preferences.getBool(storageKey) ?? false;

  static const storageKey = 'dark_mode';
  final SharedPreferences preferences;
  bool isDark;

  Future<void> setDark(bool value) async {
    if (value == isDark) return;
    if (!await preferences.setBool(storageKey, value)) {
      throw StateError('Could not save appearance.');
    }
    isDark = value;
    notifyListeners();
  }
}

class ThemeScope extends InheritedNotifier<ThemeService> {
  const ThemeScope({
    super.key,
    required ThemeService service,
    required super.child,
  }) : super(notifier: service);

  static ThemeService? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeScope>()?.notifier;
}

/// Maps the original blue and white palette to green and black in dark mode.
Color appColor(BuildContext context, int light) {
  if (Theme.of(context).brightness != Brightness.dark) return Color(light);
  return Color(
    const <int, int>{
          0xFF0A2B5A: 0xFF82D9A0,
          0xFF1976D2: 0xFF238B50,
          0xFFF5F8FC: 0xFF090E0B,
          0xFFFFFFFF: 0xFF131D17,
          0xFFEAF3FA: 0xFF192C20,
          0xFFDDEAF5: 0xFF203B29,
          0xFF6C819B: 0xFFA0B7A7,
          0xFF526780: 0xFFA0B7A7,
          0xFFF8FBFE: 0xFF101A14,
          0xFFD5E2EE: 0xFF35513F,
          0xFFBFD9EF: 0xFF285C3A,
          0xFFE7F2FC: 0xFF102017,
          0xFFDDEEFF: 0xFF244B32,
          0xFFEDF4FB: 0xFF2D4836,
          0xFFEDF6FF: 0xFF192C20,
          0xFFEAF4FF: 0xFF192C20,
          0xFFFFF2A0: 0xFF38502A,
          0xFF527D9E: 0xFF254F35,
        }[light] ??
        light,
  );
}
