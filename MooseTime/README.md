# MooseTime

MooseTime is a Flutter mobile application for mission and duty-time calculations.

## Run on Android

Run these commands from the `MooseTime` directory, which contains `pubspec.yaml`.
The project currently uses Flutter 3.47.7 with Dart 3.13.5. Android SDK tools,
an emulator, and a compatible JDK must be installed; check their setup with
`flutter doctor -v`.

```powershell
flutter pub get
flutter emulators
flutter emulators --launch Medium_Phone_API_37.0
flutter devices
flutter run -d emulator-5554
```

Skip the emulator launch command if it is already running. Use the emulator name
and device ID reported on your machine if they differ from the examples above.
In VS Code, select the Android emulator as the device and run `lib/main.dart`.

`flutter pub get` can report that newer packages are incompatible with the
current constraints even when dependency resolution succeeds. Commit
`pubspec.lock` to keep the app's resolved dependency versions reproducible.

## Android clipboard compatibility

The stable `super_clipboard` dependency includes `irondash_engine_context` and
`super_native_extensions`, whose Android builds hard-code compile SDK 31.
Their AndroidX dependencies require a newer compile SDK. The project-level
`android/build.gradle.kts` raises those two libraries' compile SDK to at least
the app's compile SDK before Android finalizes their build configuration.
Keep this setting in the project so dependency restores retain the fix.

## Checks

```powershell
flutter analyze
flutter test
```

See Flutter's [Android setup guide](https://docs.flutter.dev/platform-integration/android/setup)
for toolchain and emulator setup.
