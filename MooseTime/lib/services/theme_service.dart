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

// Shared dark palette. Light colors remain supplied by each existing widget.
const darkBackground = Color(0xFF0D1117);
const darkSurface = Color(0xFF151B23);
const darkElevatedSurface = Color(0xFF1B2430);
const darkHeaderStart = Color(0xFF14202B);
const darkHeaderEnd = Color(0xFF193326);
const darkBorder = Color(0xFF2A3441);
const darkPrimaryText = Color(0xFFF3F6FA);
const darkSecondaryText = Color(0xFFA7B3C2);
const darkMutedText = Color(0xFF7E8A98);
const darkAccent = Color(0xFF7EE2A8);
const darkAccentFill = Color(0xFF1F5A3A);
const darkSelected = Color(0xFF234B33);
const darkBadge = Color(0xFF2FAF68);
const darkHighlight = Color(0xFFC9A227);

bool isDarkTheme(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color appColor(BuildContext context, int light) {
  if (!isDarkTheme(context)) return Color(light);
  return const <int, Color>{
        0xFF0A2B5A: darkAccent,
        0xFF1976D2: darkAccentFill,
        0xFFF5F8FC: darkBackground,
        0xFFFFFFFF: darkSurface,
        0xFFEAF3FA: darkElevatedSurface,
        0xFFDDEAF5: darkElevatedSurface,
        0xFF6C819B: darkSecondaryText,
        0xFF526780: darkSecondaryText,
        0xFFF8FBFE: darkElevatedSurface,
        0xFFD5E2EE: darkBorder,
        0xFFBFD9EF: darkSelected,
        0xFFE7F2FC: darkBackground,
        0xFFDDEEFF: darkElevatedSurface,
        0xFFEDF4FB: darkBorder,
        0xFFEDF6FF: darkElevatedSurface,
        0xFFEAF4FF: darkElevatedSurface,
        0xFFFFF2A0: darkHighlight,
        0xFF527D9E: darkHeaderEnd,
      }[light] ??
      Color(light);
}

Color appTextColor(BuildContext context, int light) {
  if (!isDarkTheme(context)) return Color(light);
  return switch (light) {
    0xFF6C819B || 0xFF526780 || 0xFF1976D2 => darkSecondaryText,
    _ => darkPrimaryText,
  };
}

List<Color> appHeaderColors(BuildContext context, int start, int end) =>
    isDarkTheme(context)
    ? const [darkHeaderStart, darkHeaderEnd]
    : [Color(start), Color(end)];

ThemeData buildDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: darkAccent,
          brightness: Brightness.dark,
          surface: darkSurface,
        ).copyWith(
          primary: darkAccent,
          onPrimary: darkBackground,
          primaryContainer: darkSelected,
          onPrimaryContainer: darkAccent,
          secondary: darkAccent,
          onSecondary: darkBackground,
          secondaryContainer: darkSelected,
          onSecondaryContainer: darkAccent,
          surfaceContainerLowest: darkBackground,
          surfaceContainerLow: darkSurface,
          surfaceContainer: darkSurface,
          surfaceContainerHigh: darkElevatedSurface,
          surfaceContainerHighest: darkElevatedSurface,
          onSurface: darkPrimaryText,
          onSurfaceVariant: darkSecondaryText,
          outline: darkBorder,
          outlineVariant: darkBorder,
          surfaceTint: Colors.transparent,
        ),
    scaffoldBackgroundColor: darkBackground,
    dividerColor: darkBorder,
    disabledColor: darkMutedText,
    hintColor: darkMutedText,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: darkPrimaryText,
      displayColor: darkPrimaryText,
    ),
    primaryTextTheme: base.primaryTextTheme.apply(
      bodyColor: darkPrimaryText,
      displayColor: darkPrimaryText,
    ),
    iconTheme: const IconThemeData(color: darkAccent),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.disabled) ? darkMutedText : darkAccent,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? darkAccentFill
            : darkElevatedSurface,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? darkAccent
            : darkSecondaryText,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkHeaderStart,
      foregroundColor: darkPrimaryText,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(color: darkBorder),
    inputDecorationTheme: const InputDecorationTheme(
      fillColor: darkElevatedSurface,
      hintStyle: TextStyle(color: darkMutedText),
      labelStyle: TextStyle(color: darkMutedText),
      helperStyle: TextStyle(color: darkSecondaryText),
    ),
    listTileTheme: ListTileThemeData(
      textColor: darkPrimaryText,
      iconColor: darkAccent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkSurface,
      indicatorColor: darkSelected,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => base.textTheme.labelMedium!.copyWith(
          color: states.contains(WidgetState.selected)
              ? darkAccent
              : darkMutedText,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: darkElevatedSurface,
      contentTextStyle: TextStyle(color: darkPrimaryText),
    ),
  );
}
